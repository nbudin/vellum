require File.dirname(__FILE__) + '/../test_helper'
require 'attrs_controller'

# Re-raise errors caught by the controller.
class AttrsController; def rescue_action(e) raise e end; end

class AttrsControllerTest < Test::Unit::TestCase
  fixtures :attrs

  def setup
    @controller = AttrsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:attrs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_attr
    old_count = Attr.count
    post :create, :attr => { }
    assert_equal old_count+1, Attr.count
    
    assert_redirected_to attr_path(assigns(:attr))
  end

  def test_should_show_attr
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_attr
    put :update, :id => 1, :attr => { }
    assert_redirected_to attr_path(assigns(:attr))
  end
  
  def test_should_destroy_attr
    old_count = Attr.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Attr.count
    
    assert_redirected_to attrs_path
  end
end
