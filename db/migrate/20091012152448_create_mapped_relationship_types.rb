class CreateMappedRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :mapped_relationship_types do |t|
      t.column :map_id, :integer
      t.column :relationship_type_id, :integer
      t.column :color, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :mapped_relationship_types
  end
end
