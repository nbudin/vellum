require 'test_helper'

class MappedStructureTemplatesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    @structure_template = Factory.create(:structure_template)
    @project = Factory.create(:project, :template_schema => @structure_template.template_schema)
    @project.grant(@person)
    @map = Factory.create(:map, :project => @project)

    @referer = "http://back.com"
    @request.env["HTTP_REFERER"] = @referer
  end

  context "on POST to :create" do
    setup do
      @old_count = MappedStructureTemplate.count

      post :create, :project_id => @project.id, :map_id => @map.id,
        :structure_template_id => @structure_template.id
    end

    should_assign_to :mapped_structure_template
    should_respond_with :redirect
    should_not_set_the_flash

    should "create a mapped structure template" do
      assert_equal @old_count + 1, MappedStructureTemplate.count
      assert @map.mapped_structure_templates.all.include?(assigns(:mapped_structure_template))
    end

    should "redirect to referer" do
      assert_redirected_to @referer
    end
  end

  context "with a mapped structure template" do
    setup do
      @mrt = @map.mapped_structure_templates.create(:structure_template => @structure_template)
    end

    context "on PUT to :update" do
      setup do
        put :update, :id => @mrt.id, :map_id => @mrt.map.id, :project_id => @mrt.map.project.id,
          :mapped_structure_template => { :color => "black" }
      end

      should_assign_to :mapped_structure_template
      should_respond_with :redirect
      should_not_set_the_flash

      should "update the mapped structure template" do
        assert_equal "black", assigns(:mapped_structure_template).color
        @mrt.reload
        assert_equal "black", @mrt.color
      end

      should "redirect to referer" do
        assert_redirected_to @referer
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = MappedStructureTemplate.count
        delete :destroy, :id => @mrt.id, :map_id => @mrt.map.id, :project_id => @mrt.map.project.id
      end

      should_assign_to :mapped_structure_template
      should_respond_with :redirect
      should_not_set_the_flash

      should "destroy a mapped structure template" do
        assert_equal @old_count - 1, MappedStructureTemplate.count
      end
    end
  end
end
