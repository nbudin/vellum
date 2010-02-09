require 'test_helper'

class StructureTemplatesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @project = Factory.create(:project)
    @project.grant(@person)
  end

  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end

    should_respond_with :success
    should_assign_to :structure_templates
    should_render_template "index"
  end

  context "on GET to :index.json" do
    setup do
      get :index, :project_id => @project.id, :format => "json"
    end

    should_respond_with :success
    should_assign_to :structure_templates
    should_respond_with_json
  end

  context "on POST to :create" do
    setup do
      @old_count = StructureTemplate.count
      post :create, :project_id => @project.id,
        :doc_template => { :name => "Car" }
    end

    should_respond_with :redirect
    should_assign_to :doc_template
    should_not_set_the_flash

    should "create a structure template" do
      assert_equal @old_count + 1, StructureTemplate.count
    end

    should "redirect to the new structure template" do
      assert_redirected_to doc_template_path(@project, assigns(:doc_template))
    end
  end

  context "with a structure template" do
    setup do
      @tmpl = Factory.create(:doc_template, :project => @project)
    end

    context "on GET to :show" do
      setup do
        get :show, :project_id => @project.id, :id => @tmpl.id
      end

      should_respond_with :success
      should_assign_to :doc_template
      should_render_template "show"
    end

    context "on PUT to :update" do
      setup do
        @new_name = "A different name"

        put :update, :project_id => @project.id, :id => @tmpl.id,
          :doc_template => { :name => @new_name }
      end

      should_respond_with :redirect
      should_assign_to :doc_template
      should_not_set_the_flash

      should "update the template" do
        assert_equal @new_name, assigns(:doc_template).name
        @tmpl.reload
        assert_equal @new_name, @tmpl.name
      end

      should "redirect to the template" do
        assert_redirected_to doc_template_path(@project, @tmpl)
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = StructureTemplate.count
        delete :destroy, :project_id => @project.id, :id => @tmpl.id
      end

      should_respond_with :redirect
      should_assign_to :doc_template
      should_not_set_the_flash
      should_redirect_to("the template list") { structure_templates_path(@project) }

      should "destroy a template" do
        assert_equal @old_count - 1, StructureTemplate.count
      end
    end
  end
end
