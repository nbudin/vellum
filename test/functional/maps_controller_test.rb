require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    @project = Factory.create(:project)
    @project.grant(@person)
  end

  context "on POST to :create" do
    setup do
      @old_count = Map.count
      post :create, :project_id => @project.id, :map => { :name => "My map" }
    end

    should_assign_to :map
    should_respond_with :redirect
    should_not_set_the_flash

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

      should_assign_to :map
      should_respond_with :success
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        put :update, :project_id => @project.id, :id => @map.id, :map => { :name => "Renamed" }
      end

      should_assign_to :map
      should_respond_with :redirect
      should_not_set_the_flash

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

      should_assign_to :map
      should_respond_with :redirect
      should_not_set_the_flash

      should "destroy a map" do
        assert_equal @old_count - 1, Map.count
      end

      should "redirect back to the project" do
        assert_redirected_to project_path(@project)
      end
    end
  end
end
