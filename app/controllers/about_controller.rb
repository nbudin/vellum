class AboutController < ApplicationController
  before_filter :check_admin, :only => ["edit_settings", "update_settings"]
  
  def index
    redirect_to projects_url
  end
  
  def edit_settings
  end
  
  def update_settings
    if @site_settings.update_attributes(params[:site_settings])
      redirect_to :action => "index"
    else
      flash[:error_messages] = @site_settings.errors.messages
      render :action => "edit_settings"
    end
  end
  
  private
  def check_admin
    unless SiteSettings.instance.is_admin?(logged_in_person)
      redirect_to :action => "index"
    end
  end
end
