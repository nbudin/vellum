require File.dirname(__FILE__) + '/../test_helper'
require 'structures_controller'

# Re-raise errors caught by the controller.
class StructuresController; def rescue_action(e) raise e end; end

class StructuresControllerTest < ActionController::TestCase
  fixtures :structures

  def setup
    @controller = StructuresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:structures)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_structure
    old_count = Structure.count
    post :create, :structure => { }
    assert_equal old_count+1, Structure.count
    
    assert_redirected_to structure_path(assigns(:structure))
  end

  def test_should_show_structure
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_structure
    put :update, :id => 1, :structure => { }
    assert_redirected_to structure_path(assigns(:structure))
  end
  
  def test_should_destroy_structure
    old_count = Structure.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Structure.count
    
    assert_redirected_to structures_path
  end
end
