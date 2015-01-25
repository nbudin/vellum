class AddTemplateTypeToPublicationTemplates < ActiveRecord::Migration
  class PublicationTemplate < ActiveRecord::Base
    self.table_name = "publication_templates"
  end
  
  def up
    change_table :publication_templates do |t|
      t.string :template_type, default: "standalone"
    end
    
    AddTemplateTypeToPublicationTemplates::PublicationTemplate.where("doc_template_id is not null").update_all(template_type: "doc")
    AddTemplateTypeToPublicationTemplates::PublicationTemplate.where("content like '%<v:yield%'").update_all(template_type: "layout")
  end
  
  def down
    remove_column :publication_templates, :template_type
  end
end
