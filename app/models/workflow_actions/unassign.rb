class WorkflowActions::Unassign < WorkflowAction
  def self.description
    "Assign to nobody"
  end

  def execute(structure, options={})
    status = structure.obtain_workflow_status
    status.assignee = nil
    status.save
  end
end
