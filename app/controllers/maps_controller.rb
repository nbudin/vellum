class MapsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :map, :through => :project

  def index
    @maps = @project.maps

    respond_to do |format|
      format.html
      format.xml  { render :xml => @maps }
      format.json { render :json => @maps }
    end
  end

  # GET /maps/1
  # GET /maps/1.xml
  def show
    @map = @project.maps.includes(
      mapped_relationship_types: { relationship_type: :relationships },
      mapped_doc_templates: { doc_template: :docs }
    ).find(params[:id])
    
    attachment_filename = "#{@project.name} #{@map.name}.#{params[:format]}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @map }
      format.json { render :json => @map }
      format.png  {
        headers['Content-Disposition'] = "inline; filename=#{attachment_filename}"
        render :text => @map.output("png")
      }
      format.pdf {
        headers['Content-Disposition'] = "attachment; filename=#{attachment_filename}"
        render :text => @map.output("pdf")
      }
      format.svg {
        headers['Content-Disposition'] = "inline; filename=#{attachment_filename}"
        render :text => @map.output("svg")
      }
    end
  end

  # POST /maps
  # POST /maps.xml
  def create
    @map = @project.maps.new(params[:map])

    respond_to do |format|
      if @map.save
        format.html { redirect_to map_url(@project, @map) }
        format.xml  { render :xml => @map, :status => :created, :location => @map }
        format.json { render :json => @map, :status => :created, :location => @map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
        format.json { render :json => @map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /maps/1
  # PUT /maps/1.xml
  def update
    @map = @project.maps.find(params[:id])

    respond_to do |format|
      if @map.update_attributes(params[:map])
        format.html { redirect_to map_url(@project, @map) }
        format.xml  { render :xml => @map.to_xml }
        format.json { render :json => @map.to_json }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @map.errors, :status => :unprocessable_entity }
        format.json { render :json => @map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.xml
  def destroy
    @map = @project.maps.find(params[:id])
    @map.destroy

    respond_to do |format|
      format.html { redirect_to(maps_url(@project)) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
  end
end
