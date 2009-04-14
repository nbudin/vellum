require File.dirname(__FILE__) + '/../test_helper'
require 'structure_templates_controller'

# Re-raise errors caught by the controller.
class StructureTemplatesController; def rescue_action(e) raise e end; end

class StructureTemplatesControllerTest < ActionController::TestCase
  fixtures :structure_templates

  def setup
    @controller = StructureTemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:structure_templates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_structure_template
    old_count = StructureTemplate.count
    post :create, :structure_template => { }
    assert_equal old_count+1, StructureTemplate.count
    
    assert_redirected_to structure_template_path(assigns(:structure_template))
  end

  def test_should_show_structure_template
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_structure_template
    put :update, :id => 1, :structure_template => { }
    assert_redirected_to structure_template_path(assigns(:structure_template))
  end
  
  def test_should_destroy_structure_template
    old_count = StructureTemplate.count
    delete :destroy, :id => 1
    assert_equal old_count-1, StructureTemplate.count
    
    assert_redirected_to structure_templates_path
  end
end
