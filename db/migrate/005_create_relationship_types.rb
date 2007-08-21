class CreateRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :relationship_types do |t|
      t.column :name, :string
      t.column :left_description, :string
      t.column :right_description, :string
      t.column :left_type, :string
      t.column :right_type, :string
      t.column :template_schema_id, :integer
    end
  end

  def self.down
    drop_table :relationship_types
  end
end
