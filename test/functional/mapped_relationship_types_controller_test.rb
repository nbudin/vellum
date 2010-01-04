require 'test_helper'

class MappedRelationshipTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mapped_relationship_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mapped_relationship_type" do
    assert_difference('MappedRelationshipType.count') do
      post :create, :mapped_relationship_type => { }
    end

    assert_redirected_to mapped_relationship_type_path(assigns(:mapped_relationship_type))
  end

  test "should show mapped_relationship_type" do
    get :show, :id => mapped_relationship_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mapped_relationship_types(:one).to_param
    assert_response :success
  end

  test "should update mapped_relationship_type" do
    put :update, :id => mapped_relationship_types(:one).to_param, :mapped_relationship_type => { }
    assert_redirected_to mapped_relationship_type_path(assigns(:mapped_relationship_type))
  end

  test "should destroy mapped_relationship_type" do
    assert_difference('MappedRelationshipType.count', -1) do
      delete :destroy, :id => mapped_relationship_types(:one).to_param
    end

    assert_redirected_to mapped_relationship_types_path
  end
end
