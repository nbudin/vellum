class TemplateSchemasController < ApplicationController
  # GET /template_schemas
  # GET /template_schemas.xml
  def index
    @template_schemas = TemplateSchema.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @template_schemas.to_xml }
    end
  end

  # GET /template_schemas/1
  # GET /template_schemas/1.xml
  def show
    @template_schema = TemplateSchema.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @template_schema.to_xml }
      format.json { render :json => @template_schema.to_json }
      format.vschema { render :xml => @template_schema.to_vschema }
    end
  end

  # GET /template_schemas/new
  def new
    @template_schema = TemplateSchema.new
  end

  # POST /template_schemas
  # POST /template_schemas.xml
  def create
    @template_schema = TemplateSchema.new(params[:template_schema])

    respond_to do |format|
      if @template_schema.save
        flash[:notice] = 'TemplateSchema was successfully created.'
        format.html { redirect_to template_schema_url(@template_schema) }
        format.xml  { head :created, :location => template_schema_url(@template_schema) }
        format.json { head :created, :location => template_schema_url(@template_schema) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @template_schema.errors.to_xml }
        format.json { render :json => @template_schema.errors.to_json }
      end
    end
  end

  # PUT /template_schemas/1
  # PUT /template_schemas/1.xml
  def update
    @template_schema = TemplateSchema.find(params[:id])

    respond_to do |format|
      if @template_schema.update_attributes(params[:template_schema])
        flash[:notice] = 'TemplateSchema was successfully updated.'
        format.html { redirect_to template_schema_url(@template_schema) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @template_schema.errors.to_xml }
        format.json { render :json => @template_schema.errors.to_json }
      end
    end
  end

  # DELETE /template_schemas/1
  # DELETE /template_schemas/1.xml
  def destroy
    @template_schema = TemplateSchema.find(params[:id])
    @template_schema.destroy

    respond_to do |format|
      format.html { redirect_to template_schemas_url }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
