require File.dirname(__FILE__) + '/../test_helper'
require 'structure_templates_controller'

# Re-raise errors caught by the controller.
class StructureTemplatesController; def rescue_action(e) raise e end; end

class StructureTemplatesControllerTest < ActionController::TestCase
  fixtures :structure_templates, :template_schemas

  def setup
    @controller = StructureTemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @schema = template_schemas(:one)
  end

  def teardown
    @schema = nil
  end

  def test_should_get_index
    get :index, :template_schema_id => @schema.id
    assert_response :success
    assert assigns(:structure_templates)
  end

  def test_should_get_new
    get :new, :template_schema_id => @schema.id
    assert_response :success
  end
  
  def test_should_create_structure_template
    old_count = StructureTemplate.count
    post :create, :template_schema_id => @schema.id, :structure_template => { }
    assert_equal old_count+1, StructureTemplate.count
    
    assert_redirected_to structure_template_path(@schema, assigns['structure_template'])
  end

  def test_should_show_structure_template
    get :show, :template_schema_id => @schema.id, :id => 1
    assert_response :success
  end

  def test_should_update_structure_template
    put :update, :template_schema_id => @schema.id, :id => 1, :structure_template => { }
    assert_redirected_to structure_template_path(@schema, assigns['structure_template'])
  end
  
  def test_should_destroy_structure_template
    old_count = StructureTemplate.count
    delete :destroy, :template_schema_id => @schema.id, :id => 1
    assert_equal old_count-1, StructureTemplate.count
    
    assert_redirected_to structure_templates_path
  end
end
