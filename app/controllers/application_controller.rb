# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :get_site_settings
  
  def current_ability
    Ability.new(current_person)
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  
  private
  def get_site_settings
    @site_settings = SiteSettings.instance
  end
end
