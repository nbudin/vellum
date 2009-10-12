require 'test_helper'

class MappedStructureTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mapped_structure_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mapped_structure_template" do
    assert_difference('MappedStructureTemplate.count') do
      post :create, :mapped_structure_template => { }
    end

    assert_redirected_to mapped_structure_template_path(assigns(:mapped_structure_template))
  end

  test "should show mapped_structure_template" do
    get :show, :id => mapped_structure_templates(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mapped_structure_templates(:one).to_param
    assert_response :success
  end

  test "should update mapped_structure_template" do
    put :update, :id => mapped_structure_templates(:one).to_param, :mapped_structure_template => { }
    assert_redirected_to mapped_structure_template_path(assigns(:mapped_structure_template))
  end

  test "should destroy mapped_structure_template" do
    assert_difference('MappedStructureTemplate.count', -1) do
      delete :destroy, :id => mapped_structure_templates(:one).to_param
    end

    assert_redirected_to mapped_structure_templates_path
  end
end
