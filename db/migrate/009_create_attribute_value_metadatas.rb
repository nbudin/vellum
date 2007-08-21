class CreateAttributeValueMetadatas < ActiveRecord::Migration
  def self.up
    create_table :attribute_value_metadatas do |t|
      t.column :attribute_id, :integer
      t.column :structure_id, :integer
      t.column :value_id, :integer
      t.column :value_type, :integer
    end
  end

  def self.down
    drop_table :attribute_value_metadatas
  end
end
