class ProjectInvitationsController < ApplicationController
  load_and_authorize_resource :find_by => :token
  
  def show
    return redirect_to [:consume, @project_invitation] if person_signed_in?
    
    # We're about to sign in as an invitation, so if they're already signed in as a different invitation,
    # we need to sign that one out
    sign_out(current_project_invitation) if project_invitation_signed_in?
    
    if @project_invitation.consumed?
      return redirect_to new_person_session_url, :notice => "Please sign in to access #{@project.name}."
    end
    
    # Authenticate as the invitation so that followup pages can take action based upon it
    sign_in(@project_invitation) 
    
    # Once they do sign in or sign up, consume the invitation
    session[:person_return_to] = polymorphic_url([:consume, @project_invitation])
  end
  
  def consume
    return redirect_to @project_invitation unless person_signed_in?
    
    project = @project_invitation.project
    
    begin
      # If they're not already a member, make them one.  Otherwise, just redirect to the project.
      if project.project_memberships.where(:person_id => current_person.id).empty?
        @project_invitation.consume!(current_person)

        flash[:notice] = "Thank you!  Welcome to #{project.name}."
      end

      redirect_to after_consume_invitation_path_for(@project_invitation)
    rescue Exception => e
      flash[:alert] = e.message
      logger.warn "Error consuming project invitation #{@project_invitation.token}: #{e.message}"
      redirect_to @project_invitation
    end
  end
  
  def resend
    ProjectInvitationMailer.invitation_created(@project_invitation).deliver
    flash[:notice] = "Invitation email sent again to #{@project_invitation.email}."
    redirect_to :back
  end
  
  protected
  def after_consume_invitation_path_for(project_invitation)
    url_for project_invitation.project
  end
end
