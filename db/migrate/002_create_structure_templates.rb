class CreateStructureTemplates < ActiveRecord::Migration
  def self.up
    create_table :structure_templates do |t|
      t.column :name, :string
      t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :structure_templates
  end
end
