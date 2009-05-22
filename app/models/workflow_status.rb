class WorkflowStatus < ActiveRecord::Base
  acts_as_versioned

  belongs_to :structure
  belongs_to :workflow_step
  belongs_to :assignee, :class_name => "Person"
  belongs_to :transitioner, :class_name => "Person"
  
  def assignee_name
    if assignee
      assignee.name
    else
      "Unassigned"
    end
  end
end
