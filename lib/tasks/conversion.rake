namespace :convert do
  task :attr_to_doc_content => :environment do
    %w{PROJECT_ID DOC_TEMPLATE_ID ATTR_NAME}.each do |v|
      unless ENV[v]
        raise "#{v} must be specified"
      end
    end
    
    project = Project.find(ENV["PROJECT_ID"])
    doc_template = project.doc_templates.find(ENV["DOC_TEMPLATE_ID"])

    puts "Will convert all #{ENV["ATTR_NAME"].pluralize} on #{doc_template.name.pluralize} to doc content"
    
    Doc.transaction do
      project.docs.all(:conditions => { :doc_template_id => doc_template.id }).each do |doc|
        attr_value = doc.attrs[ENV["ATTR_NAME"]].value
        if doc.content.blank?
          doc.content = attr_value
          doc.attrs.delete(ENV["ATTR_NAME"])
          doc.save!
        elsif doc.content != attr_value
          raise "#{doc.name} already has content saved; aborting!"
        end
      end
    end

    dta = doc_template.doc_template_attrs.find_by_name(ENV["ATTR_NAME"])
    unless dta.nil?
      dta.destroy
    end
  end
end      
