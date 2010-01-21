require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      get :index
    end

    should_respond_with :success
    should_assign_to :workflows
    should_render_template "index"
  end

  context "on POST to :create" do
    setup do
      @old_count = Workflow.count
      @name = "My super cool workflow"
      post :create, :workflow => { :name => @name }
    end

    should_respond_with :redirect
    should_assign_to :workflow
    should_not_set_the_flash

    should "create a workflow with permissions for the logged in person" do
      assert_equal @old_count + 1, Workflow.count
      assert @person.permitted?(assigns(:workflow), "edit")
    end

    should "redirect to the new workflow" do
      assert_redirected_to assigns(:workflow)
    end
  end

  context "with a workflow" do
    setup do
      @workflow = Factory.create(:workflow)
      @workflow.grant(@person)
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @workflow.id
      end

      should_respond_with :success
      should_assign_to :workflow
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_name = "Less awesome, more work"
        put :update, :id => @workflow.id, :workflow => { :name => @new_name }
      end

      should_respond_with :redirect
      should_assign_to :workflow
      should_not_set_the_flash

      should "update the workflow" do
        assert_equal @new_name, assigns(:workflow).name
        @workflow.reload
        assert_equal @new_name, @workflow.name
      end

      should "redirect back to the workflow" do
        assert_redirected_to @workflow
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Workflow.count
        delete :destroy, :id => @workflow.id
      end

      should_respond_with :redirect
      should_assign_to :workflow
      should_not_set_the_flash

      should "destroy a workflow" do
        assert_equal @old_count - 1, Workflow.count
      end

      should "redirect back to the workflow list" do
        assert_redirected_to workflows_path
      end
    end
  end
end
