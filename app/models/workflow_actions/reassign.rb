class WorkflowActions::Reassign < WorkflowAction
  def self.description
    "Assign"
  end
  
  belongs_to :person

  def execute(structure)
    status = structure.status
    status.assignee = person
    status.save
  end
end
