class StructureTemplatesController < ApplicationController
  rest_edit_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  
  # GET /structure_templates
  # GET /structure_templates.xml
  def index
    @structure_templates = @project.structure_templates

    respond_to do |format|
      format.xml  { render :xml => @structure_templates.to_xml }
      format.json { render :json => @structure_templates.to_json }
    end
  end

  # GET /structure_templates/1
  # GET /structure_templates/1.xml
  def show
    @structure_template = StructureTemplate.find(params[:id])
    @relationship_types = @structure_template.outward_relationship_types + @structure_template.inward_relationship_types

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure_template.to_xml(:include => [:attrs]) }
      format.json  { render :json => @structure_template.to_json }
    end
  end

  # POST /structure_templates
  # POST /structure_templates.xml
  def create
    @structure_template = StructureTemplate.new(params[:structure_template])
    @structure_template.project = @project

    respond_to do |format|
      if @structure_template.save
        format.html { redirect_to structure_template_url(@project, @structure_template) }
        format.xml  { head :created, :location => structure_template_url(@project, @structure_template) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @structure_template.errors.to_xml }
      end
    end
  end

  # PUT /structure_templates/1
  # PUT /structure_templates/1.xml
  def update
    @structure_template = StructureTemplate.find(params[:id])
    update_params = params[:structure_template].dup
    update_params.delete(:attrs)

    respond_to do |format|
      if @structure_template.update_attributes(update_params)
        format.html { redirect_to structure_template_url(@project, @structure_template) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @structure_template.errors.to_xml }
        format.json { render :json => @structure_template.errors.to_json }
      end
    end
  end

  # DELETE /structure_templates/1
  # DELETE /structure_templates/1.xml
  def destroy
    @structure_template = StructureTemplate.find(params[:id])
    @structure_template.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
    end
  end
  
  def get_project
    @project = Project.find(params[:project_id])
  end
end
