class StructureTemplatesController < ApplicationController
  # GET /structure_templates
  # GET /structure_templates.xml
  def index
    @structure_templates = StructureTemplate.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @structure_templates.to_xml }
    end
  end

  # GET /structure_templates/1
  # GET /structure_templates/1.xml
  def show
    @structure_template = StructureTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure_template.to_xml }
      format.json  { render :json => @structure_template.to_json }
    end
  end

  # GET /structure_templates/new
  def new
    @structure_template = StructureTemplate.new
  end

  # GET /structure_templates/1;edit
  def edit
    @structure_template = StructureTemplate.find(params[:id])
  end

  # POST /structure_templates
  # POST /structure_templates.xml
  def create
    @structure_template = StructureTemplate.new(params[:structure_template])

    respond_to do |format|
      if @structure_template.save
        flash[:notice] = 'StructureTemplate was successfully created.'
        format.html { redirect_to structure_template_url(@structure_template) }
        format.xml  { head :created, :location => structure_template_url(@structure_template) }
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

    respond_to do |format|
      if @structure_template.update_attributes(params[:structure_template])
        flash[:notice] = 'StructureTemplate was successfully updated.'
        format.html { redirect_to structure_template_url(@structure_template) }
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
      format.html { redirect_to structure_templates_url }
      format.xml  { head :ok }
    end
  end
end
