class DocVersionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :doc, through: :project
  load_and_authorize_resource through: :doc, through_association: 'versions', class: Doc::Version
  
  def show
  end
end
