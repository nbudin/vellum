class StructureTemplatesController < ApplicationController
  before_filter :get_schema
  
  # GET /structure_templates
  # GET /structure_templates.xml
  def index
    @structure_templates = @template_schema.structure_templates

    respond_to do |format|
      format.xml  { render :xml => @structure_templates.to_xml }
    end
  end

  # GET /structure_templates/1
  # GET /structure_templates/1.xml
  def show
    @structure_template = StructureTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @structure_template.to_xml(:include => [:attrs]) }
      format.json  { render :json => @structure_template.to_json }
    end
  end

  # GET /structure_templates/new
  def new
    @structure_template = StructureTemplate.new
  end

  # POST /structure_templates
  # POST /structure_templates.xml
  def create
    @structure_template = StructureTemplate.new(params[:structure_template])
    @structure_template.template_schema = @template_schema

    respond_to do |format|
      if @structure_template.save
        format.html { redirect_to structure_template_url(@template_schema, @structure_template) }
        format.xml  { head :created, :location => structure_template_url(@template_schema, @structure_template) }
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
        format.html { redirect_to structure_template_url(@template_schema, @structure_template) }
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
      format.html { redirect_to template_schema_url(@template_schema) }
      format.xml  { head :ok }
    end
  end
  
  def get_schema
    @template_schema = TemplateSchema.find(params[:template_schema_id])
  end
end
