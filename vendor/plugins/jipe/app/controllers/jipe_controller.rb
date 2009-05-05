class JipeController < ApplicationController
  unloadable
  layout nil
  
  def jester
    respond_to do |format|
      format.js {}
    end
  end
  
  def jipe
    respond_to do |format|
      format.js {}
    end
  end
end
