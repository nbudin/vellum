class CreateWorkflowActions < ActiveRecord::Migration
  def self.up
    create_table :workflow_actions do |t|
      t.integer :workflow_transition_id
      t.string :type
      t.integer :person_id
      t.timestamps
    end
    add_index :workflow_actions, :workflow_transition_id
  end

  def self.down
    drop_table :workflow_actions
  end
end
