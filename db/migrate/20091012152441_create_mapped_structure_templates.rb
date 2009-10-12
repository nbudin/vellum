class CreateMappedStructureTemplates < ActiveRecord::Migration
  def self.up
    create_table :mapped_structure_templates do |t|
      t.column :map_id, :integer
      t.column :structure_template_id, :integer
      t.column :color, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :mapped_structure_templates
  end
end
