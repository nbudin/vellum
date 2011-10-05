class ApplicationController < ActionController::Base
  before_filter :get_site_settings
  protect_from_forgery
  
  def current_ability
    Ability.new(current_person)
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:error] = exception.message
        redirect_to root_url
      end
      
      format.json { render :json => exception.message.to_json, :status => :forbidden }
      format.xml  { render :xml => "<access-denied>#{exception.message}</access-denied>", :status => :forbidden }
      format.all  { render :text => exception.message, :status => :forbidden }
    end
  end
  
  private
  def get_site_settings
    @site_settings = SiteSettings.instance
  end
end
