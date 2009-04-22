require 'test_helper'

class RelationshipTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationship_type" do
    assert_difference('RelationshipType.count') do
      post :create, :relationship_type => { }
    end

    assert_redirected_to relationship_type_path(assigns(:relationship_type))
  end

  test "should show relationship_type" do
    get :show, :id => relationship_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => relationship_types(:one).to_param
    assert_response :success
  end

  test "should update relationship_type" do
    put :update, :id => relationship_types(:one).to_param, :relationship_type => { }
    assert_redirected_to relationship_type_path(assigns(:relationship_type))
  end

  test "should destroy relationship_type" do
    assert_difference('RelationshipType.count', -1) do
      delete :destroy, :id => relationship_types(:one).to_param
    end

    assert_redirected_to relationship_types_path
  end
end
