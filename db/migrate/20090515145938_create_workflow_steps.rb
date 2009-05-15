class CreateWorkflowSteps < ActiveRecord::Migration
  def self.up
    create_table :workflow_steps do |t|
      t.string :name
      t.integer :position
      t.integer :workflow_id
      t.timestamps
    end

    add_index :workflow_steps, :workflow_id
  end

  def self.down
    drop_table :workflow_steps
  end
end
