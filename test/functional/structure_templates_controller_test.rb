require 'test_helper'

class StructureTemplatesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @schema = Factory.create(:template_schema)
    @schema.grant(@person)
  end

  context "on GET to :index.json" do
    setup do
      get :index, :template_schema_id => @schema.id, :format => "json"
    end

    should_respond_with :success
    should_assign_to :structure_templates
    should_respond_with_json
  end

  context "on GET to :new" do
    setup do
      get :new, :template_schema_id => @schema.id
    end

    should_respond_with :success
    should_assign_to :structure_template
    should_render_template "new"
  end

  context "on POST to :create" do
    setup do
      @old_count = StructureTemplate.count
      post :create, :template_schema_id => @schema.id,
        :structure_template => { :name => "Car" }
    end

    should_respond_with :redirect
    should_assign_to :structure_template
    should_not_set_the_flash

    should "create a structure template" do
      assert_equal @old_count + 1, StructureTemplate.count
    end

    should "redirect to the new structure template" do
      assert_redirected_to structure_template_path(@schema, assigns(:structure_template))
    end
  end

  context "with a structure template" do
    setup do
      @tmpl = Factory.create(:structure_template, :template_schema => @schema)
    end

    context "on GET to :show" do
      setup do
        get :show, :template_schema_id => @schema.id, :id => @tmpl.id
      end

      should_respond_with :success
      should_assign_to :structure_template
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_name = "A different name"

        put :update, :template_schema_id => @schema.id, :id => @tmpl.id,
          :structure_template => { :name => @new_name }
      end

      should_respond_with :redirect
      should_assign_to :structure_template
      should_not_set_the_flash

      should "update the template" do
        assert_equal @new_name, assigns(:structure_template).name
        @tmpl.reload
        assert_equal @new_name, @tmpl.name
      end

      should "redirect to the template" do
        assert_redirected_to structure_template_path(@schema, @tmpl)
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = StructureTemplate.count
        delete :destroy, :template_schema_id => @schema.id, :id => @tmpl.id
      end

      should_respond_with :redirect
      should_assign_to :structure_template
      should_not_set_the_flash

      should "destroy a template" do
        assert_equal @old_count - 1, StructureTemplate.count
      end

      should "redirect to the schema" do
        assert_redirected_to template_schema_path(@schema)
      end
    end
  end
end
