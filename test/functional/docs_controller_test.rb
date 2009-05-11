require File.dirname(__FILE__) + '/../test_helper'
require 'docs_controller'

# Re-raise errors caught by the controller.
class DocsController; def rescue_action(e) raise e end; end

class DocsControllerTest < ActionController::TestCase
  fixtures :docs, :projects

  def setup
    @controller = DocsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:person] = Person.find(:first).id

    @project = projects(:people)
  end

  def teardown
    @project = nil
  end

  def test_should_get_index
    get :index, :project_id => @project.id
    assert_response :success
    assert assigns['docs']
  end

  def test_should_get_new
    get :new, :project_id => @project.id
    assert_response :success
  end
  
  def test_should_create_doc
    old_count = Doc.count
    post :create, :project_id => @project.id, :doc => { }
    assert_equal old_count+1, Doc.count
    
    assert_redirected_to doc_path(@project.id, assigns['doc'])
  end

  def test_should_show_doc
    get :show, :project_id => @project.id, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :project_id => @project.id, :id => 1
    assert_response :success
  end
  
  def test_should_update_doc
    put :update, :project_id => @project.id, :id => 1, :doc => { }
    assert_redirected_to doc_path(@project.id, assigns['doc'])
  end
  
  def test_should_destroy_doc
    old_count = Doc.count
    delete :destroy, :project_id => @project.id, :id => 1
    assert_equal old_count-1, Doc.count
    
    assert_redirected_to docs_path
  end
end
