class CreateAttrValueMetadatas < ActiveRecord::Migration
  def self.up
    create_table :attr_value_metadatas do |t|
      t.column :attr_id, :integer
      t.column :structure_id, :integer
      t.column :value_id, :integer
      t.column :value_type, :integer
    end
  end

  def self.down
    drop_table :attr_value_metadatas
  end
end
