class MapsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_project

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
    @map = @project.maps.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @map }
      format.json { render :json => @map }
      format.png  {
        send_data @map.output("png"), :filename => "#{@project.name} #{@map.name}.png",
                  :disposition => 'inline', :type => 'png'
      }
      format.svg {
        send_data @map.output("svg"), :filename => "#{@project.name} #{@map.name}.svg",
                  :disposition => 'inline', :type => 'svg'
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
        format.xml  { head :ok }
        format.json { head :ok }
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
