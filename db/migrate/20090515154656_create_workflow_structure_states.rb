class CreateWorkflowStructureStates < ActiveRecord::Migration
  def self.up
    create_table :workflow_structure_states do |t|
      t.integer :structure_id
      t.integer :workflow_step_id
      t.integer :assignee_id
      t.integer :transitioner_id
      t.timestamps
    end
    add_index :workflow_structure_states, :structure_id
    add_index :workflow_structure_states, :workflow_step_id
    add_index :workflow_structure_states, :assignee_id

    WorkflowStructureState.create_versioned_table
  end

  def self.down
    WorkflowStructureState.drop_versioned_table
    drop_table :workflow_structure_states
  end
end
