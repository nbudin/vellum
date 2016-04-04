class ProjectsController < ApplicationController
  load_and_authorize_resource :except => [:index]

  # GET /projects
  # GET /projects.xml
  def index
    @my_projects, @other_projects = Project.includes(:members).accessible_by(current_ability, :read).partition do |project|
      project.members.include?(current_person)
    end

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
    @project = Project.includes(:project_memberships, docs: :doc_template).find(params[:id])

    respond_to do |format|
      format.html do
        @templates = @project.doc_templates.to_a.sort_by { |t| t.name.sort_normalize }
        @docs = @project.docs.includes(:doc_template, :assignee).to_a.group_by(&:doc_template)
        @docs.transform_values! { |docs| docs.sort_by! { |d| d.position || 0 } }
      end
      format.xml  { render :xml => @project.to_xml }
      format.json { render :json => @project.to_json }
      format.vproj {
        tempfile = @project.to_vproj
        send_file tempfile.path, :type => :vproj, :disposition => 'attachment',
          :filename => "#{@project.name}.vproj"
      }
    end
  end

  def edit
    @project = Project.includes(project_memberships: :person).find(params[:id])
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

    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        @project.project_memberships.create!(:person => current_person, :author => true, :admin => true)

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
      if @project.update_attributes(project_params)
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

  private

  def project_params
    params.require(:project).permit(
      :name,
      :blurb,
      :template_source_project_id,
      :public_visibility,
      project_memberships_attributes: [
        :id,
        :email,
        :author,
        :admin,
        :_destroy
      ]
    )
  end
end
