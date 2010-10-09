class MappedRelationshipTypesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_project_and_map

  # POST /mapped_relationship_types
  # POST /mapped_relationship_types.xml
  def create
    @mapped_relationship_type = @map.mapped_relationship_types.new(params[:mapped_relationship_type])

    respond_to do |format|
      if @mapped_relationship_type.save
        format.html { redirect_to(:back) }
        format.xml  { render :xml => @mapped_relationship_type, :status => :created, :location => @mapped_relationship_type }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mapped_relationship_types/1
  # PUT /mapped_relationship_types/1.xml
  def update
    @mapped_relationship_type = @map.mapped_relationship_types.find(params[:id])

    respond_to do |format|
      if @mapped_relationship_type.update_attributes(params[:mapped_relationship_type])
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_relationship_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mapped_relationship_types/1
  # DELETE /mapped_relationship_types/1.xml
  def destroy
    @mapped_relationship_type = MappedRelationshipType.find(params[:id])
    @mapped_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_project_and_map
    @project = Project.find params[:project_id]
    @map = Map.find params[:map_id]
  end
end
