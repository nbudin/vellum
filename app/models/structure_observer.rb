class StructureObserver < ActiveRecord::Observer
  def before_save(structure)
    if structure.assignee_id_changed? and structure.assignee
      AssignmentMailer.deliver_assigned_to_you(structure, structure.assignee)
    end
  end
end
