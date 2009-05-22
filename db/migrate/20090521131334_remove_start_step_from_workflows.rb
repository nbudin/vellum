class RemoveStartStepFromWorkflows < ActiveRecord::Migration
  def self.up
    remove_column :workflows, :start_step_id
  end

  def self.down
    add_column :workflows, :start_step_id, :integer
  end
end
