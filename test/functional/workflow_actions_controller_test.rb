require 'test_helper'

class WorkflowActionsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @workflow = Factory.create(:workflow)
    @workflow.grant(@person)
    @start = @workflow.workflow_steps.create(:name => "Start", :position => 1)
    @end = @workflow.workflow_steps.create(:name => "End", :position => 2)
    @transition = @start.leaving_transitions.create(:to => @end, :name => "Finish")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_action" do
    assert_difference('WorkflowAction.count') do
      post :create, :workflow_action => { }
    end

    assert_redirected_to workflow_action_path(assigns(:workflow_action))
  end

  test "should show workflow_action" do
    get :show, :id => workflow_actions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => workflow_actions(:one).to_param
    assert_response :success
  end

  test "should update workflow_action" do
    put :update, :id => workflow_actions(:one).to_param, :workflow_action => { }
    assert_redirected_to workflow_action_path(assigns(:workflow_action))
  end

  test "should destroy workflow_action" do
    assert_difference('WorkflowAction.count', -1) do
      delete :destroy, :id => workflow_actions(:one).to_param
    end

    assert_redirected_to workflow_actions_path
  end
end
