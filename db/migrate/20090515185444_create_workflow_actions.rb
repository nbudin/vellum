class CreateWorkflowActions < ActiveRecord::Migration
  def self.up
    create_table :workflow_actions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_actions
  end
end
