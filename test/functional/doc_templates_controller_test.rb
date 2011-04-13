require 'test_helper'

class DocTemplatesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @project = Factory.create(:project)
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
  end

  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end

    should respond_with(:success)
    should assign_to(:doc_templates)
    should render_template("index")
  end

  context "on GET to :index.json" do
    setup do
      get :index, :project_id => @project.id, :format => "json"
    end

    should respond_with(:success)
    should assign_to(:doc_templates)
    should_respond_with_json
  end

  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end

    should respond_with(:success)
    should assign_to(:doc_template)
    should render_template("new")
  end

  context "on POST to :create" do
    setup do
      @old_count = DocTemplate.count
      post :create, :project_id => @project.id,
        :doc_template => { :name => "Car" }
    end

    should respond_with(:redirect)
    should assign_to(:doc_template)
    should_not set_the_flash

    should "create a doc template" do
      assert_equal @old_count + 1, DocTemplate.count
    end

    should "redirect to the new doc template" do
      assert_redirected_to doc_template_path(@project, assigns(:doc_template))
    end
  end

  context "with a doc template" do
    setup do
      @tmpl = Factory.create(:doc_template, :project => @project)
    end

    context "on GET to :show" do
      setup do
        get :show, :project_id => @project.id, :id => @tmpl.id
      end

      should respond_with(:success)
      should assign_to(:doc_template)
      should render_template("show")
    end

    context "on PUT to :update" do
      setup do
        @new_name = "A different name"

        put :update, :project_id => @project.id, :id => @tmpl.id,
          :doc_template => { :name => @new_name }
      end

      should respond_with(:redirect)
      should assign_to(:doc_template)
      should_not set_the_flash

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
        @old_count = DocTemplate.count
        delete :destroy, :project_id => @project.id, :id => @tmpl.id
      end

      should respond_with(:redirect)
      should assign_to(:doc_template)
      should_not set_the_flash
      should redirect_to("the template list") { doc_templates_path(@project) }

      should "destroy a template" do
        assert_equal @old_count - 1, DocTemplate.count
      end
    end
  end
end
