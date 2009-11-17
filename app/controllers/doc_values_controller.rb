class DocValuesController < ApplicationController
  before_filter :get_objects
  
  def show
  end
  
  private
  def get_objects
    @project = Project.find(params[:project_id])
    @structure = @project.structures.find(params[:structure_id])
    @doc_value = DocValue.find(params[:id], :conditions => ["structure_id = ?", @structure.id],
                               :joins => :attr_value_metadata)
  end
end
