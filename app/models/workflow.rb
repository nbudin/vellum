class Workflow < ActiveRecord::Base
  acts_as_permissioned

  has_many :workflow_steps, :order => :position, :include => [:entering_transitions, :leaving_transitions]
  has_many :structure_templates

  def start_step
    workflow_steps.first
  end
end
