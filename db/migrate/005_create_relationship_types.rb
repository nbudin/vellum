class CreateRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :relationship_types do |t|
      t.column :name, :string
      t.column :left_description, :string
      t.column :right_description, :string
      t.column :left_type, :string
      t.column :right_type, :string
    end
    create_table :relationship_types_templates, :id => false do |t|
      t.column :relationship_type_id, :integer
      t.column :template_id, :integer
    end
  end

  def self.down
    drop_table :relationship_types
  end
end
