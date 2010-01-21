require 'test_helper'

class WorkflowStepsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @workflow = Factory.create(:workflow)
    @workflow.grant(@person)
  end

  context "on POST to :create" do
    setup do
      @old_count = WorkflowStep.count
      @name = "Start"
      post :create, :workflow_id => @workflow.id, :workflow_step => { :name => @name }
    end

    should_redirect_to("the workflow") { @workflow }
    should_assign_to :workflow_step
    should_not_set_the_flash

    should "create a step" do
      assert_equal @old_count + 1, WorkflowStep.count
      assert_equal @name, assigns(:workflow_step).name
    end
  end

  context "with steps" do
    setup do
      @start = @workflow.workflow_steps.create(:name => "Start", :position => 1)
      @end = @workflow.workflow_steps.create(:name => "End", :position => 2)
    end

    context "on PUT to :update" do
      setup do
        @new_name = "Begin"
        put :update, :id => @start.id, :workflow_id => @workflow.id,
          :workflow_step => { :name => @new_name }
      end

      should_redirect_to("the workflow") { @workflow }
      should_assign_to :workflow_step
      should_not_set_the_flash

      should "update the step" do
        assert_equal @new_name, assigns(:workflow_step).name
        @start.reload
        assert_equal @new_name, @start.name
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = WorkflowStep.count
        delete :destroy, :id => @start.id, :workflow_id => @workflow.id
      end

      should_redirect_to("the workflow") { @workflow }
      should_assign_to :workflow_step
      should_not_set_the_flash

      should "destroy a step" do
        assert_equal @old_count - 1, WorkflowStep.count
      end
    end

    context "on POST to :sort" do
      setup do
        post :sort, :workflow_id => @workflow.id, 
          :workflow_steps => [ @end.id.to_s, @start.id.to_s ]
      end

      should_respond_with :success
      should_assign_to :workflow_steps
      should_not_set_the_flash

      should "re-sort the steps" do
        @end.reload
        @start.reload
        assert @start.position > @end.position
      end
    end
  end
end
