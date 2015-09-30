require 'csv'

class CsvExportsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :through => :project
  
  def index
    @csv_exports = @csv_exports.order(:name)
  end
  
  def new
  end
  
  def create
    @csv_export = @project.csv_exports.new(params[:csv_export])
    
    respond_to do |format|
      if @csv_export.save
        format.html { redirect_to csv_export_url(@project, @csv_export) }
        format.xml  { head :created, :location => csv_export_url(@project, @csv_export, :format => "xml" ) }
        format.json { head :created, :location => csv_export_url(@project, @csv_export, :format => "json") }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @csv_export.errors.to_xml }
        format.json { render :json => @csv_export.errors.to_json }
      end
    end
  end

  def show
    respond_to do |format|
      format.html {}
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=#{@csv_export.filename}"
        csv_data = CSV.generate { |csv| @csv_export.write(csv) }
        render :text => csv_data
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |format|
      if @csv_export.update_attributes(params[:csv_export])
        format.html { redirect_to csv_export_url(@project, @csv_export) }
        format.xml  { head :created, :location => csv_export_url(@project, @csv_export, :format => "xml" ) }
        format.json { head :created, :location => csv_export_url(@project, @csv_export, :format => "json") }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @csv_export.errors.to_xml }
        format.json { render :json => @csv_export.errors.to_json }
      end
    end
  end
  
  def destroy
    @csv_export.destroy

    respond_to do |format|
      format.html { redirect_to csv_exports_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
