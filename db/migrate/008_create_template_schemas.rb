class CreateTemplateSchemas < ActiveRecord::Migration
  def self.up
    create_table :template_schemas do |t|
      t.column :name, :string
      t.column :description, :text
    end
    add_column "templates", "template_schema_id", :integer
  end

  def self.down
    remove_column "templates", "template_schema_id"
    drop_table :template_schemas
  end
end
