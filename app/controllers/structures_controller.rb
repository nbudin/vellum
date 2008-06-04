class StructuresController < ApplicationController
  rest_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  
  # GET /structures
  # GET /structures.xml
  def index
    @structures = Structure.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @structures.to_xml }
    end
  end

  # GET /structures/1
  # GET /structures/1.xml
  def show
    @structure = Structure.find(params[:id])
    check_forged_url

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure.to_xml }
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
    
    if struct_ok
      params[:attrs].each do |id, value|
        val = @structure.attr_value(Attr.find(id))
        val.value = value
        attr_ok = val.save
        if not attr_ok
          @attr_errors[id] = val.errors
        end
      end
    end
    
    if @attr_errors.length > 0
      @structure.destroy
    end

    respond_to do |format|
      if (struct_ok) and (@attr_errors.length == 0)
        format.html { redirect_to project_structure_url(@project, @structure) }
        format.xml  { head :created, :location => project_structure_url(@project, @structure) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @structure.errors.to_xml }
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
          v.attributes = params[:attr_value][v.id.to_s]
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
        format.html { redirect_to project_structure_url(@project, @structure) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @structure.errors.to_xml }
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
