class AboutController < ApplicationController
  before_filter :check_admin, :only => ["edit_settings", "update_settings"]

  def index
    redirect_to projects_url
  end

  def edit_settings
  end

  def update_settings
    if @site_settings.update_attributes(site_settings_params)
      redirect_to :action => "index"
    else
      render :action => "edit_settings"
    end
  end

  private
  def check_admin
    authorize! :edit, SiteSettings.instance
  end

  def site_settings_params
    params.require(:site_settings).permit(:site_name, :site_color, :site_email, :welcome_html)
  end
end
