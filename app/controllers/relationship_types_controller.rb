class RelationshipTypesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :relationship_type, :through => :project
  
  def new
    set_relationship_type_return_url    
    render :action => "choose_templates" if templates_needed?
  end
  
  # GET /relationship_types/1
  # GET /relationship_types/1.xml
  def show
    @relationship_type = @project.relationship_types.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @relationship_type }
      format.json  { render :json => @relationship_type }
    end
  end
  
  def edit
    set_relationship_type_return_url
    @relationship_type = @project.relationship_types.find(params[:id])
  end

  # POST /relationship_types
  # POST /relationship_types.xml
  def create
    if templates_needed?
      set_relationship_type_return_url
      render :action => "choose_templates"
    else
      respond_to do |format|
        if @relationship_type.save
          format.html { redirect_to(relationship_type_return_url) }
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
  end

  # PUT /relationship_types/1
  # PUT /relationship_types/1.xml
  def update
    respond_to do |format|
      if @relationship_type.update(relationship_type_params)
        format.html { redirect_to(relationship_type_return_url) }
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
  def set_relationship_type_return_url
    session[:relationship_type_return_url] ||= request.referer
  end
  
  def relationship_type_return_url
    session.delete(:relationship_type_return_url) || doc_template_url(@project, @relationship_type.left_template)
  end
  
  def templates_needed?
    @relationship_type.left_template.nil? or @relationship_type.right_template.nil?
  end 
  
  def relationship_type_params
    params.require(:relationship_type).permit(
      :name,
      :left_template_id, 
      :right_template_id,
      :left_description,
      :right_description
    )
  end
end
