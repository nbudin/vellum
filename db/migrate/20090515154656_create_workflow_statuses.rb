class CreateWorkflowStatuses < ActiveRecord::Migration
  def self.up
    create_table :workflow_statuses do |t|
      t.integer :structure_id
      t.integer :workflow_step_id
      t.integer :assignee_id
      t.integer :transitioner_id
      t.timestamps
    end
    add_index :workflow_statuses, :structure_id
    add_index :workflow_statuses, :workflow_step_id
    add_index :workflow_statuses, :assignee_id

    WorkflowStatus.create_versioned_table
  end

  def self.down
    WorkflowStatus.drop_versioned_table
    drop_table :workflow_statuses
  end
end
