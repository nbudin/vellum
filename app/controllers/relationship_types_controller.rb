class RelationshipTypesController < ApplicationController
  rest_edit_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project

  # GET /relationship_types/1
  # GET /relationship_types/1.xml
  def show
    @relationship_type = RelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @relationship_type }
      format.json  { render :json => @relationship_type }
    end
  end

  # POST /relationship_types
  # POST /relationship_types.xml
  def create
    @relationship_type = RelationshipType.new(params[:relationship_type])
    @relationship_type.project = @project

    respond_to do |format|
      if @relationship_type.save
        format.html { redirect_to(relationship_type_url(@project, @relationship_type)) }
        format.xml  { render :xml => @relationship_type, :status => :created,
          :location => relationship_type_url(@project, @relationship_type, :format => :xml) }
        format.json { render :json => @relationship_type, :status => :created, 
          :location => relationship_type_url(@project, @relationship_type, :format => :json) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @relationship_type.errors, :status => :unprocessable_entity }
        format.json { render :json => @relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relationship_types/1
  # PUT /relationship_types/1.xml
  def update
    @relationship_type = RelationshipType.find(params[:id])

    respond_to do |format|
      if @relationship_type.update_attributes(params[:relationship_type])
        format.html { redirect_to(relationship_type_url(@project, @relationship_type)) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relationship_type.errors, :status => :unprocessable_entity }
        format.json { render :json => @relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationship_types/1
  # DELETE /relationship_types/1.xml
  def destroy
    @relationship_type = RelationshipType.find(params[:id])
    left_template = @relationship_type.left_template
    @relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to(doc_template_url(@project, left_template)) }
      format.xml  { head :ok }
    end
  end

  private
  def get_project
    @project = Project.find(params[:project_id])
  end
end
