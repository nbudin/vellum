class WorkflowActionsController < ApplicationController
  # GET /workflow_actions
  # GET /workflow_actions.xml
  def index
    @workflow_actions = WorkflowAction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workflow_actions }
    end
  end

  # GET /workflow_actions/1
  # GET /workflow_actions/1.xml
  def show
    @workflow_action = WorkflowAction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workflow_action }
    end
  end

  # GET /workflow_actions/new
  # GET /workflow_actions/new.xml
  def new
    @workflow_action = WorkflowAction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workflow_action }
    end
  end

  # GET /workflow_actions/1/edit
  def edit
    @workflow_action = WorkflowAction.find(params[:id])
  end

  # POST /workflow_actions
  # POST /workflow_actions.xml
  def create
    @workflow_action = WorkflowAction.new(params[:workflow_action])

    respond_to do |format|
      if @workflow_action.save
        flash[:notice] = 'WorkflowAction was successfully created.'
        format.html { redirect_to(@workflow_action) }
        format.xml  { render :xml => @workflow_action, :status => :created, :location => @workflow_action }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workflow_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_actions/1
  # PUT /workflow_actions/1.xml
  def update
    @workflow_action = WorkflowAction.find(params[:id])

    respond_to do |format|
      if @workflow_action.update_attributes(params[:workflow_action])
        flash[:notice] = 'WorkflowAction was successfully updated.'
        format.html { redirect_to(@workflow_action) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_actions/1
  # DELETE /workflow_actions/1.xml
  def destroy
    @workflow_action = WorkflowAction.find(params[:id])
    @workflow_action.destroy

    respond_to do |format|
      format.html { redirect_to(workflow_actions_url) }
      format.xml  { head :ok }
    end
  end
end
