class AddDocTemplateIdToPublicationTemplates < ActiveRecord::Migration
  def self.up
    add_column :publication_templates, :doc_template_id, :integer
  end

  def self.down
    remove_column :publication_templates, :doc_template_id
  end
end
