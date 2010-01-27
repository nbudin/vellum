require 'test_helper'

class RelationshipTypesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @project = Factory.create(:project)
    @project.grant(@person)
  end

  context "on POST to :create" do
    setup do
      @a = @project.structure_templates.create(:name => "A")
      @b = @project.structure_templates.create(:name => "B")

      @old_count = RelationshipType.count
      post :create, :project_id => @project.id, :relationship_type => {
        :left_template_id => @a.id,
        :right_template_id => @b.id,
        :left_description => "is related to"
      }
    end

    should_assign_to :relationship_type
    should_respond_with :redirect
    should_not_set_the_flash

    should "create a relationship type" do
      assert_equal @old_count + 1, RelationshipType.count
    end

    should "redirect to the new relationship type" do
      assert_redirected_to relationship_type_path(@project, assigns(:relationship_type))
    end
  end

  context "with a relationship type" do
    setup do
      @rt = Factory.create(:relationship_type, :project => @project)
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @rt.id, :project_id => @project.id
      end

      should_assign_to :relationship_type
      should_respond_with :success
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_desc = "is taller than"
        put :update, :id => @rt.id, :project_id => @project.id,
          :relationship_type => { :left_description => @new_desc }
      end

      should_assign_to :relationship_type
      should_respond_with :redirect
      should_not_set_the_flash

      should "update the relationship type" do
        assert_equal @new_desc, assigns(:relationship_type).left_description
        @rt.reload
        assert_equal @new_desc, @rt.left_description
      end

      should "redirect to the relationship type" do
        assert_redirected_to relationship_type_path(@project, @rt)
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = RelationshipType.count
        delete :destroy, :id => @rt.id, :project_id => @project.id
      end

      should_assign_to :relationship_type
      should_respond_with :redirect
      should_not_set_the_flash

      should "destroy a relationship type" do
        assert_equal @old_count - 1, RelationshipType.count
      end
    end
  end
end
