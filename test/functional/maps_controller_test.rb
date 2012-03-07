require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    @project = FactoryGirl.create(:project)
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
  end

  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end

    should assign_to(:maps)
    should respond_with(:success)
    should render_template("index")
  end

  context "on POST to :create" do
    setup do
      @old_count = Map.count
      post :create, :project_id => @project.id, :map => { :name => "My map" }
    end

    should assign_to(:map)
    should respond_with(:redirect)
    should_not set_the_flash

    should "create map" do
      assert_equal @old_count + 1, Map.count
      assert_redirected_to map_path(@project, assigns(:map))
    end
  end

  context "with a map" do
    setup do
      @map = @project.maps.create :name => "A map"
    end

    context "on GET to :show" do
      setup do
        get :show, :project_id => @project.id, :id => @map.id
      end

      should assign_to(:map)
      should respond_with(:success)
      should render_template("show")
    end

    context "on PUT to :update" do
      setup do
        put :update, :project_id => @project.id, :id => @map.id, :map => { :name => "Renamed" }
      end

      should assign_to(:map)
      should respond_with(:redirect)
      should_not set_the_flash

      should "update the map" do
        assert_equal "Renamed", assigns(:map).name
      end

      should "redirect back to the map" do
        assert_redirected_to map_path(@project, assigns(:map))
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Map.count
        delete :destroy, :project_id => @project.id, :id => @map.id
      end

      should assign_to(:map)
      should respond_with(:redirect)
      should_not set_the_flash
      should redirect_to("the map list") { maps_path @project }

      should "destroy a map" do
        assert_equal @old_count - 1, Map.count
      end
    end
  end
end
