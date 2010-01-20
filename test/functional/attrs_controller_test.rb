require File.dirname(__FILE__) + '/../test_helper'
require 'attrs_controller'

# Re-raise errors caught by the controller.
class AttrsController; def rescue_action(e) raise e end; end

class AttrsControllerTest < ActionController::TestCase
  fixtures :attrs, :structure_templates, :template_schemas

  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      @tmpl = Factory.create(:structure_template)
      @tmpl.template_schema.grant(@person)

      get :index, :structure_template_id => @tmpl.id,
        :template_schema_id => @tmpl.template_schema.id
    end

    should_assign_to :attrs
    should_respond_with :success
  end

  context "on GET to :new for an attr" do
    setup do
      @tmpl = Factory.create(:structure_template)
      get :new, :structure_template_id => @tmpl.id,
        :template_schema_id => @tmpl.template_schema.id
    end

    should_assign_to :structure_template
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create for an attr" do
    setup do
      @old_count = Attr.count
      @tmpl = Factory.create(:structure_template)
      post :create, :attr => { :name => "test" },
        :structure_template_id => @tmpl.id,
        :template_schema_id => @tmpl.template_schema.id,
        :config_class => "TextField"
    end
    
    should_assign_to :attr
    should_respond_with :redirect
    should_not_set_the_flash

    should "create an attr" do
      assert_equal @old_count + 1, Attr.count
      assert_equal "test", assigns(:attr).name
    end

    should "redirect back to the template" do
      assert_redirected_to structure_template_path(@tmpl.template_schema, @tmpl)
    end
  end

  context "on GET to :show.json for an attr" do
    setup do
      @attr = Factory.create(:attr)
      @attr.structure_template.template_schema.grant(@person)
      get :show, :id => @attr.id,
        :structure_template_id => @attr.structure_template.id,
        :template_schema_id => @attr.structure_template.template_schema.id,
        :format => 'json'
    end

    should_assign_to :attr
    should_respond_with :success
    should_not_set_the_flash

    should "respond with valid JSON" do
      @obj = begin
        JSON.parse(@response.body)
      rescue
      end
      assert @obj, "Response body (#{@response.body}) is not valid JSON"
      assert_equal @attr.id, @obj["id"]
    end
  end

  context "on PUT to :update for an attr" do
    setup do
      @attr = Factory.create(:attr)
      @attr.structure_template.template_schema.grant(@person)
    
      put :update, :id => @attr.id, :attr => { :name => "SomethingElse" },
        :template_schema_id => @attr.structure_template.template_schema.id,
        :structure_template_id => @attr.structure_template.id,
        :format => 'xml'
    end

    should_assign_to :attr
    should_respond_with :success
    should_not_set_the_flash

    should "update the attr's fields" do
      @attr.reload
      assert_equal "SomethingElse", @attr.name
    end
  end
  
  context "on DELETE to :destroy for an attr" do
    setup do
      @attr = Factory.create(:attr)
      @attr.structure_template.template_schema.grant(@person)

      @old_count = Attr.count
      
      delete :destroy, :id => @attr.id,
        :structure_template_id => @attr.structure_template.id,
        :template_schema_id => @attr.structure_template.template_schema.id
    end

    should_assign_to :attr
    should_respond_with :redirect
    should_not_set_the_flash

    should "destroy an attr" do
      assert_equal @old_count - 1, Attr.count
    end

    should "redirect back to the template" do
      assert_redirected_to structure_template_path(@attr.structure_template.template_schema, @attr.structure_template)
    end
  end
end
