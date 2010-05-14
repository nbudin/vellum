require 'zip/zip'

class PublicationTemplatesController < ApplicationController
  rest_edit_permissions :class_name => "Project", :id_param => "project_id"
  before_filter :get_project
  
  def index
    @publication_templates = @project.publication_templates.all(:order => :name)
  end
  
  # GET /docs/1
  # GET /docs/1.xml
  def show
    @publication_template = @project.publication_templates.find(params[:id])
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @publication_template.to_xml }
      format.json { render :json => @publication_template.to_json }
    end
  end
  
  def new
    @publication_template = @project.publication_templates.build
    @doc_templates = @project.doc_templates.all.sort_by { |t| t.name.sort_normalize }
  end
  
  # GET /publication_templates/1;edit
  def edit
    @publication_template = @project.publication_templates.find(params[:id])
    @doc_templates = @project.doc_templates.all.sort_by { |t| t.name.sort_normalize }
  end

  def create
    @publication_template = @project.publication_templates.new(params[:publication_template])

    respond_to do |format|
      if @publication_template.save
        format.html { redirect_to publication_template_url(@project, @publication_template) }
        format.xml  { head :created, :location => publication_template_url(@project, @publication_template, :format => "xml" ) }
        format.json { head :created, :location => publication_template_url(@project, @publication_template, :format => "json") }
      else
        flash[:error_messages] = @publication_template.errors.full_messages
        format.html { render :action => "new" }
        format.xml  { render :xml => @publication_template.errors.to_xml }
        format.json { render :json => @publication_template.errors.to_json }
      end
    end
  end
  
  def test
    @publication_template = @project.publication_templates.find(params[:id])
    
    context_options = { :project => @project }
    if params[:context] && params[:context][:doc_id]
      @doc = @project.docs.find(params[:context][:doc_id])
      context_options[:doc] = @doc
    end
    
    begin
      @output = @publication_template.execute(context_options)
    rescue Exception => e
      @error = e
    end
  end
  
  def publish
    @publication_template = @project.publication_templates.find(params[:id])
    
    context_options = { :project => @project }
    
    @tempfile = Tempfile.new("vellum-publication.zip")
    
    begin      
      Zip::ZipOutputStream.open(@tempfile.path) do |zipfile|
        if @publication_template.doc_template
          @publication_template.doc_template.docs.each do |doc|
            zipfile.put_next_entry("#{doc.name}.#{@publication_template.output_format}")
            zipfile.print @publication_template.execute(:project => @project, :doc => doc)
          end
        else
          zipfile.put_next_entry("#{@publication_template.name}.#{@publication_template.output_format}")
          zipfile.print @publication_template.execute(:project => @project)
        end
      end
      
      filename = @project.name
      filename << " - #{@publication_template.doc_template.plural_name}" if @publication_template.doc_template
      filename << ".zip"
      
      send_file @tempfile.path, :type => 'application/zip', :disposition => 'attachment',
        :filename => filename
    rescue Exception => e
      @error = e
      render :action => 'test'
    ensure
      @tempfile.close
    end
  end

  # PUT /publication_templates/1
  # PUT /publication_templates/1.xml
  def update
    @publication_template = @project.publication_templates.find(params[:id])

    respond_to do |format|
      if @publication_template.update_attributes(params[:publication_template])
        format.html { redirect_to publication_template_url(@project, @publication_template) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @publication_template.errors.to_xml }
        format.json { render :json => @publication_template.errors.to_json }
      end
    end
  end

  # DELETE /publication_templates/1
  # DELETE /publication_templates/1.xml
  def destroy
    @publication_template = @project.publication_templates.find(params[:id])
    @publication_template.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  private
  def get_project
    @project = Project.find(params[:project_id])
  end
end
