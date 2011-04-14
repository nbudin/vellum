require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      get :index
    end

    should respond_with(:success)
    should assign_to(:projects)
    should render_template("index")
  end

  context "on GET to :new" do
    setup do
      get :new
    end

    should respond_with(:success)
    should render_template("new")
  end

  context "on POST to :create with project" do
    setup do
      @old_count = Project.count
      post :create, { :project => { :name => "My project" }}
    end

    should respond_with(:redirect)
    should assign_to(:project)
    should_not set_the_flash

    should "create a project" do
      assert_equal @old_count + 1, Project.count
    end

    should "redirect to the project" do
      assert_redirected_to project_url(assigns(:project))
    end

    should "grant permissions to the logged in user" do
      ability = Ability.new(@person)
      %w{read update destroy}.each do |action|
        assert ability.can?(action.to_sym, assigns(:project))
      end
    end
  end

  context "with project" do
    setup do
      @project = Factory.create(:project)
      @project.project_memberships.create(:person => @person, :author => true, :admin => true)
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @project.id
      end

      should respond_with(:success)
      should render_template(:show)
      should assign_to(:project)
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @project.id
      end

      should respond_with(:success)
      should render_template(:edit)
      should assign_to(:project)
    end

    context "on PUT to :update" do
      setup do
        put :update, :id => @project.id, :project => { :name => "New name" }
      end

      should respond_with(:redirect)
      should assign_to(:project)
      should_not set_the_flash

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

      should respond_with(:redirect)
      should assign_to(:project)
      should_not set_the_flash

      should "destroy the project" do
        assert_equal @old_count - 1, Project.count
      end

      should "redirect back to the project list" do
        assert_redirected_to projects_url
      end
    end
  end
end
