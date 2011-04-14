class RelationshipsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :relationship, :through => :project
  
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
    @relationship = @project.relationships.new(params[:relationship])
    html_redirect = :back
    if params[:relationship][:target_id] == "new"
      tmpl = @relationship.relationship_type.send("#{@relationship.target_direction}_template")
      target = Doc.create(:project => @project, :doc_template => tmpl, :name => "New #{tmpl.name}")
      @relationship.target_id = target.id
      html_redirect = edit_doc_url(@project, target)
    end

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to html_redirect }
        format.xml  { render :xml => @relationship, :status => :created, :location => @relationship }
      else
        format.html { 
          flash[:error] = @relationship.errors.full_messages.join(", ")
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
          flash[:errors] = @relationship.errors.full_messages.join(", ")
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
end
