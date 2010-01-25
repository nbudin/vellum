class AssignmentMailer < ActionMailer::Base
  

  def assigned_to_you(structure, assignee = nil, sent_at = Time.now)
    assignee ||= structure.assignee

    @site_settings = SiteSettings.instance

    subject    "[#{structure.project ? structure.project.name : "Vellum"}] #{structure.name} has been assigned to you"
    from       @site_settings.site_email
    recipients assignee.primary_email_address
    sent_on    sent_at
    
    body       :structure => structure, :assignee => assignee
  end

end
