require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    @project = FactoryGirl.create(:project)
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
  end

  describe "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end

    it "should respond correctly" do
      must respond_with(:success)
      must render_template("index")
    end
  end

  describe "on POST to :create" do
    setup do
      @old_count = Map.count
      post :create, :project_id => @project.id, :map => { :name => "My map" }
    end

    it "should respond correctly" do
      must respond_with(:redirect)
      wont set_flash
    end

    it "should create map" do
      assert_equal @old_count + 1, Map.count
      assert_redirected_to map_path(@project, assigns(:map))
    end
  end

  describe "with a map" do
    setup do
      @map = @project.maps.create :name => "A map"
    end

    describe "on GET to :show" do
      setup do
        get :show, :project_id => @project.id, :id => @map.id
      end

      it "should respond correctly" do
        must respond_with(:success)
        must render_template("show")
      end
    end

    describe "on PUT to :update" do
      setup do
        put :update, :project_id => @project.id, :id => @map.id, :map => { :name => "Renamed" }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should update the map" do
        assert_equal "Renamed", assigns(:map).name
      end

      it "should redirect back to the map" do
        assert_redirected_to map_path(@project, assigns(:map))
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = Map.count
        delete :destroy, :project_id => @project.id, :id => @map.id
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
        must redirect_to("the map list") { maps_path @project }
      end

      it "should destroy a map" do
        assert_equal @old_count - 1, Map.count
      end
    end
  end
end
