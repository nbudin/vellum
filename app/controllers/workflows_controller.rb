class WorkflowsController < ApplicationController
  rest_permissions
  before_filter :check_login
  
  # GET /workflows
  # GET /workflows.xml
  def index
    @workflows = Workflow.find(:all, :include => :permissions).select { |w| logged_in_person.permitted?(w, "show") }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workflows }
    end
  end

  # GET /workflows/1
  # GET /workflows/1.xml
  def show
    @workflow = Workflow.find(params[:id], :include => [:workflow_steps])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workflow }
    end
  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
  end

  # POST /workflows
  # POST /workflows.xml
  def create
    @workflow = Workflow.new(params[:workflow])

    respond_to do |format|
      if @workflow.save
        @workflow.grant(logged_in_person)
        format.html { redirect_to(@workflow) }
        format.xml  { head :created, :location => @workflow }
        format.json { head :created, :location => @workflow }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workflow.errors, :status => :unprocessable_entity }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflows/1
  # PUT /workflows/1.xml
  def update
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      if @workflow.update_attributes(params[:workflow])
        flash[:notice] = 'Workflow was successfully updated.'
        format.html { redirect_to(@workflow) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.xml
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to(workflows_url) }
      format.xml  { head :ok }
    end
  end

  private
  def check_login
    if not logged_in?
      redirect_to :controller => "about", :action => "index"
    end
  end
end
