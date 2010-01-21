require 'test_helper'

class WorkflowActionsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @workflow = Factory.create(:workflow)
    @workflow.grant(@person)
    @start = @workflow.workflow_steps.create(:name => "Start", :position => 1)
    @end = @workflow.workflow_steps.create(:name => "End", :position => 2)
    @transition = @start.leaving_transitions.create(:to => @end, :name => "Finish")
    @params = {
      :workflow_id => @workflow.id,
      :workflow_step_id => @start.id,
      :workflow_transition_id => @transition.id
    }
    @transition_path = workflow_transition_path(@workflow, @start, @transition)
  end

  context "on POST to :create" do
    setup do
      @old_count = WorkflowAction.count
      post :create, @params.update(
        :workflow_action => {
          :type => "WorkflowActions::Reassign",
          :whom => "prompt"
        }
      )
    end

    should_redirect_to("the transition") { @transition_path }
    should_assign_to :workflow_action
    should_not_set_the_flash

    should "create a workflow action" do
      assert_equal @old_count + 1, WorkflowAction.count
    end
  end

  context "with a workflow action" do
    setup do
      @action = @transition.workflow_actions.create(:type => "WorkflowActions::Reassign",
        :whom => "prompt")
      @params[:id] = @action.id
    end

    context "on PUT to :update" do
      setup do
        @new_whom = @person.id.to_s
        put :update, @params.update(:workflow_action => { :whom => @new_whom })
      end

      should_redirect_to("the transition") { @transition_path }
      should_assign_to :workflow_action
      should_not_set_the_flash

      should "update the workflow action" do
        assert_equal @new_whom, assigns(:workflow_action).whom
        @action.reload
        assert_equal @new_whom, @action.whom
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = WorkflowAction.count
        delete :destroy, @params
      end

      should_redirect_to("the transition") { @transition_path }
      should_assign_to :workflow_action
      should_not_set_the_flash

      should "destroy a workflow action" do
        assert_equal @old_count - 1, WorkflowAction.count
      end
    end
  end
end
