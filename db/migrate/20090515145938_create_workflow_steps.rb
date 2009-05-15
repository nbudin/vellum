class CreateWorkflowSteps < ActiveRecord::Migration
  def self.up
    create_table :workflow_steps do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_steps
  end
end
