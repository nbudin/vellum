class WorkflowAction < ActiveRecord::Base
  belongs_to :workflow_transition
  self.store_full_sti_class = true

  validates_uniqueness_of :type, :scope => "workflow_transition_id"

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
  
  def required_options
    []
  end

  def execute(structure, options={})
  end
end

WorkflowAction.register_action_type WorkflowActions::Reassign
WorkflowAction.register_action_type WorkflowActions::Unassign
