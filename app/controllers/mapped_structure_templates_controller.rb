class MappedStructureTemplatesController < ApplicationController
  perm_options = { :class_name => "Project", :id_param => "project_id" }
  rest_permissions perm_options
  require_permission "edit", {:only => [:sort]}.update(perm_options)
  before_filter :get_project_and_map

  # POST /mapped_structure_templates
  # POST /mapped_structure_templates.xml
  def create
    @mapped_structure_template = @map.mapped_structure_templates.new(params[:mapped_structure_template])

    respond_to do |format|
      if @mapped_structure_template.save
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_structure_template, :status => :created, :location => @mapped_structure_template }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_structure_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mapped_structure_templates/1
  # PUT /mapped_structure_templates/1.xml
  def update
    @mapped_structure_template = @map.mapped_structure_templates.find(params[:id])

    respond_to do |format|
      if @mapped_structure_template.update_attributes(params[:mapped_structure_template])
        format.html { redirect_to :back }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_structure_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mapped_structure_templates/1
  # DELETE /mapped_structure_templates/1.xml
  def destroy
    @mapped_structure_template = MappedStructureTemplate.find(params[:id])
    @mapped_structure_template.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_project_and_map
    @project = Project.find params[:project_id]
    @map = Map.find params[:map_id]
  end
end