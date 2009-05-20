require 'test_helper'

class WorkflowStepsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_steps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_step" do
    assert_difference('WorkflowStep.count') do
      post :create, :workflow_step => { }
    end

    assert_redirected_to workflow_step_path(assigns(:workflow_step))
  end

  test "should show workflow_step" do
    get :show, :id => workflow_steps(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => workflow_steps(:one).to_param
    assert_response :success
  end

  test "should update workflow_step" do
    put :update, :id => workflow_steps(:one).to_param, :workflow_step => { }
    assert_redirected_to workflow_step_path(assigns(:workflow_step))
  end

  test "should destroy workflow_step" do
    assert_difference('WorkflowStep.count', -1) do
      delete :destroy, :id => workflow_steps(:one).to_param
    end

    assert_redirected_to workflow_steps_path
  end
end
