require 'cgi'
require 'json'
require 'net/http'
require 'openssl'
require 'base64'
require 'uri'
require 'stringio'

# Exports Vellum projects to Google Drive using the Drive REST API directly,
# authenticated via a Google service account (JWT bearer flow).
class GoogleDriveExporter
  DRIVE_API      = 'https://www.googleapis.com/drive/v3'
  DRIVE_UPLOAD   = 'https://www.googleapis.com/upload/drive/v3'
  TOKEN_URI      = 'https://oauth2.googleapis.com/token'
  SCOPE          = 'https://www.googleapis.com/auth/drive'
  BOUNDARY       = 'vellum_multipart_boundary'

  def initialize(service_account_json_path)
    @credentials  = JSON.parse(File.read(service_account_json_path))
    @access_token = fetch_access_token
  end

  # Exports a single project. Returns { folder_id:, folder_url:, warnings: [] }.
  # Pass parent_folder_id to nest the project folder inside an existing Drive folder.
  def export_project(project, parent_folder_id: nil)
    @warnings       = []
    @warnings_mutex = Mutex.new

    log "Creating folder: #{project.name}"
    folder = create_folder(project.name, parent_id: parent_folder_id)

    template_folder_ids = {}
    project.doc_templates.order(:name).each do |template|
      log "  Creating subfolder: #{template.name}"
      tf = create_folder(template.name, parent_id: folder['id'])
      template_folder_ids[template.id] = tf['id']
    end

    log "  Uploading project JSON"
    upload_file("#{project.name}.json", project.to_vproj_json, 'application/json', parent_id: folder['id'])

    docs = project.docs.includes(
      :doc_template,
      outward_relationships: [:relationship_type, :right],
      inward_relationships:  [:relationship_type, :left]
    ).to_a

    # First pass: upload all docs in parallel to get their Drive URLs
    file_map = {}
    file_map_mutex = Mutex.new
    parallel_each(docs) do |doc|
      log "  Uploading: #{doc.name}"
      parent_id = template_folder_ids[doc.doc_template_id]
      file = create_doc(doc.name, render_doc_html(doc, {}), parent_id: parent_id)
      file_map_mutex.synchronize { file_map[doc.id] = file }
    end

    # Second pass: re-upload docs that have relationships, now with real links
    url_map = file_map.transform_values { |f| f['webViewLink'] }
    docs_with_relationships = docs.select { |doc| doc.outward_relationships.any? || doc.inward_relationships.any? }
    parallel_each(docs_with_relationships) do |doc|
      log "  Adding links: #{doc.name}"
      update_doc(file_map[doc.id]['id'], doc.name, render_doc_html(doc, url_map))
    end

    export_publications(project, parent_folder_id: folder['id'])

    emails = project.members.map(&:email).compact.uniq
    emails.each do |email|
      log "  Sharing with #{email}"
      share_folder(folder['id'], email)
    rescue => e
      warn "Could not share with #{email}: #{e.message}"
    end

    if @warnings.any?
      log "  Uploading export warnings"
      warnings_text = "Export warnings for #{project.name}\n" \
                      "Generated: #{Time.now}\n\n" +
                      @warnings.map { |w| "- #{w}" }.join("\n")
      upload_file("Export Warnings.txt", warnings_text, 'text/plain', parent_id: folder['id'])
    end

    folder_url = "https://drive.google.com/drive/folders/#{folder['id']}"
    { folder_id: folder['id'], folder_url: folder_url, warnings: @warnings }
  end

  private

  # ── Concurrency ───────────────────────────────────────────────────────────

  def parallel_each(items, max_threads: 8, &block)
    return if items.empty?
    mutex = Mutex.new
    queue = items.dup
    [items.size, max_threads].min.times.map do
      Thread.new do
        loop do
          item = mutex.synchronize { queue.shift }
          break unless item
          block.call(item)
        end
      ensure
        ActiveRecord::Base.clear_active_connections!
      end
    end.each(&:join)
  end

  # ── Publication template export ───────────────────────────────────────────

  def export_publications(project, parent_folder_id:)
    renderable = project.publication_templates
      .includes(:doc_template)
      .select { |pt| %w(standalone doc).include?(pt.template_type) }
    return if renderable.empty?

    log "  Creating Publications subfolder"
    pub_folder = create_folder("Publications", parent_id: parent_folder_id)

    renderable.each do |pt|
      case pt.template_type
      when 'standalone'
        export_standalone_publication(pt, project, parent_folder_id: pub_folder['id'])
      when 'doc'
        export_doc_publication(pt, project, parent_folder_id: pub_folder['id'])
      end
    end
  end

  def export_standalone_publication(pt, project, parent_folder_id:)
    log "  Publishing standalone: #{pt.name}"
    content = pt.execute(project: project)
    filename = "#{pt.name}#{publication_extension(pt)}"
    upload_file(filename, content, publication_mime_type(pt), parent_id: parent_folder_id)
  rescue => e
    warn "Failed to render publication '#{pt.name}': #{e.message}"
  end

  def export_doc_publication(pt, project, parent_folder_id:)
    return unless pt.doc_template
    docs = project.docs.where(doc_template_id: pt.doc_template_id).to_a
    return if docs.empty?

    log "  Creating Publications/#{pt.name} subfolder"
    folder = create_folder(pt.name, parent_id: parent_folder_id)
    ext  = publication_extension(pt)
    mime = publication_mime_type(pt)

    # Force VPubContext to autoload in the main thread before parallel execution;
    # Rails 4 autoloading is not thread-safe and will raise a circular dependency
    # error if multiple threads try to load the same constant simultaneously.
    VPubContext

    parallel_each(docs) do |doc|
      log "  Publishing #{pt.name}: #{doc.name}"
      content = pt.execute(doc: doc, project: project)
      upload_file("#{doc.name}#{ext}", content, mime, parent_id: folder['id'])
    rescue => e
      warn "Failed to render '#{doc.name}' with publication '#{pt.name}': #{e.message}"
    end
  end

  def publication_extension(pt)
    return '.html' if pt.output_format.blank?
    FormatConversions.filename_extension_for(pt.output_format)
  rescue FormatConversions::UnknownFormatException
    ".#{pt.output_format}"
  end

  def publication_mime_type(pt)
    case pt.output_format.to_s
    when 'fo'       then 'application/xml'
    when 'gametex'  then 'text/plain'
    else                 'text/html'
    end
  end

  # ── Drive API calls ────────────────────────────────────────────────────────

  def create_folder(name, parent_id: nil)
    metadata = { name: name, mimeType: 'application/vnd.google-apps.folder' }
    metadata[:parents] = [parent_id] if parent_id
    drive_post('/files?supportsAllDrives=true&fields=id,webViewLink', metadata.to_json, 'application/json')
  end

  def upload_file(name, content, content_type, parent_id:)
    metadata = { name: name, parents: [parent_id] }
    drive_multipart_post('/files?uploadType=multipart&supportsAllDrives=true&fields=id,webViewLink', metadata, content, content_type)
  end

  def create_doc(name, html, parent_id:)
    metadata = {
      name:     name,
      parents:  [parent_id],
      mimeType: 'application/vnd.google-apps.document'
    }
    drive_multipart_post('/files?uploadType=multipart&supportsAllDrives=true&fields=id,webViewLink', metadata, html, 'text/html')
  end

  def update_doc(file_id, name, html)
    drive_multipart_patch("/files/#{file_id}?uploadType=multipart&supportsAllDrives=true&fields=id", { name: name }, html, 'text/html')
  end

  def share_folder(folder_id, email)
    permission = { type: 'user', role: 'writer', emailAddress: email }
    drive_post("/files/#{folder_id}/permissions?supportsAllDrives=true&sendNotificationEmail=false",
               permission.to_json, 'application/json')
  end

  # ── HTTP helpers ───────────────────────────────────────────────────────────

  def drive_post(path, body, content_type)
    uri = URI("#{DRIVE_API}#{path}")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "Bearer #{@access_token}"
    req['Content-Type']  = content_type
    req.body = body
    execute(uri, req)
  end

  def drive_multipart_post(path, metadata, body, content_type)
    uri = URI("#{DRIVE_UPLOAD}#{path}")
    req = Net::HTTP::Post.new(uri)
    set_multipart(req, metadata, body, content_type)
    execute(uri, req)
  end

  def drive_multipart_patch(path, metadata, body, content_type)
    uri = URI("#{DRIVE_UPLOAD}#{path}")
    req = Net::HTTP::Patch.new(uri)
    set_multipart(req, metadata, body, content_type)
    execute(uri, req)
  end

  def set_multipart(req, metadata, body, content_type)
    req['Authorization'] = "Bearer #{@access_token}"
    req['Content-Type']  = "multipart/related; boundary=#{BOUNDARY}"
    req.body = [
      "--#{BOUNDARY}",
      "Content-Type: application/json; charset=UTF-8",
      "",
      metadata.to_json,
      "--#{BOUNDARY}",
      "Content-Type: #{content_type}; charset=UTF-8",
      "",
      body,
      "--#{BOUNDARY}--"
    ].join("\r\n")
  end

  def execute(uri, req)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    unless response.is_a?(Net::HTTPSuccess)
      raise "Drive API error #{response.code}: #{response.body}"
    end
    JSON.parse(response.body)
  end

  # ── Service account JWT auth ───────────────────────────────────────────────

  def fetch_access_token
    case @credentials['type']
    when 'authorized_user'
      fetch_access_token_from_refresh_token
    when 'service_account', nil
      fetch_access_token_from_service_account
    else
      raise "Unsupported credential type: #{@credentials['type']}"
    end
  end

  def fetch_access_token_from_refresh_token
    uri  = URI(TOKEN_URI)
    resp = Net::HTTP.post_form(uri,
      grant_type:    'refresh_token',
      client_id:     @credentials['client_id'],
      client_secret: @credentials['client_secret'],
      refresh_token: @credentials['refresh_token']
    )
    data = JSON.parse(resp.body)
    raise "Failed to get access token: #{data['error_description'] || data.inspect}" unless data['access_token']
    data['access_token']
  end

  def fetch_access_token_from_service_account
    now = Time.now.to_i
    claim = {
      iss:   @credentials['client_email'],
      scope: SCOPE,
      aud:   TOKEN_URI,
      iat:   now,
      exp:   now + 3600
    }

    uri  = URI(TOKEN_URI)
    resp = Net::HTTP.post_form(uri, grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: sign_jwt(claim))
    data = JSON.parse(resp.body)
    raise "Failed to get access token: #{data['error_description'] || data.inspect}" unless data['access_token']
    data['access_token']
  end

  def sign_jwt(payload)
    header  = base64url({ alg: 'RS256', typ: 'JWT' }.to_json)
    body    = base64url(payload.to_json)
    input   = "#{header}.#{body}"
    key     = OpenSSL::PKey::RSA.new(@credentials['private_key'])
    sig     = key.sign(OpenSSL::Digest::SHA256.new, input)
    "#{input}.#{base64url(sig)}"
  end

  def base64url(str)
    Base64.urlsafe_encode64(str, padding: false)
  end

  # ── HTML rendering ─────────────────────────────────────────────────────────

  def render_doc_html(doc, url_map)
    parts = []
    parts << "<h1>#{h doc.name}</h1>"

    attrs = doc.attrs.to_a
    unless attrs.empty?
      parts << "<h2>Attributes</h2><table>"
      attrs.each do |attr|
        parts << "<tr><td><strong>#{h attr.name}</strong></td><td>#{attr.value}</td></tr>"
      end
      parts << "</table>"
    end

    parts << "<h2>Content</h2>#{doc.content}" if doc.content.present?

    outward = doc.outward_relationships.to_a
    inward  = doc.inward_relationships.to_a
    unless (outward + inward).empty?
      parts << "<h2>Relationships</h2><ul>"
      outward.each do |rel|
        desc = rel.left_description.presence || rel.relationship_type.name
        parts << "<li>#{h doc.name} <em>#{h desc}</em> #{linked_name(rel.right, url_map)}</li>"
      end
      inward.each do |rel|
        desc = rel.right_description.presence || rel.relationship_type.name
        parts << "<li>#{h doc.name} <em>#{h desc}</em> #{linked_name(rel.left, url_map)}</li>"
      end
      parts << "</ul>"
    end

    style = "<style>p { margin-bottom: 12pt; }</style>"
    "<!DOCTYPE html><html><head><meta charset='utf-8'>#{style}</head><body>#{parts.join}</body></html>"
  end

  def linked_name(doc, url_map)
    url = url_map[doc.id]
    url ? "<a href=\"#{h url}\">#{h doc.name}</a>" : h(doc.name)
  end

  def h(str)
    CGI.escapeHTML(str.to_s)
  end

  def log(msg)
    puts msg
  end

  def warn(msg)
    log "  WARNING: #{msg}"
    @warnings_mutex.synchronize { @warnings << msg }
  end
end
