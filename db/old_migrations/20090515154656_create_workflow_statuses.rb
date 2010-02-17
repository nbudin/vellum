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

    create_table :workflow_status_versions do |t|
      t.integer :structure_id
      t.integer :workflow_step_id
      t.integer :assignee_id
      t.integer :transitioner_id
      t.integer :workflow_status_id
      t.integer :version
      t.timestamps      
    end
  end

  def self.down
    drop_table :workflow_status_versions
    drop_table :workflow_statuses
  end
end
