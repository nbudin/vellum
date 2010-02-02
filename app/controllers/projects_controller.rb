class ProjectsController < ApplicationController
  rest_permissions
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = if logged_in?
      Project.find(:all, :include => :permissions).select { |p|
        logged_in_person.permitted?(p, "show")
      }
    else
      []
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @projects.to_xml }
      format.json { render :json => @projects.to_json }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id], 
      :include => { :structures => { :structure_template => [] },
                                     :permissions => [] })

    respond_to do |format|
      format.html do
        @templates = @project.structure_templates.sort_by { |ts| ts.name.sort_normalize }
        @structures = {}
        @templates.each do |tmpl|
          @structures[tmpl] = @project.structures.select { |s| s.structure_template == tmpl }
          @structures[tmpl] = @structures[tmpl].sort_by { |s| s.position }
        end
      end
      format.xml  { render :xml => @project.to_xml }
      format.json { render :json => @project.to_json }
      format.vproj { render :xml => @project.to_vproj(:all_doc_versions => params[:all_doc_versions]) }
    end
  end
  
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        @project.grant(logged_in_person)
        format.html { redirect_to project_url(@project) }
        format.xml  { head :created, :location => project_url(@project) }
        format.json { head :created, :location => project_url(@project) }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @project.errors.to_xml }
        format.json { render :json => @project.errors.to_json }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to project_url(@project) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml => @project.errors.to_xml }
        format.json { render :json => @project.errors.to_json }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  private
  def check_login
    if not logged_in?
      redirect_to :controller => "about", :action => "index"
    end
  end
end
