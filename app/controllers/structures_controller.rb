class StructuresController < ApplicationController
  rest_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_buttons1 => 'formatselect, bold, italic, underline, strikethrough, separator, undo, redo',
    :theme_advanced_buttons2 => '',
    :theme_advanced_buttons3 => '',
    :theme_advanced_toolbar_location => 'top',
    :theme_advanced_toolbar_align => 'left',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :theme_advanced_statusbar_location => 'bottom',
    :content_css => '/stylesheets/document.css',
    :width => "700"
  }
  
  # GET /structures
  # GET /structures.xml
  def index
    conds = {:project_id => @project.id}
    if params[:template_id]
      conds[:structure_template_id] = @project.template_schema.structure_templates.find(params[:template_id]).id
    end
    @structures = Structure.find(:all, :conditions => conds).sort_by {|s| s.name.sort_normalize }

    respond_to do |format|
      format.xml  { render :xml => @structures.to_xml(:methods => [:name]) }
      format.json { render :json => @structures.to_json(:methods => [:name]) }
    end
  end

  # GET /structures/1
  # GET /structures/1.xml
  def show
    @structure = Structure.find(params[:id])
    check_forged_url
    @relationships = @structure.relationships.sort_by do |rel|
      other = rel.other(@structure)
      "#{rel.relationship_type.description_for(@structure)} #{other.name.sort_normalize}"
    end
    @relationship_types = @structure.structure_template.relationship_types.sort_by {|t| t.name.sort_normalize}
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure.to_xml }
      format.json { render :json => @structure.to_json }
    end
  end

  # GET /structures/new
  def new
    @structure = Structure.new
    @structure.structure_template = StructureTemplate.find(params[:template_id])
  end

  # GET /structures/1;edit
  def edit
    @structure = Structure.find(params[:id])
    check_forged_url
  end

  # POST /structures
  # POST /structures.xml
  def create
    @structure = Structure.new(params[:structure])
    @structure.structure_template = StructureTemplate.find(params[:template_id])
    @structure.project = @project
    
    struct_ok = @structure.save
    @attr_errors = {}
    
    if struct_ok and params[:attr_value]
      params[:attr_value].each do |id, value|
        if not value.blank?
          val = @structure.attr_value(Attr.find(id))
          val.update_attributes(value)
          attr_ok = val.save
          if not attr_ok
            @attr_errors[id] = val.errors
          end
        end
      end
    end
    
    if @attr_errors.length > 0
      @structure.destroy
    end

    respond_to do |format|
      if (struct_ok) and (@attr_errors.length == 0)
        format.html { redirect_to structure_url(@project, @structure) }
        format.xml  { head :created, :location => structure_url(@project, @structure, :format => "xml" ) }
        format.json { head :created, :location => structure_url(@project, @structure, :format => "json") }
      else
        flash[:error_messages] = @structure.errors.full_messages + @attr_errors.values.collect { |errs| errs.full_messages }.flatten
        format.html { render :action => "new" }
        format.xml  { render :xml => @structure.errors.to_xml }
        format.json { render :json => @structure.errors.to_json }
      end
    end
  end

  # PUT /structures/1
  # PUT /structures/1.xml
  def update
    @structure = Structure.find(params[:id])
    check_forged_url
    
    flash[:error_messages] = []
    flash[:error_attrs] = []
    
    if params[:attr_value]
      @structure.attr_values.each do |v|
        logger.debug "Checking for update on attr_value #{v.id}"
        if params[:attr_value].has_key?(v.id.to_s)
          logger.debug "Updating attr_value #{v.id}"
          params[:attr_value][v.id.to_s].each do |key, value|
            if v.respond_to? key
              v.send("#{key}=", value)
              if v.kind_of? DocValue and key == "doc_content"
                v.doc.author = logged_in_person
                v.doc.save
              end
            else
              logger.debug("Warning, user is trying to set nonexistent attribute #{key} on #{v}")
            end
          end
          if not v.save
            v.errors.each do |err|
              flash[:error_messages].push("#{err[0]} #{err[1]}")
            end
          end
        end
      end
    end

    respond_to do |format|
      if flash[:error_messages].length == 0
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
    @structure = Structure.find(params[:id])
    check_forged_url
    @structure.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
  end
  
  def check_forged_url
    if not @structure.project == @project
      flash[:error_messages] = "That structure does not belong to that project."
      redirect_to project_url(@project)
    end
  end
end
