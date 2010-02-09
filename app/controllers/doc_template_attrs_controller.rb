class DocTemplateAttrsController < ApplicationController
  perm_options = { :class_name => "Project", :id_param => "project_id" }
  rest_permissions perm_options
  require_permission "show", {:only => [:show_config]}.update(perm_options)
  require_permission "edit", {:only => [:sort, :update_config]}.update(perm_options)
  before_filter :get_template_and_project
  
  # GET /attrs
  # GET /attrs.xml
  def index
    @attrs = @doc_template.doc_template_attrs

    respond_to do |format|
      format.xml  { render :xml => @attrs.to_xml }
      format.json { render :json => @attrs.to_json }
    end
  end

  # GET /attrs/1
  # GET /attrs/1.xml
  def show
    @attr = @doc_template.doc_template_attrs.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @attr.to_xml }
      format.json { render :json => @attr.to_json }
    end
  end

  # GET /attrs/new
  def new
    @attr = @doc_template.doc_template_attrs.new
  end

  # POST /attrs
  # POST /attrs.xml
  def create
    @attr = @doc_template.doc_template_attrs.new(params[:attr])

    respond_to do |format|
      if @attr.save
        format.html { redirect_to doc_template_url(@project, @doc_template) }
        format.xml  { head :created, :location => doc_template_attr_url(@project, @doc_template, @attr) }
        format.json { head :created, :location => doc_template_attr_url(@project, @doc_template, @attr) }
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
    @attr = @doc_template.doc_template_attrs.find(params[:id])

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
    @attr = @doc_template.doc_template_attrs.find(params[:id])
    @attr.destroy

    respond_to do |format|
      format.html { redirect_to doc_template_url(@project, @doc_template) }
      format.xml  { head :ok }
      format.json { render :json => @attr.errors.to_json }
    end
  end

  def sort
    @attrs = @doc_template.doc_template_attrs
    @attrs.each do |attr|
      attr.position = params['attrs'].index(attr.id.to_s) + 1
      attr.save!
    end
    head :ok
  end

  private
  
  def get_template_and_project
    @project = Project.find(params[:project_id])
    @doc_template = @project.doc_templates.find(params[:doc_template_id])
  end
end
