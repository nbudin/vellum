class CreateWorkflowStructureStates < ActiveRecord::Migration
  def self.up
    create_table :workflow_structure_states do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_structure_states
  end
end
