class CreatePublicationTemplates < ActiveRecord::Migration
  def self.up
    create_table :publication_templates do |t|
      t.integer :template_schema_id
      t.string :name
      t.string :format
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :publication_templates
  end
end
