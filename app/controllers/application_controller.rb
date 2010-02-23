# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_buttons1 => 'formatselect, bold, italic, underline, strikethrough, |, bullist, numlist, outdent, indent, |, undo, redo',
    :theme_advanced_buttons2 => '',
    :theme_advanced_buttons3 => '',
    :theme_advanced_toolbar_location => 'top',
    :theme_advanced_toolbar_align => 'left',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :theme_advanced_statusbar_location => 'bottom',
    :content_css => '/stylesheets/document.css',
    #:width => "500",
    :height => "250"
  }
  
  before_filter :get_site_settings
  
  private
  def get_site_settings
    @site_settings = SiteSettings.instance
  end
end
