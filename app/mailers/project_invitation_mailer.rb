class ProjectInvitationMailer < ActionMailer::Base

  def invitation_created(project_invitation)
    @project_invitation = project_invitation
    @project = @project_invitation.project
    @site_settings = SiteSettings.instance

    mail(:subject => "[#{@project.name}] You've been invited to #{@project.name} on Vellum",
         :from => @project_invitation.inviter.try(:email) || @site_settings.site_email,
         :to => @project_invitation.email)
  end

end