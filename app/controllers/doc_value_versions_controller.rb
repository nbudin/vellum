class DocValueVersionsController < ApplicationController
  before_filter :get_objects
  
  def show
  end
  
  private
  def get_objects
    @project = Project.find(params[:project_id])
    @structure = @project.structures.find(params[:structure_id])
    @doc_value = DocValue.find(params[:doc_value_id],
                               :conditions => ["structure_id = ?", @structure.id],
                               :joins => :attr_value_metadata)
    @version = @doc_value.doc.versions.find_by_version(params[:id])
  end
end
