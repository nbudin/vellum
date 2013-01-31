class DocTemplatesController < ApplicationController
  load_resource :project
  load_and_authorize_resource :through => :project
  
  cache_sweeper :project_sweeper, :only => [:create, :update, :destroy]
  
  # GET /doc_templates
  # GET /doc_templates.xml
  def index
    @doc_templates = @project.doc_templates.all(:order => "name")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @doc_templates.to_xml }
      format.json { render :json => @doc_templates.to_json }
    end
  end

  # GET /doc_templates/1
  # GET /doc_templates/1.xml
  def show
    @relationship_types = @doc_template.outward_relationship_types + @doc_template.inward_relationship_types

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @doc_template.to_xml(:include => [:attrs]) }
      format.json  { render :json => @doc_template.to_json }
    end
  end

  def new
    @doc_template = @project.doc_templates.new
  end

  # GET /doc_templates/1
  # GET /doc_templates/1.xml
  def edit
    @relationship_types = @doc_template.outward_relationship_types + @doc_template.inward_relationship_types
  end

  # POST /doc_templates
  # POST /doc_templates.xml
  def create
    respond_to do |format|
      if @doc_template.save
        format.html { redirect_to doc_template_url(@project, @doc_template) }
        format.xml  { head :created, :location => doc_template_url(@project, @doc_template) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @doc_template.errors.to_xml }
      end
    end
  end

  # PUT /doc_templates/1
  # PUT /doc_templates/1.xml
  def update
    update_params = params[:doc_template].dup
    if update_params[:doc_template_attrs_attributes]
      update_params[:doc_template_attrs_attributes].reject! { |id, attr_params| attr_params[:name].blank? }
    end

    respond_to do |format|
      if @doc_template.update_attributes(update_params)
        format.html { redirect_to doc_template_url(@project, @doc_template) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @doc_template.errors.to_xml }
        format.json { render :json => @doc_template.errors.to_json }
      end
    end
  end

  # DELETE /doc_templates/1
  # DELETE /doc_templates/1.xml
  def destroy
    @doc_template.destroy

    respond_to do |format|
      format.html { redirect_to doc_templates_url(@project) }
      format.xml  { head :ok }
    end
  end
end
