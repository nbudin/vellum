class WorkflowStepsController < ApplicationController
  rest_permissions :class_name => "Workflow", :id_param => "workflow_id"
  before_filter :get_workflow

  # POST /workflow_steps
  # POST /workflow_steps.xml
  def create
    @workflow_step = WorkflowStep.new(params[:workflow_step])
    @workflow_step.workflow = @workflow

    respond_to do |format|
      if @workflow_step.save
        format.html { redirect_to(@workflow) }
        format.xml  { head :created, :location => @workflow_step }
        format.json { head :created, :location => @workflow_step }
      else
        format.html { redirect_to(@workflow) }
        format.xml  { render :xml => @workflow_step.errors, :status => :unprocessable_entity }
        format.json { render :json => @workflow_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_steps/1
  # PUT /workflow_steps/1.xml
  def update
    @workflow_step = WorkflowStep.find(params[:id])

    respond_to do |format|
      if @workflow_step.update_attributes(params[:workflow_step])
        flash[:notice] = 'WorkflowStep was successfully updated.'
        format.html { redirect_to(@workflow_step) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_steps/1
  # DELETE /workflow_steps/1.xml
  def destroy
    @workflow_step = WorkflowStep.find(params[:id])
    @workflow_step.destroy

    respond_to do |format|
      format.html { redirect_to(workflow_steps_url) }
      format.xml  { head :ok }
    end
  end

  def sort
    @workflow_steps = @workflow.workflow_steps
    @workflow_steps.each do |step|
      step.position = params['workflow_steps'].index(step.id.to_s) + 1
      step.save!
    end
    head :ok
  end

  private
  def get_workflow
    @workflow = Workflow.find(params[:workflow_id])
  end
end
