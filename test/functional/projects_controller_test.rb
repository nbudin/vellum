require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  describe "on GET to :index" do
    setup do
      get :index
    end

    it "should respond correctly" do
      must respond_with(:success)
      must render_template("index")
    end
  end

  describe "on GET to :new" do
    setup do
      get :new
    end

    it "should respond correctly" do
      must respond_with(:success)
      must render_template("new")
    end
  end

  describe "on POST to :create with project" do
    setup do
      @old_count = Project.count
      post :create, { :project => { :name => "My project" }}
    end

    it "should respond correctly" do
      must respond_with(:redirect)
      wont set_the_flash
    end

    it "should create a project" do
      assert_equal @old_count + 1, Project.count
    end

    it "should redirect to the project" do
      assert_redirected_to project_url(assigns(:project))
    end

    it "should grant permissions to the logged in user" do
      ability = Ability.new(@person)
      %w{read update destroy}.each do |action|
        assert ability.can?(action.to_sym, assigns(:project))
      end
    end
  end

  describe "with project" do
    setup do
      @project = FactoryGirl.create(:project)
      @project.project_memberships.create(:person => @person, :author => true, :admin => true)
    end

    describe "on GET to :show" do
      setup do
        get :show, :id => @project.id
      end

      it "should respond correctly" do
        must respond_with(:success)
        must render_template(:show)
      end
    end

    describe "on GET to :edit" do
      setup do
        get :edit, :id => @project.id
      end

      it "should respond correctly" do
        must respond_with(:success)
        must render_template(:edit)
      end
    end

    describe "on PUT to :update" do
      setup do
        put :update, :id => @project.id, :project => { :name => "New name" }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_the_flash
      end

      it "should update the project" do
        assert_equal "New name", assigns(:project).name
      end

      it "should redirect back to the project" do
        assert_redirected_to project_url(assigns(:project))
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = Project.count
        delete :destroy, :id => @project.id
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_the_flash
      end

      it "should destroy the project" do
        assert_equal @old_count - 1, Project.count
      end

      it "should redirect back to the project list" do
        assert_redirected_to projects_url
      end
    end
  end
end
