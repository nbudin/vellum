class GridController < ApplicationController
  before_filter :get_project_and_doc_template, :get_content
  helper :docs

  def show
    
  end

  def edit

  end

  private
  def get_project_and_doc_template
    @project = Project.find(params[:project_id])
    @doc_template = @project.doc_templates.find(params[:doc_template_id], :include => :doc_template_attrs)
  end

  def get_content
    @docs = @doc_template.docs
    @doc_template_attrs = @doc_template.doc_template_attrs
  end
end
