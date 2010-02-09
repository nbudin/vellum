class RelationshipsController < ApplicationController
  rest_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  
  # GET /relationships
  # GET /relationships.xml
  def index
    @relationships = @project.relationships

    respond_to do |format|
      format.xml  { render :xml => @relationships }
      format.json { render :json => @relationships }
    end
  end

  # GET /relationships/1
  # GET /relationships/1.xml
  def show
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @relationship }
      format.json { render :json => @relationship }
    end
  end

  # POST /relationships
  # POST /relationships.xml
  def create
    @relationship_type = RelationshipType.find(params[:relationship][:relationship_type_id])
    html_redirect = :back
    if params[:relationship][:left_id] == "new"
      left = Doc.create(:project => @project, :doc_template => @relationship_type.left_template)
      params[:relationship][:left_id] = left.id
      html_redirect = edit_doc_url(@project, left)
    elsif params[:relationship][:right_id] == "new"
      right = Doc.create(:project => @project, :doc_template => @relationship_type.right_template)
      params[:relationship][:right_id] = right.id
      html_redirect = edit_doc_url(@project, right)
    end

    @relationship = Relationship.new(params[:relationship])
    @relationship.project = @project

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to html_redirect }
        format.xml  { render :xml => @relationship, :status => :created, :location => @relationship }
      else
        format.html { 
          flash[:error_messages] = @relationship.errors.full_messages
          redirect_to :back 
        }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.xml
  def update
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if @relationship.update_attributes(params[:relationship])
        format.html { redirect_to :back }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { 
          flash[:error_messages] = @relationship.errors.full_messages
          redirect_to :back 
        }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
        format.json { render :json => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.xml
  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private
  
  def get_project
    @project = Project.find(params[:project_id])
  end
end
