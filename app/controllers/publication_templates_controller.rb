require 'format_conversions'

class PublicationTemplatesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :through => :project

  def index
    @publication_templates_by_type = @publication_templates.sort_by(&:name).group_by(&:template_type)
  end

  # GET /docs/1
  # GET /docs/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @publication_template.to_xml }
      format.json { render :json => @publication_template.to_json }
    end
  end

  def new
    @doc_templates = @project.doc_templates.all.sort_by { |t| t.name.sort_normalize }
  end

  # GET /publication_templates/1;edit
  def edit
    @doc_templates = @project.doc_templates.all.sort_by { |t| t.name.sort_normalize }
  end

  def create
    respond_to do |format|
      if @publication_template.save
        format.html { redirect_to publication_template_url(@project, @publication_template) }
        format.xml  { head :created, :location => publication_template_url(@project, @publication_template, :format => "xml" ) }
        format.json { head :created, :location => publication_template_url(@project, @publication_template, :format => "json") }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @publication_template.errors.to_xml }
        format.json { render :json => @publication_template.errors.to_json }
      end
    end
  end

  def test
    @publication_template = @project.publication_templates.find(params[:id])

    context_options = { :project => @project }
    if params[:context] && params[:context][:doc_id]
      @doc = @project.docs.find(params[:context][:doc_id])
      context_options[:doc] = @doc
    end

    begin
      @output = @publication_template.execute(context_options)
    rescue Exception => e
      @error = e
    end

    if params[:raw_preview]
      render :text => @output
    else
      @raw_preview_url = url_for(params.update(:raw_preview => true))
    end
  end

  def publish
    @publication_template = @project.publication_templates.find(params[:id])

    @attachment = (@publication_template.output_format.to_s != 'html')

    begin
      if @publication_template.doc_template
        @tempfile = Tempfile.new("vellum-publication-#{Time.now}.zip")

        @filename = @project.name
        @filename << " - #{@publication_template.doc_template.plural_name}" if @publication_template.doc_template
        @filename << ".zip"

        @filetype = "application/zip"

        Zip::OutputStream.open(@tempfile.path) do |zipfile|
          @publication_template.doc_template.docs.each do |doc|
            filename = doc.name.gsub(/[\/\\]/, "_")
            filename << FormatConversions.filename_extension_for(@publication_template.output_format)
            zipfile.put_next_entry(filename)
            zipfile.print @publication_template.execute(:project => @project, :doc => doc)
          end
        end
      else
        @tempfile = Tempfile.new("vellum-publication-#{Time.now}.#{@publication_template.output_format}")
        @tempfile.write @publication_template.execute(:project => @project)

        @filetype = FormatConversions.mime_type_for(@publication_template.output_format)
        extension = FormatConversions.filename_extension_for(@publication_template.output_format)
        @filename = "#{@project.name} - #{@publication_template.name}#{extension}"
      end

      @tempfile.flush

      send_file @tempfile.path, :type => @filetype, :disposition => (@attachment ? 'attachment' : 'inline'),
        :filename => @filename
    rescue Exception => e
      @error = e
      render :action => 'test'
    ensure
      @tempfile.close
    end
  end

  # PUT /publication_templates/1
  # PUT /publication_templates/1.xml
  def update
    respond_to do |format|
      if @publication_template.update_attributes(publication_template_params)
        format.html { redirect_to publication_template_url(@project, @publication_template) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @publication_template.errors.to_xml }
        format.json { render :json => @publication_template.errors.to_json }
      end
    end
  end

  # DELETE /publication_templates/1
  # DELETE /publication_templates/1.xml
  def destroy
    @publication_template.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private
  def layouts
    @publication_template.project.publication_templates.where(template_type: "layout").order(:name).reject { |t| t == @publication_template }
  end
  helper_method :layouts

  def publication_template_params
    params.require(:publication_template).permit(:name, :format, :content, :doc_template_id, :layout_id, :template_type)
  end
end
