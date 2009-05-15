class CreateWorkflowWorkflows < ActiveRecord::Migration
  def self.up
    create_table :workflow_workflows do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_workflows
  end
end
