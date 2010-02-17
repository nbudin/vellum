class AddStartStepToWorkflows < ActiveRecord::Migration
  def self.up
    add_column :workflows, :start_step_id, :integer
  end

  def self.down
    remove_column :workflows, :start_step_id
  end
end
