require 'test_helper'

class DocsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    
    assert @attr = Factory.create(:doc_template_attr, :name => "Favorite color")
    assert @tmpl = @attr.doc_template
    assert @project = @tmpl.project
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
  end

  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id, :format => 'json'
    end

    should respond_with(:success)
    should assign_to(:docs)
    should respond_with_json
  end

  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id, :template_id => @tmpl.id
    end

    should respond_with(:success)
    should assign_to(:doc)
    should render_template("new")
  end

  context "on POST to :create" do
    setup do
      @old_count = Doc.count
      @name = "William"
      @color = "orange"
      post :create, { :project_id => @project.id, :template_id => @tmpl.id,
        :doc => {
          :name => @name,
          :attrs_attributes => [
            { 'name' => @attr.name, 'value' => @color }
          ]
        }
      }
    end

    should respond_with(:redirect)
    should assign_to(:doc)
    should_not set_the_flash

    should "create a doc with the appropriate attrs" do
      assert_equal @old_count + 1, Doc.count
      assert_equal @name, assigns(:doc).name
      assert_equal @color, assigns(:doc).attrs[@attr.name].value
    end

    should "set the creator and version author" do
      assert_equal @person.id, assigns(:doc).creator_id
      assert_equal @person.id, assigns(:doc).versions.first.author_id
    end

    should "redirect to the new doc" do
      assert_redirected_to doc_path(@project, assigns(:doc))
    end
  end

  context "with a doc" do
    setup do
      @name = "Melissa"
      @color = "purple"

      @doc = @project.docs.create(:name => @name, :doc_template => @tmpl,
        :position => 1)
      @doc.attrs[@attr.name].value = @color
      @doc.save
      @doc.reload
    end

    context "on GET to :index.json with the appropriate template" do
      setup do
        get :index, :project_id => @project.id, :template_id => @tmpl.id, :format => "json"
      end

      should respond_with(:success)
      should assign_to(:docs)
      should respond_with_json
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @doc.id, :project_id => @project.id
      end

      should respond_with(:success)
      should assign_to(:doc)
      should render_template("show")
    end
    
    context "on GET to :edit" do
      setup do
        get :edit, :id => @doc.id, :project_id => @project.id
      end
      
      should respond_with(:success)
      should assign_to(:doc)
      should render_template("edit")
    end

    context "on PUT to :update" do
      setup do
        @new_color = "turquoise"

        put :update, :id => @doc.id, :project_id => @project.id,
          :doc => {
            :attrs_attributes => [
              { 'name' => @attr.name, 'value' => @new_color }
            ]
          }
      end

      should respond_with(:redirect)
      should assign_to(:doc)
      should_not set_the_flash

      should "set the new version's author" do
        assert_equal @person.id, assigns(:doc).versions.latest.author_id
      end

      should "update the structure" do
        assert_equal @new_color, assigns(:doc).attrs[@attr.name].value
      end

      should "redirect back to the structure" do
        assert_redirected_to doc_path(@project, @doc)
      end
    end

    context "on PUT to :update with new assignee" do
      setup do
        assert @person.email
        assert_not_equal @person.id, @doc.assignee
        @site_settings = SiteSettings.instance
        @site_settings.site_name = "Test Site"
        @site_settings.site_email = "vellum@example.com"
        @site_settings.save

        put :update, :id => @doc.id, :project_id => @project.id,
          :doc => { :assignee_id => @person.id }
      end

      should assign_to(:doc)

      should "reassign the doc" do
        assert_equal @person.id, assigns(:doc).assignee.id
      end

      should have_sent_email do |email|
        email.subject =~ /\[#{@project.name}\]/ &&
          email.subject.include?(@doc.name) &&
          email.from.include?(@site_settings.site_email) &&
          email.to.include?(@person.primary_email_address) &&
          email.body.include?("assigned to you")
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Doc.count
        delete :destroy, :id => @doc.id, :project_id => @project.id
      end

      should respond_with(:redirect)
      should assign_to(:doc)
      should_not set_the_flash
      should redirect_to("the project") { project_path @project }

      should "destroy a doc" do
        assert_equal @old_count - 1, Doc.count
      end
    end

    context "and another structure" do
      setup do
        @d2 = @project.docs.create(:name => "Another", :doc_template => @tmpl,
          :position => 2)
      end

      context "on POST to :sort" do
        setup do
          assert @doc.position < @d2.position
          
          post :sort, :project_id => @project.id,
            "docs_#{@tmpl.id}".to_sym => [ @d2.id.to_s, @doc.id.to_s ]
        end

        should respond_with(:success)

        should "sort the docs" do
          @doc.reload
          @d2.reload

          assert @d2.position < @doc.position
        end
      end
    end
  end
end
