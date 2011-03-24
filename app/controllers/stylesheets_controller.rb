class StylesheetsController < ApplicationController
  layout nil
  caches_page :site_theme
  
  def site_theme
  end
end
