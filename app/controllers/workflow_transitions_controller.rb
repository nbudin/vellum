class WorkflowTransitionsController < ApplicationController
  rest_permissions :class_name => "Workflow", :id_param => "workflow_id"
  before_filter :get_workflow_and_from

  # GET /workflow_transitions/1
  # GET /workflow_transitions/1.xml
  def show
    @workflow_transition = @from.leaving_transitions.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workflow_transition }
    end
  end

  # POST /workflow_transitions
  # POST /workflow_transitions.xml
  def create
    @workflow_transition = @from.leaving_transitions.new(params[:workflow_transition])

    respond_to do |format|
      if @workflow_transition.save
        format.html { redirect_to(workflow_transition_url(@workflow, @from, @workflow_transition)) }
        format.xml  { head :created, :location => @workflow_transition }
        format.json { head :created, :location => @workflow_transition }
      else
        format.html { render :controller => "workflows", :action => "show" }
        format.xml  { render :xml => @workflow_transition.errors, :status => :unprocessable_entity }
        format.json { render :json => @workflow_transition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_transitions/1
  # PUT /workflow_transitions/1.xml
  def update
    @workflow_transition = @from.leaving_transitions.find(params[:id])

    respond_to do |format|
      if @workflow_transition.update_attributes(params[:workflow_transition])
        format.html { redirect_to(@workflow) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow_transition.errors, :status => :unprocessable_entity }
        format.json { render :xml => @workflow_transition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_transitions/1
  # DELETE /workflow_transitions/1.xml
  def destroy
    @workflow_transition = @from.leaving_transitions.find(params[:id])
    @workflow_transition.destroy

    respond_to do |format|
      format.html { redirect_to(@workflow) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private
  def get_workflow_and_from
    @workflow = Workflow.find(params[:workflow_id])
    @from = @workflow.workflow_steps.find(params[:workflow_step_id])
  end
end
