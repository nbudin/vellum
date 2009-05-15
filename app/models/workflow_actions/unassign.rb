class WorkflowActions::Unassign < WorkflowAction
  def self.description
    "Assign to nobody"
  end

  def execute(structure)
    status = structure.status
    status.assignee = nil
    status.save
  end
end
