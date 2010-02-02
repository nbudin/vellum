class StylesheetsController < ApplicationController
  layout nil
  caches_page :application, :editors, :jumpbox, :structures
  
  def application
  end
  
  def editors
  end
  
  def jumpbox
  end
  
  def structures
  end
end
