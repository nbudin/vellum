class Workflow < ActiveRecord::Base
  has_many :workflow_steps, :include => [:entering_transitions, :leaving_transitions]
  has_many :structure_templates
  belongs_to :start_step, :class_name => "WorkflowStep"

  validate :check_start_step_in_workflow

  private
  def check_start_step_in_workflow
    if start_step
      unless workflow_steps.include? start_step
        errors.add("start_step", "is not part of this workflow")
      end
    end
  end
end
