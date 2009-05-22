class WorkflowActions::Reassign < WorkflowAction
  def self.description
    "Assign"
  end
  
  def required_options
    if whom == "prompt"
      [:person_id]
    else
      []
    end
  end

  def whom
    read_attribute(:whom) || "prompt"
  end
  
  def execute(structure, options={})
    status = structure.obtain_workflow_status
    if whom == "prompt" and options[:person_id]
      status.assignee = Person.find(options[:person_id])
    end
    status.save
  end
end
