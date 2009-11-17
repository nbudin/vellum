class StructuresController < ApplicationController
  perm_options = { :class_name => "Project", :id_param => "project_id" }
  rest_permissions perm_options
  require_permission "edit", {:only => [:sort]}.update(perm_options)
  before_filter :get_project
  
  # GET /structures
  # GET /structures.xml
  def index
    conds = {:project_id => @project.id}
    if params[:template_id]
      conds[:structure_template_id] = @project.template_schema.structure_templates.find(params[:template_id]).id
    end
    @structures = Structure.find(:all, :conditions => conds, :include => [:attr_value_metadatas, :attrs]).sort_by {|s| s.name.sort_normalize }

    respond_to do |format|
      format.xml  { render :xml => @structures.to_xml(:methods => [:name]) }
      format.json { 
        # We have to do this to work around the json gem overriding to_json
        render :json => ActiveSupport::JSON.encode(@structures, :methods => [:name]) 
      }
    end
  end

  # GET /structures/1
  # GET /structures/1.xml
  def show
    @structure = @project.structures.find(params[:id], :include =>
        [:structure_template, :attr_value_metadatas, :inward_relationships, :outward_relationships])
    @relationships = @structure.relationships.sort_by do |rel|
      other = rel.other(@structure)
      "#{rel.relationship_type.description_for(@structure)} #{other.name.sort_normalize}"
    end
    @relationship_types = @structure.structure_template.relationship_types.sort_by {|t| t.name.sort_normalize}
    if @structure.structure_template.workflow
      @workflow_status = @structure.obtain_workflow_status
    end
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure.to_xml }
      format.json { render :json => @structure.to_json }
    end
  end

  # GET /structures/new
  def new
    @structure = @project.structures.new
    @structure.structure_template = StructureTemplate.find(params[:template_id])
  end

  # GET /structures/1;edit
  def edit
    @structure = @project.structures.find(params[:id])
  end

  # POST /structures
  # POST /structures.xml
  def create
    # we need to set up the template before we can set the attrs
    @structure_template = @project.template_schema.structure_templates.find(params[:template_id])
    @structure = @project.structures.new(:structure_template => @structure_template)
    @structure.attributes = params[:structure]

    respond_to do |format|
      if @structure.save
        format.html { redirect_to structure_url(@project, @structure) }
        format.xml  { head :created, :location => structure_url(@project, @structure, :format => "xml" ) }
        format.json { head :created, :location => structure_url(@project, @structure, :format => "json") }
      else
        flash[:error_messages] = @structure.errors.full_messages
        format.html { render :action => "new" }
        format.xml  { render :xml => @structure.errors.to_xml }
        format.json { render :json => @structure.errors.to_json }
      end
    end
  end

  # PUT /structures/1
  # PUT /structures/1.xml
  def update
    @structure = @project.structures.find(params[:id])
    
    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        format.html { redirect_to structure_url(@project, @structure) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @structure.errors.to_xml }
        format.json { render :json => @structure.errors.to_json }
      end
    end
  end

  # DELETE /structures/1
  # DELETE /structures/1.xml
  def destroy
    @structure = @project.structures.find(params[:id])
    @structure.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def transition
    @structure = @project.structures.find(params[:id])
    @status = @structure.obtain_workflow_status
    @transition = @status.workflow_step.leaving_transitions.find(params[:workflow_transition_id])
    @required_options = @transition.required_options
    
    params[:options] ||= {}
    ready_to_go = true
    @required_options.each do |action, reqs|
      logger.debug "Checking required options for action #{action.id}"
      logger.debug "Required options are #{reqs.join(", ")}"
      params[:options][action.id.to_s] ||= {}
      unless reqs.none? { |opt| params[:options][action.id.to_s][opt].blank? }
        ready_to_go = false
      end
    end
    
    if ready_to_go
      @transition.execute(@structure, params[:options])
      
      respond_to do |format|
        format.html { redirect_to structure_url(@project, @structure) }
        format.xml  { head :ok }
        format.json { head :ok }
      end
    end
  end
  
  def sort
    params.each do |k, v|
      if k =~ /structures_(\d+)/
        tmpl_id = $1
        @structure_template = @project.template_schema.structure_templates.find(tmpl_id)
        @structures = @project.structures.select { |s| s.structure_template == @structure_template }
        @structures.each do |structure|
          structure.position = v.index(structure.id.to_s) + 1
          structure.save!
        end
      end
    end
    head :ok
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
  end
end
