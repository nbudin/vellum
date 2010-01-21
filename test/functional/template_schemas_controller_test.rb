require 'test_helper'

class TemplateSchemasControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      get :index
    end

    should_respond_with :success
    should_assign_to :template_schemas
    should_render_template "index"
  end

  context "on POST to :create" do
    setup do
      @old_count = TemplateSchema.count
      @name = "My super cool templates"
      post :create, :template_schema => { :name => @name }
    end

    should_respond_with :redirect
    should_assign_to :template_schema
    should_not_set_the_flash

    should "create a schema with permissions for the logged in person" do
      assert_equal @old_count + 1, TemplateSchema.count
      assert @person.permitted?(assigns(:template_schema), "edit")
    end

    should "redirect to the new schema" do
      assert_redirected_to assigns(:template_schema)
    end
  end

  context "with a schema" do
    setup do
      @schema = Factory.create(:template_schema)
      @schema.grant(@person)
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @schema.id
      end

      should_respond_with :success
      should_assign_to :template_schema
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_name = "Less awesome, more templates"
        put :update, :id => @schema.id, :template_schema => { :name => @new_name }
      end

      should_respond_with :redirect
      should_assign_to :template_schema
      should_not_set_the_flash

      should "update the schema" do
        assert_equal @new_name, assigns(:template_schema).name
        @schema.reload
        assert_equal @new_name, @schema.name
      end

      should "redirect back to the schema" do
        assert_redirected_to @schema
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = TemplateSchema.count
        delete :destroy, :id => @schema.id
      end

      should_respond_with :redirect
      should_assign_to :template_schema
      should_not_set_the_flash

      should "destroy a schema" do
        assert_equal @old_count - 1, TemplateSchema.count
      end

      should "redirect back to the schema list" do
        assert_redirected_to template_schemas_path
      end
    end
  end
end
