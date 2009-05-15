class CreateWorkflowTransitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_transitions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_transitions
  end
end
