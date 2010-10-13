# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :get_site_settings
  
  private
  def get_site_settings
    @site_settings = SiteSettings.instance
  end
end
