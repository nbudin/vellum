class AssignmentMailer < ActionMailer::Base

  def assigned_to_you(doc, assignee = nil, sent_at = Time.now)
    @doc = doc
    @assignee = assignee || @doc.assignee
    @site_settings = SiteSettings.instance

    mail(:subject => "[#{@doc.project ? @doc.project.name : "Vellum"}] #{@doc.name} has been assigned to you",
         :from => @site_settings.site_email,
         :recipients => @assignee.email,
         :date => sent_at)
  end

end
