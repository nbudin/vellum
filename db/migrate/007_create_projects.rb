class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :name, :string
      t.column :template_schema_id, :integer
    end
    add_column "docs", "project_id", :integer
    add_column "doc_versions", "project_id", :integer
    add_column "structures", "project_id", :integer
  end

  def self.down
    remove_column "docs", "project_id"
    remove_column "doc_versions", "project_id"
    remove_column "structures", "project_id"
    drop_table :projects
  end
end
