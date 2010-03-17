require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      get :index
    end

    should_respond_with :success
    should_assign_to :projects
    should_render_template "index"
  end

  context "on GET to :new" do
    setup do
      get :new
    end

    should_respond_with :success
    should_render_template "new"
  end

  context "on POST to :create with project" do
    setup do
      @old_count = Project.count
      post :create, { :project => { :name => "My project" }}
    end

    should_respond_with :redirect
    should_assign_to :project
    should_not_set_the_flash

    should "create a project" do
      assert_equal @old_count + 1, Project.count
    end

    should "redirect to the project" do
      assert_redirected_to project_url(assigns(:project))
    end

    should "grant permissions to the logged in user" do
      assert @person.permitted?(assigns(:project), 'edit')
    end
  end

  context "with project" do
    setup do
      @project = Factory.create(:project)
      @project.grant(@person)
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @project.id
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :project
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @project.id
      end

      should_respond_with :success
      should_render_template :edit
      should_assign_to :project
    end

    context "on PUT to :update" do
      setup do
        put :update, :id => @project.id, :project => { :name => "New name" }
      end

      should_respond_with :redirect
      should_assign_to :project
      should_not_set_the_flash

      should "update the project" do
        assert_equal "New name", assigns(:project).name
      end

      should "redirect back to the project" do
        assert_redirected_to project_url(assigns(:project))
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Project.count
        delete :destroy, :id => @project.id
      end

      should_respond_with :redirect
      should_assign_to :project
      should_not_set_the_flash

      should "destroy the project" do
        assert_equal @old_count - 1, Project.count
      end

      should "redirect back to the project list" do
        assert_redirected_to projects_url
      end
    end
  end
end
