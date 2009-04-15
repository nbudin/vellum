class AttrsController < ApplicationController
  before_filter :get_template_and_schema
  
  # GET /attrs
  # GET /attrs.xml
  def index
    @attrs = @structure_template.attrs

    respond_to do |format|
      format.xml  { render :xml => @attrs.to_xml }
      format.json { render :json => @attrs.to_json }
    end
  end

  # GET /attrs/1
  # GET /attrs/1.xml
  def show
    @attr = Attr.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @attr.to_xml }
      format.json { render :json => @attr.to_json }
    end
  end

  # GET /attrs/new
  def new
    @attr = Attr.new
  end

  # POST /attrs
  # POST /attrs.xml
  def create
    @attr = Attr.new(params[:attr])
    
    if params[:config_class] =~ /\W/
      @attr.errors.add("attr_configuration", "class name contains invalid characters.")
      render :action => "new"
      return
    end
    if params[:config_class].nil?
      @attr.errors.add("attr_configuration", "class name must be specified.")
      render :action => "new"
      return
    end
    config_class = eval(params[:config_class])
    
    @attr.attr_configuration = config_class.new(params[:attr].reject {|k, v| k == 'name'})
    @attr.structure_template = @structure_template

    respond_to do |format|
      if @attr.save
        format.html { redirect_to structure_template_url(@template_schema, @structure_template) }
        format.xml  { head :created, :location => attr_url(@template_schema, @structure_template, @attr) }
        format.json { head :created, :location => attr_url(@template_schema, @structure_template, @attr) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attr.errors.to_xml }
        format.json { render :json => @attr.errors.to_json }
      end
    end
  end

  # PUT /attrs/1
  # PUT /attrs/1.xml
  def update
    @attr = Attr.find(params[:id])

    respond_to do |format|
      if @attr.update_attributes(params[:attr])
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.xml  { render :xml => @attr.errors.to_xml }
        format.json { render :json => @attr.errors.to_json }
      end
    end
  end

  # DELETE /attrs/1
  # DELETE /attrs/1.xml
  def destroy
    @attr = Attr.find(params[:id])
    @attr.destroy

    respond_to do |format|
      format.html { redirect_to structure_template_url(@template_schema, @structure_template) }
      format.xml  { head :ok }
      format.json { render :json => @attr.errors.to_json }
    end
  end

  def show_config
    @attr = Attr.find(params[:id])
    @config = @attr.attr_configuration

    respond_to do |format|
      format.xml  { render :xml => @config.to_xml }
      format.json { render :json => @config.to_json }
    end
  end

  def update
    @attr = Attr.find(params[:id])
    @config = @attr.attr_configuration

    respond_to do |format|
      if @config.update_attributes(params[:config])
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.xml  { render :xml => @config.errors.to_xml }
        format.json { render :json => @config.errors.to_json }
      end
    end
  end

  private
  
  def get_template_and_schema
    @structure_template = StructureTemplate.find(params[:structure_template_id])
    @template_schema = TemplateSchema.find(params[:template_schema_id])
  end
end
