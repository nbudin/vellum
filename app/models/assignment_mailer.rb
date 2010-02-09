class AssignmentMailer < ActionMailer::Base
  

  def assigned_to_you(doc, assignee = nil, sent_at = Time.now)
    assignee ||= doc.assignee

    @site_settings = SiteSettings.instance

    subject    "[#{doc.project ? doc.project.name : "Vellum"}] #{doc.name} has been assigned to you"
    from       @site_settings.site_email
    recipients assignee.primary_email_address
    sent_on    sent_at
    
    body       :doc => doc, :assignee => assignee
  end

end
