class DocsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :doc, :through => :project
  
  # GET /docs
  # GET /docs.xml
  def index
    conds = {}
    if params[:template_id]
      conds[:doc_template_id] = @project.doc_templates.find(params[:template_id]).id
    end
    @docs = @project.docs.all(:conditions => conds).sort_by {|s| s.name.try(:sort_normalize) || "" }

    serialization_options = { :only => [:id, :name, :version, :blurb, :doc_template_id] }
    respond_to do |format|
      format.xml  { render :xml => @docs.to_xml(serialization_options) }
      format.json { render :json => @docs.to_json(serialization_options) }
    end
  end

  # GET /docs/1
  # GET /docs/1.xml
  def show
    @doc = @project.docs.find(params[:id],
      :include => { :doc_template => [],
                    :outward_relationships => { :left => [], :relationship_type => [:left_template, :right_template] }, 
                    :inward_relationships => { :right => [], :relationship_type => [:left_template, :right_template] } })
    @doc.project = @project
    @relationships = @doc.relationships.sort_by do |rel|
      other = rel.other(@doc)
      "#{rel.description_for(@doc)} #{other.name.try(:sort_normalize)}"
    end
    @relationship_types = {}
    @doc.doc_template.relationship_types.each do |typ|
      next if @relationship_types.include? typ
      if typ.same_template?
        @relationship_types[typ] = [:left, :right]
      else
        @relationship_types[typ] = [typ.direction_of(@doc.doc_template)]
      end
    end
    
    other_docs = @project.docs.all(:conditions => {:doc_template_id => @doc.doc_template.id}, :order => 'position')
    my_index = other_docs.index(@doc)
    @prev_doc = (my_index > 0) && other_docs[my_index - 1]
    @next_doc = (my_index < other_docs.length - 1) && other_docs[my_index + 1]
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @doc.to_xml(:methods => [:attrs]) }
      format.json { render :json => @doc.to_json(:methods => [:attrs]) }
      format.fo   { render :layout => false }
    end
  end

  # GET /docs/new
  def new
    @doc = @project.docs.new
    @doc.doc_template = @project.doc_templates.find(params[:template_id])
  end

  # GET /docs/1;edit
  def edit
    @doc = @project.docs.find(params[:id])
  end

  # POST /docs
  # POST /docs.xml
  def create
    if params[:template_id]
      @doc_template = @project.doc_templates.find(params[:template_id])
    end

    @doc = @project.docs.new(params[:doc].update(
        :doc_template => @doc_template,
        :creator => current_person))

    respond_to do |format|
      if @doc.save
        format.html { redirect_to doc_url(@project, @doc) }
        format.xml  { head :created, :location => doc_url(@project, @doc, :format => "xml" ) }
        format.json { head :created, :location => doc_url(@project, @doc, :format => "json") }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @doc.errors.to_xml }
        format.json { render :json => @doc.errors.to_json }
      end
    end
  end

  # PUT /docs/1
  # PUT /docs/1.xml
  def update
    @doc = @project.docs.find(params[:id])

    successful_save = @doc.update_attributes(params[:doc])
    if successful_save
      v = @doc.versions.latest
      v.author = current_person
      successful_save = v.save
    end

    respond_to do |format|
      if successful_save
        format.html { redirect_to doc_url(@project, @doc) }
        format.xml  { render :xml => @doc.to_xml }
        format.json { render :json => @doc.to_json }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @doc.errors.to_xml }
        format.json { render :json => @doc.errors.to_json }
      end
    end
  end

  # DELETE /docs/1
  # DELETE /docs/1.xml
  def destroy
    @doc = @project.docs.find(params[:id])
    @doc.destroy

    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def sort
    params.each do |k, v|
      if k =~ /docs_(\d+)/
        tmpl_id = $1
        @doc_template = @project.doc_templates.find(tmpl_id)
        @docs = @project.docs.select { |s| s.doc_template == @doc_template }
        @docs.each do |doc|
          doc.position = v.index(doc.id.to_s) + 1
          doc.save!
        end
      end
    end
    head :ok
  end
end
