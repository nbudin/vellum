class AttrsController < ApplicationController
  before_filter :get_template
  
  # GET /attrs
  # GET /attrs.xml
  def index
    @attrs = Attr.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @attrs.to_xml }
    end
  end

  # GET /attrs/1
  # GET /attrs/1.xml
  def show
    @attr = Attr.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @attr.to_xml }
    end
  end

  # GET /attrs/new
  def new
    @attr = Attr.new
  end

  # GET /attrs/1;edit
  def edit
    @attr = Attr.find(params[:id])
  end

  # POST /attrs
  # POST /attrs.xml
  def create
    @attr = Attr.new(params[:attr])
    
    if params[:config_class] =~ /\W/
      @attr.errors.add("attr_configuration", "class name contains invalid characters.")
      render :action => "new"
      return
    end
    if params[:config_class].nil?
      @attr.errors.add("attr_configuration", "class name must be specified.")
      render :action => "new"
      return
    end
    config_class = eval(params[:config_class])
    
    @attr.attr_configuration = config_class.new(params[:attr].reject {|k, v| k == 'name'})
    @attr.structure_template = @structure_template

    respond_to do |format|
      if @attr.save
        flash[:notice] = 'Attr was successfully created.'
        format.html { redirect_to attr_url(@structure_template, @attr) }
        format.xml  { head :created, :location => attr_url(@structure_template, @attr) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attr.errors.to_xml }
      end
    end
  end

  # PUT /attrs/1
  # PUT /attrs/1.xml
  def update
    @attr = Attr.find(params[:id])

    respond_to do |format|
      if @attr.update_attributes(params[:attr])
        flash[:notice] = 'Attr was successfully updated.'
        format.html { redirect_to attr_url(@structure_template, @attr) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attr.errors.to_xml }
      end
    end
  end

  # DELETE /attrs/1
  # DELETE /attrs/1.xml
  def destroy
    @attr = Attr.find(params[:id])
    @attr.destroy

    respond_to do |format|
      format.html { redirect_to attrs_url }
      format.xml  { head :ok }
    end
  end
  
  def get_template
    @structure_template = StructureTemplate.find(params[:structure_template_id])
  end
end
