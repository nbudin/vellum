require 'test_helper'

class DocTemplatesControllerTest < ActionController::TestCase
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

  describe "on GET to :index.json" do
    setup do
      get :index, :project_id => @project.id, :format => "json"
    end

    it "should respond correctly" do
      must respond_with(:success)
    end
  end

  describe "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end

    it "should respond correctly" do
      must respond_with(:success)
      must render_template("new")
    end
  end

  describe "on POST to :create" do
    setup do
      @old_count = DocTemplate.count
      post :create, :project_id => @project.id,
        :doc_template => { :name => "Car" }
    end

    it "should respond correctly" do
      must respond_with(:redirect)
      wont set_flash
    end

    it "should create a doc template" do
      assert_equal @old_count + 1, DocTemplate.count
    end

    it "should redirect to the new doc template" do
      assert_redirected_to doc_template_path(@project, assigns(:doc_template))
    end
  end

  describe "with a doc template" do
    setup do
      @tmpl = FactoryGirl.create(:doc_template, :project => @project)
    end

    describe "on GET to :show" do
      setup do
        get :show, :project_id => @project.id, :id => @tmpl.id
      end

      it "should respond correctly" do
        must respond_with(:success)
        must render_template("show")
      end
    end

    describe "on PUT to :update" do
      setup do
        @new_name = "A different name"

        put :update, :project_id => @project.id, :id => @tmpl.id,
          :doc_template => { :name => @new_name }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should update the template" do
        assert_equal @new_name, assigns(:doc_template).name
        @tmpl.reload
        assert_equal @new_name, @tmpl.name
      end

      it "should redirect to the template" do
        assert_redirected_to doc_template_path(@project, @tmpl)
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = DocTemplate.count
        delete :destroy, :project_id => @project.id, :id => @tmpl.id
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
        must redirect_to("the template list") { doc_templates_path(@project) }
      end

      it "should destroy a template" do
        assert_equal @old_count - 1, DocTemplate.count
      end
    end
  end
end
