require 'test_helper'

class MappedRelationshipTypesControllerTest < ActionController::TestCase
  setup do
    create_logged_in_person
    @relationship_type = FactoryGirl.create(:relationship_type)
    @project = @relationship_type.project
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
    @map = FactoryGirl.create(:map, :project => @project)

    @referer = "http://back.com"
    @request.env["HTTP_REFERER"] = @referer
  end

  describe "on POST to :create" do
    setup do
      @old_count = MappedRelationshipType.count

      post :create, :project_id => @project.id, :map_id => @map.id,
        :relationship_type_id => @relationship_type.id
    end

    it "should respond correctly" do
      must respond_with(:redirect)
      wont set_flash
    end

    it "should create a mapped relationship type" do
      assert_equal @old_count + 1, MappedRelationshipType.count
      assert @map.mapped_relationship_types.all.include?(assigns(:mapped_relationship_type))
    end

    it "should redirect to referer" do
      assert_redirected_to @referer
    end
  end

  describe "with a mapped relationship type" do
    setup do
      @mrt = @map.mapped_relationship_types.create(:relationship_type => @relationship_type)
    end

    describe "on PUT to :update" do
      setup do
        put :update, :id => @mrt.id, :map_id => @mrt.map.id, :project_id => @mrt.map.project.id,
          :mapped_relationship_type => { :color => "black" }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should update the mapped relationship type" do
        assert_equal "black", assigns(:mapped_relationship_type).color
        @mrt.reload
        assert_equal "black", @mrt.color
      end

      it "should redirect to referer" do
        assert_redirected_to @referer
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = MappedRelationshipType.count
        delete :destroy, :id => @mrt.id, :map_id => @mrt.map.id, :project_id => @mrt.map.project.id
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should destroy a mapped relationship type" do
        assert_equal @old_count - 1, MappedRelationshipType.count
      end
    end
  end
end
