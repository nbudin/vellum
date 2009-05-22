class ReplacePersonIdWithWhom < ActiveRecord::Migration
  def self.up
    remove_column :workflow_actions, :person_id
    add_column :workflow_actions, :whom, :string
  end

  def self.down
    remove_column :workflow_actions, :whom
    add_column :workflow_actions, :person_id, :integer
  end
end
