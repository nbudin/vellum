require 'test_helper'

class DocTemplateAttrsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
  end

  context "on GET to :index" do
    setup do
      @tmpl = Factory.create(:doc_template)
      @tmpl.project.grant(@person)

      get :index, :doc_template_id => @tmpl.id, :project_id => @tmpl.project.id
    end

    should_assign_to :attrs
    should_respond_with :success
  end

  context "on GET to :new for an attr" do
    setup do
      @tmpl = Factory.create(:doc_template)
      get :new, :doc_template_id => @tmpl.id, :project_id => @tmpl.project.id
    end

    should_assign_to :doc_template
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
  end

  context "on POST to :create for an attr" do
    setup do
      @old_count = DocTemplateAttr.count
      @tmpl = Factory.create(:doc_template)
      post :create, :attr => { :name => "test" },
        :doc_template_id => @tmpl.id,
        :project_id => @tmpl.project.id,
        :ui_type => "text"
    end
    
    should_assign_to :attr
    should_respond_with :redirect
    should_not_set_the_flash
    should_redirect_to("the template") { doc_template_path(@tmpl.project, @tmpl) }

    should "create an attr" do
      assert_equal @old_count + 1, DocTemplateAttr.count
      assert_equal "test", assigns(:attr).name
    end
  end

  context "on GET to :show.json for an attr" do
    setup do
      @attr = Factory.create(:doc_template_attr)
      @attr.doc_template.project.grant(@person)
      get :show, :id => @attr.id,
        :doc_template_id => @attr.doc_template.id,
        :project_id => @attr.doc_template.project.id,
        :format => 'json'
    end

    should_assign_to :attr
    should_respond_with :success
    should_not_set_the_flash

    should "respond with valid JSON" do
      @obj = parse_json_response
      assert @obj, "Response body (#{@response.body}) is not valid JSON"
      assert_equal @attr.id, @obj["id"]
    end
  end

  context "on PUT to :update for an attr" do
    setup do
      @attr = Factory.create(:doc_template_attr)
      @attr.doc_template.project.grant(@person)
    
      put :update, :id => @attr.id, :attr => { :name => "SomethingElse" },
        :project_id => @attr.doc_template.project.id,
        :doc_template_id => @attr.doc_template.id,
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
      @attr = Factory.create(:doc_template_attr)
      @project = @attr.doc_template.project
      @project.grant(@person)

      @old_count = DocTemplateAttr.count
      
      delete :destroy, :id => @attr.id,
        :doc_template_id => @attr.doc_template.id,
        :project_id => @project.id
    end

    should_assign_to :attr
    should_respond_with :redirect
    should_not_set_the_flash

    should "destroy an attr" do
      assert_equal @old_count - 1, DocTemplateAttr.count
    end

    should "redirect back to the template" do
      assert_redirected_to doc_template_path(@project, @attr.doc_template)
    end
  end
end
