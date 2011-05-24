class DocObserver < ActiveRecord::Observer
  def before_save(doc)
    if doc.assignee_id_changed? and doc.assignee
      AssignmentMailer.assigned_to_you(doc, doc.assignee).deliver
    end
  end
end
