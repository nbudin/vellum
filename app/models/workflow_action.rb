class WorkflowAction < ActiveRecord::Base
  belongs_to :workflow_transition
  self.store_full_sti_class = true

  def self.description
    "Do nothing"
  end

  @@action_types = []
  def self.register_action_type(klass)
    @@action_types.push(klass)
  end

  def self.action_types
    @@action_types
  end

  def execute(structure)
  end
end

WorkflowAction.register_action_type WorkflowActions::Reassign
WorkflowAction.register_action_type WorkflowActions::Unassign
