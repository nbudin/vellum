class DocsController < ApplicationController
  rest_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project

  # GET /docs
  # GET /docs.xml
  def index
    @docs = Doc.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @docs.to_xml }
    end
  end

  # GET /docs/1
  # GET /docs/1.xml
  def show
    @doc = Doc.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @doc.to_xml }
    end
  end

  # GET /docs/new
  def new
    @doc = Doc.new
  end

  # GET /docs/1;edit
  def edit
    @doc = Doc.find(params[:id])
  end

  # POST /docs
  # POST /docs.xml
  def create
    @doc = Doc.new(params[:doc])
    @doc.project = @project

    respond_to do |format|
      if @doc.save
        flash[:notice] = 'Doc was successfully created.'
        format.html { redirect_to doc_url(@project, @doc) }
        format.xml  { head :created, :location => doc_url(@project, @doc) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @doc.errors.to_xml }
      end
    end
  end

  # PUT /docs/1
  # PUT /docs/1.xml
  def update
    @doc = Doc.find(params[:id])

    respond_to do |format|
      if @doc.update_attributes(params[:doc])
        flash[:notice] = 'Doc was successfully updated.'
        format.html { redirect_to doc_url(@project, @doc) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @doc.errors.to_xml }
      end
    end
  end

  # DELETE /docs/1
  # DELETE /docs/1.xml
  def destroy
    @doc = Doc.find(params[:id])
    @doc.destroy

    respond_to do |format|
      format.html { redirect_to docs_url(@project) }
      format.xml  { head :ok }
    end
  end

  private
  
  def get_project
    @project = Project.find(params[:project_id])
  end
end
