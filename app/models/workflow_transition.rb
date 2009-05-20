class WorkflowTransition < ActiveRecord::Base
  belongs_to :from, :class_name => "WorkflowStep"
  belongs_to :to, :class_name => "WorkflowStep"
  has_many :workflow_actions

  class WorkflowException < Exception
  end

  def execute(structure, person=nil)
    status = structure.workflow_status
    if not status.workflow_step == from
      raise WorkflowException.new("This is not a valid transition for #{structure.name}, because it is in the #{status.workflow_step.name} step.")
    end
    status.workflow_step = to
    status.transitioner = person
    status.save
    workflow_actions.each do |action|
      action.execute(structure, self)
    end
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
