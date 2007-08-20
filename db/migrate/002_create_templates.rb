class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.column :name, :string
      t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :templates
  end
end
