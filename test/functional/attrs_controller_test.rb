require File.dirname(__FILE__) + '/../test_helper'
require 'attrs_controller'

# Re-raise errors caught by the controller.
class AttrsController; def rescue_action(e) raise e end; end

class AttrsControllerTest < ActionController::TestCase
  fixtures :attrs, :structure_templates, :template_schemas

  def setup
    @controller = AttrsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    tmpl = structure_templates(:person)
    get :index, :structure_template_id => tmpl.id, 
      :template_schema_id => tmpl.template_schema.id
    assert_response :success
    assert assigns(:attrs)
  end

  def test_should_get_new
    tmpl = structure_templates(:person)
    get :new, :structure_template_id => tmpl.id, 
      :template_schema_id => tmpl.template_schema.id
    assert_response :success
  end
  
  def test_should_create_attr
    old_count = Attr.count
    tmpl = structure_templates(:person)
    post :create, :attr => { :name => "test" }, :structure_template_id => tmpl.id, 
      :template_schema_id => tmpl.template_schema.id, :config_class => "TextField"
    assert_equal old_count+1, Attr.count
    
    assert_redirected_to structure_template_path(tmpl.template_schema, tmpl)
  end

  def test_should_show_attr
    attr = attrs(:name)
    get :show, :id => attr.id, 
      :template_schema_id => attr.structure_template.template_schema.id,
      :structure_template_id => attr.structure_template.id
    assert_response :success
  end

  def test_should_update_attr
    attr = attrs(:name)
    put :update, :id => attr.id, :attr => { :name => "SomethingElse" },
      :template_schema_id => attr.structure_template.template_schema.id,
      :structure_template_id => attr.structure_template.id,
      :format => :xml
    assert_response :success
  end
  
  def test_should_destroy_attr
    old_count = Attr.count
    attr = attrs(:name)
    delete :destroy, :id => attr.id, 
      :structure_template_id => attr.structure_template.id, 
      :template_schema_id => attr.structure_template.template_schema.id
    assert_equal old_count-1, Attr.count
    
    assert_redirected_to structure_template_path(attr.structure_template.template_schema,
      attr.structure_template)
  end
end
