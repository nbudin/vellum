class CreateAttributes < ActiveRecord::Migration
  def self.up
    create_table :attributes do |t|
      t.column :name, :string
      t.column :attribute_configuration_id, :integer
      t.column :attribute_configuration_type, :string
    end
  end

  def self.down
    drop_table :attributes
  end
end
