require 'test_helper'

class WorkflowTransitionsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @workflow = Factory.create(:workflow)
    @workflow.grant(@person)
    @start = @workflow.workflow_steps.create(:name => "Start", :position => 1)
    @end = @workflow.workflow_steps.create(:name => "End", :position => 2)
  end

  context "on POST to :create" do
    setup do
      @old_count = WorkflowTransition.count
      post :create, :workflow_id => @workflow.id, :workflow_step_id => @start.id,
        :workflow_transition => { :to_id => @end.id, :name => "Finish" }
    end

    should_redirect_to("the new transition") {
      workflow_transition_path(@workflow, @start, assigns(:workflow_transition))
    }
    should_assign_to :workflow_transition
    should_not_set_the_flash

    should "create a workflow transition" do
      assert_equal @old_count + 1, WorkflowTransition.count
      assert_equal @end.id, assigns(:workflow_transition).to.id
    end
  end

  context "with a transition" do
    setup do
      @transition = @start.leaving_transitions.create(:to => @end, :name => "Finish")
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @transition.id, :workflow_step_id => @start.id, :workflow_id => @workflow.id
      end

      should_respond_with :success
      should_assign_to :workflow_transition
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_name = "Finish him!!!!"
        put :update, :id => @transition.id, :workflow_step_id => @start.id, :workflow_id => @workflow.id,
          :workflow_transition => { :name => @new_name }
      end

      should_redirect_to("the transition") {
        workflow_transition_path(@workflow, @start, @transition)
      }
      should_assign_to :workflow_transition
      should_not_set_the_flash

      should "update the transition" do
        assert_equal @new_name, assigns(:workflow_transition).name
        @transition.reload
        assert_equal @new_name, @transition.name
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = WorkflowTransition.count
        delete :destroy, :id => @transition.id, :workflow_step_id => @start.id, :workflow_id => @workflow.id
      end

      should_redirect_to("the workflow") { @workflow }
      should_assign_to :workflow_transition
      should_not_set_the_flash

      should "destroy a transition" do
        assert_equal @old_count - 1, WorkflowTransition.count
      end
    end
  end
end
