class WorkflowTransitionsController < ApplicationController
  # GET /workflow_transitions
  # GET /workflow_transitions.xml
  def index
    @workflow_transitions = WorkflowTransition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workflow_transitions }
    end
  end

  # GET /workflow_transitions/1
  # GET /workflow_transitions/1.xml
  def show
    @workflow_transition = WorkflowTransition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workflow_transition }
    end
  end

  # GET /workflow_transitions/new
  # GET /workflow_transitions/new.xml
  def new
    @workflow_transition = WorkflowTransition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workflow_transition }
    end
  end

  # GET /workflow_transitions/1/edit
  def edit
    @workflow_transition = WorkflowTransition.find(params[:id])
  end

  # POST /workflow_transitions
  # POST /workflow_transitions.xml
  def create
    @workflow_transition = WorkflowTransition.new(params[:workflow_transition])

    respond_to do |format|
      if @workflow_transition.save
        flash[:notice] = 'WorkflowTransition was successfully created.'
        format.html { redirect_to(@workflow_transition) }
        format.xml  { render :xml => @workflow_transition, :status => :created, :location => @workflow_transition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workflow_transition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_transitions/1
  # PUT /workflow_transitions/1.xml
  def update
    @workflow_transition = WorkflowTransition.find(params[:id])

    respond_to do |format|
      if @workflow_transition.update_attributes(params[:workflow_transition])
        flash[:notice] = 'WorkflowTransition was successfully updated.'
        format.html { redirect_to(@workflow_transition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow_transition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_transitions/1
  # DELETE /workflow_transitions/1.xml
  def destroy
    @workflow_transition = WorkflowTransition.find(params[:id])
    @workflow_transition.destroy

    respond_to do |format|
      format.html { redirect_to(workflow_transitions_url) }
      format.xml  { head :ok }
    end
  end
end
