class WorkflowStep < ActiveRecord::Base
  acts_as_list :scope => :workflow_id
  belongs_to :workflow
  has_many :workflow_statuses
  has_many :structures, :through => :workflow_statuses
  has_many :entering_transitions, :class_name => "WorkflowTransition", :foreign_key => :to_id
  has_many :leaving_transitions, :class_name => "WorkflowTransition", :foreign_key => :from_id
  has_many :source_steps, :through => :entering_transitions, :class_name => "WorkflowStep"
  has_many :destination_steps, :through => :leaving_transitions, :class_name => "WorkflowStep"
end
