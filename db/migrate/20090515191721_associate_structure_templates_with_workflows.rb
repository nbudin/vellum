class AssociateStructureTemplatesWithWorkflows < ActiveRecord::Migration
  def self.up
    add_column :structure_templates, :workflow_id, :integer
  end

  def self.down
    remove_column :structure_templates, :workflow_id
  end
end
