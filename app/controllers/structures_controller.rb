class StructuresController < ApplicationController
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
        format.html { redirect_to structure_url(@project, @structure) }
        format.xml  { head :created, :location => structure_url(@project, @structure) }
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

    respond_to do |format|
      if @structure.update_attributes(params[:structure])
        format.html { redirect_to structure_url(@project, @structure) }
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
    @structure.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
    end
  end
  
  def get_project
    @project = Project.find(params[:project_id])
  end
end