class ProjectsController < ApplicationController
  load_and_authorize_resource :except => [:index]

  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.accessible_by(current_ability, :read)
    
    respond_to do |format|
      format.html { render :action => "index" }
      format.xml  { authorize! :create, Project ; render :xml => @projects.to_xml }
      format.json { authorize! :create, Project ; render :json => @projects.to_json }
    end
  end

  def new
    @template_sources = Project.accessible_by(current_ability, :copy_templates)
    
    render :action => "new"
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id], 
      :include => { :docs => { :doc_template => [] },
                    :project_memberships => [] })

    respond_to do |format|
      format.html do
        @templates = @project.doc_templates.sort_by { |t| t.name.sort_normalize }
        @docs = {}
        @project.docs.all(:include => [:doc_template, :assignee]).each do |d|
          @docs[d.doc_template] ||= []
          @docs[d.doc_template] << d
        end
        @templates.each do |tmpl|
          @docs[tmpl] ||= []
          @docs[tmpl] = @docs[tmpl].sort_by { |s| s.position || 0 }
        end
      end
      format.xml  { render :xml => @project.to_xml }
      format.json { render :json => @project.to_json }
      format.vproj { render :xml => @project.to_vproj(:all_doc_versions => params[:all_doc_versions]) }
    end
  end
  
  def edit
    @project = Project.find(params[:id], :include => {:project_memberships => :person})
    authorize! :change_permissions, @project
    
    @project.project_memberships.build
  end

  # POST /projects
  # POST /projects.xml
  def create
    unless params[:project][:template_source_project_id].blank?
      source_project = Project.find(params[:project][:template_source_project_id])
      authorize! :copy_templates, source_project
    end
    
    @project = Project.new(params[:project])
    @project.project_memberships.build(:person => current_person, :project => @project, :author => true, :admin => true)

    respond_to do |format|
      if @project.save
        format.html { redirect_to project_url(@project) }
        format.xml  { head :created, :location => project_url(@project) }
        format.json { head :created, :location => project_url(@project) }
      else
        format.html { self.new }
        format.xml  { render :xml => @project.errors.to_xml }
        format.json { render :json => @project.errors.to_json }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
    authorize! :change_permissions, @project

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to project_url(@project) }
        format.xml  { render :xml => @project.to_xml }
        format.json { render :json => @project.to_json }
      else
        format.html { render :action => "edit" }
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
end
