class WorkflowActionsController < ApplicationController
  rest_permissions :class_name => "Workflow", :id_param => "workflow_id"
  before_filter :get_workflow_from_and_transition

  # POST /workflow_actions
  # POST /workflow_actions.xml
  def create
    @workflow_action = @transition.workflow_actions.new(params[:workflow_action])
    @workflow_action.type = params[:workflow_action][:type]

    respond_to do |format|
      if @workflow_action.save
        format.html { redirect_to(workflow_transition_url(@workflow, @from, @transition)) }
        format.xml  { head :created, :location => @workflow_action }
        format.json { head :created, :location => @workflow_action }
      else
        format.html do
          flash[:error_messages] = @workflow_action.errors.full_messages
          redirect_to workflow_transition_url(@workflow, @from, @transition)
        end
        format.xml  { render :xml => @workflow_action.errors, :status => :unprocessable_entity }
        format.json { render :json => @workflow_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_actions/1
  # PUT /workflow_actions/1.xml
  def update
    @workflow_action = WorkflowAction.find(params[:id])

    respond_to do |format|
      if @workflow_action.update_attributes(params[:workflow_action])
        format.html { redirect_to(workflow_transition_url(@workflow, @from, @transition)) }
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
    @workflow_action = @transition.workflow_actions.find(params[:id])
    @workflow_action.destroy

    respond_to do |format|
      format.html { redirect_to(workflow_transition_url(@workflow, @from, @transition)) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private
  def get_workflow_from_and_transition
    @workflow = Workflow.find(params[:workflow_id])
    @from = @workflow.workflow_steps.find(params[:workflow_step_id])
    @transition = @from.leaving_transitions.find(params[:workflow_transition_id])
  end
end
