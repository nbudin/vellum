class CreateWorkflowTransitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_transitions do |t|
      t.string :name
      t.integer :from_id
      t.integer :to_id
      t.timestamps
    end
    
    add_index :workflow_transitions, :from_id
  end

  def self.down
    drop_table :workflow_transitions
  end
end
