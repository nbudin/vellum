class CreateAttrs < ActiveRecord::Migration
  def self.up
    create_table :attrs do |t|
      t.column :name, :string
      t.column :template_id, :integer
      t.column :attr_configuration_id, :integer
      t.column :attr_configuration_type, :string
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :attrs
  end
end
