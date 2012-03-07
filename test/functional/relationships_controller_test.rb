require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @rt = FactoryGirl.create(:relationship_type)
    @project = @rt.project
    @project.project_memberships.create(:person => @person, :author => true)
    @left = FactoryGirl.create(:doc, :project => @project, :doc_template => @rt.left_template)
    @right = FactoryGirl.create(:doc, :project => @project, :doc_template => @rt.right_template)
  end

  context "on GET to :index.json" do
    setup do
      get :index, :format => "json", :project_id => @project.id
    end

    should respond_with(:success)
    should assign_to(:relationships)
    should respond_with_json
  end

  context "creating a new relationship" do
    setup do
      @referer = "http://xyzzy.com/plugh"
      @request.env["HTTP_REFERER"] = @referer
      @old_count = Relationship.count
    end

    context "on POST to :create" do
      setup do
        post :create, :project_id => @project.id, :relationship => {
          :relationship_type_id => @rt.id,
          :left_id => @left.id,
          :right_id => @right.id
        }
      end

      should respond_with(:redirect)
      should assign_to(:relationship)
      should_not set_the_flash

      should "create a relationship" do
        assert_equal @old_count + 1, Relationship.count
      end

      should "redirect back" do
        assert_redirected_to @referer
      end
    end

    context "and a new structure" do
      setup do
        @old_doc_count = Doc.count
      end

      context "on POST to :create with a new doc specified on the left" do
        setup do
          post :create, :project_id => @project.id, :relationship => {
            :relationship_type_id_and_source_direction => "#{@rt.id}_right",
            :target_id => "new",
            :source_id => @right.id
          }
        end

        should respond_with(:redirect)
        should assign_to(:relationship)
        should_not set_the_flash

        should "create a relationship and a doc" do
          assert_equal @old_count + 1, Relationship.count
          assert_equal @old_doc_count + 1, Doc.count
        end

        should "redirect to the new doc" do
          assert_redirected_to edit_doc_path(@project, assigns(:relationship).left)
        end
      end

      context "on POST to :create with a new doc specified on the right" do
        setup do
          post :create, :project_id => @project.id, :relationship => {
            :relationship_type_id_and_source_direction => "#{@rt.id}_left",
            :source_id => @left.id,
            :target_id => "new"
          }
        end

        should respond_with(:redirect)
        should assign_to(:relationship)
        should_not set_the_flash

        should "create a relationship and a structure" do
          assert_equal @old_count + 1, Relationship.count
          assert_equal @old_doc_count + 1, Doc.count
        end

        should "redirect to the new doc" do
          assert_redirected_to edit_doc_path(@project, assigns(:relationship).right)
        end
      end
    end
  end

  context "with a relationship" do
    setup do
      @relationship = FactoryGirl.create(:relationship, :project => @project, :relationship_type => @rt)
    end

    context "on PUT to :update.json" do
      setup do
        put :update, :id => @relationship.id, :project_id => @project.id,
          :relationship => { :left_id => @left.id },
          :format => "json"
      end

      should respond_with(:success)
      should assign_to(:relationship)

      should "update the relationship" do
        assert_equal @left.id, assigns(:relationship).left_id
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Relationship.count
        @referer = "http://asdfljaqwioer"
        @request.env["HTTP_REFERER"] = @referer
        delete :destroy, :id => @relationship.id, :project_id => @project.id
      end

      should respond_with(:redirect)
      should assign_to(:relationship)
      should_not set_the_flash

      should "destroy a relationship" do
        assert_equal @old_count - 1, Relationship.count
      end

      should "redirect to the referer" do
        assert_redirected_to @referer
      end
    end
  end
end
