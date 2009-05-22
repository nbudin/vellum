class WorkflowTransition < ActiveRecord::Base
  belongs_to :from, :class_name => "WorkflowStep"
  belongs_to :to, :class_name => "WorkflowStep"
  has_many :workflow_actions

  class WorkflowException < Exception
  end

  def execute(structure, options={})
    status = structure.workflow_status
    if not status.workflow_step == from
      raise WorkflowException.new("This is not a valid transition for #{structure.name}, because it is in the #{status.workflow_step.name} step.")
    end
    status.workflow_step = to
    status.transitioner = options[:transitioner]
    status.save
    workflow_actions.each do |action|
      options[action.id] ||= {}
      action.execute(structure, options[action.id.to_s].update(:transition => self))
    end
  end
  
  def required_options
    reqs = {}
    workflow_actions.each do |action|
      reqs[action] = action.required_options
    end
    return reqs
  end

  private
  def check_same_workflow
    if from and to
      if not from.workflow == to.workflow
        errors.add_to_base "This transition goes from #{from.workflow.name} to #{to.workflow.name}."
      end
    end
  end
end
