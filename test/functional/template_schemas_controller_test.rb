require File.dirname(__FILE__) + '/../test_helper'
require 'template_schemas_controller'

# Re-raise errors caught by the controller.
class TemplateSchemasController; def rescue_action(e) raise e end; end

class TemplateSchemasControllerTest < ActionController::TestCase
  fixtures :template_schemas

  def setup
    @controller = TemplateSchemasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:template_schemas)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_template_schema
    old_count = TemplateSchema.count
    post :create, :template_schema => { }
    assert_equal old_count+1, TemplateSchema.count
    
    assert_redirected_to template_schema_path(assigns(:template_schema))
  end

  def test_should_show_template_schema
    get :show, :id => 1
    assert_response :success
  end

  def test_should_update_template_schema
    put :update, :id => 1, :template_schema => { }
    assert_redirected_to template_schema_path(assigns(:template_schema))
  end
  
  def test_should_destroy_template_schema
    old_count = TemplateSchema.count
    delete :destroy, :id => 1
    assert_equal old_count-1, TemplateSchema.count
    
    assert_redirected_to template_schemas_path
  end
end
