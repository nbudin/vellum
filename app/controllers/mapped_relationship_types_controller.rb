class MappedRelationshipTypesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :map, :through => :project
  load_and_authorize_resource :mapped_relationship_type, :through => :map

  # POST /mapped_relationship_types
  # POST /mapped_relationship_types.xml
  def create
    @mapped_relationship_type = @map.mapped_relationship_types.new(mapped_relationship_type_params)

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
      if @mapped_relationship_type.update_attributes(mapped_relationship_type_params)
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
  
  def mapped_relationship_type_params
    params.fetch(:mapped_relationship_type, {}).permit(:relationship_type_id, :color)
  end
end
