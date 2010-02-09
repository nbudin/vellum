class StructureTemplatesController < ApplicationController
  rest_edit_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  
  # GET /structure_templates
  # GET /structure_templates.xml
  def index
    @structure_templates = @project.structure_templates.all(:order => "name")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @structure_templates.to_xml }
      format.json { render :json => @structure_templates.to_json }
    end
  end

  # GET /structure_templates/1
  # GET /structure_templates/1.xml
  def show
    @doc_template = StructureTemplate.find(params[:id])
    @relationship_types = @doc_template.outward_relationship_types + @doc_template.inward_relationship_types

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @doc_template.to_xml(:include => [:attrs]) }
      format.json  { render :json => @doc_template.to_json }
    end
  end

  # POST /structure_templates
  # POST /structure_templates.xml
  def create
    @doc_template = StructureTemplate.new(params[:doc_template])
    @doc_template.project = @project

    respond_to do |format|
      if @doc_template.save
        format.html { redirect_to doc_template_url(@project, @doc_template) }
        format.xml  { head :created, :location => doc_template_url(@project, @doc_template) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @doc_template.errors.to_xml }
      end
    end
  end

  # PUT /structure_templates/1
  # PUT /structure_templates/1.xml
  def update
    @doc_template = StructureTemplate.find(params[:id])
    update_params = params[:doc_template].dup
    update_params.delete(:attrs)

    respond_to do |format|
      if @doc_template.update_attributes(update_params)
        format.html { redirect_to doc_template_url(@project, @doc_template) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @doc_template.errors.to_xml }
        format.json { render :json => @doc_template.errors.to_json }
      end
    end
  end

  # DELETE /structure_templates/1
  # DELETE /structure_templates/1.xml
  def destroy
    @doc_template = StructureTemplate.find(params[:id])
    @doc_template.destroy

    respond_to do |format|
      format.html { redirect_to structure_templates_url(@project) }
      format.xml  { head :ok }
    end
  end
  
  def get_project
    @project = Project.find(params[:project_id])
  end
end
