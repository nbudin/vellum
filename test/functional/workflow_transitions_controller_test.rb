require 'test_helper'

class WorkflowTransitionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_transitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_transition" do
    assert_difference('WorkflowTransition.count') do
      post :create, :workflow_transition => { }
    end

    assert_redirected_to workflow_transition_path(assigns(:workflow_transition))
  end

  test "should show workflow_transition" do
    get :show, :id => workflow_transitions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => workflow_transitions(:one).to_param
    assert_response :success
  end

  test "should update workflow_transition" do
    put :update, :id => workflow_transitions(:one).to_param, :workflow_transition => { }
    assert_redirected_to workflow_transition_path(assigns(:workflow_transition))
  end

  test "should destroy workflow_transition" do
    assert_difference('WorkflowTransition.count', -1) do
      delete :destroy, :id => workflow_transitions(:one).to_param
    end

    assert_redirected_to workflow_transitions_path
  end
end
