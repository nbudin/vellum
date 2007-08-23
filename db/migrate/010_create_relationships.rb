class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.column :relationship_type_id, :integer
      t.column :left_id, :integer
      t.column :right_id, :integer
    end
  end

  def self.down
    drop_table :relationships
  end
end
