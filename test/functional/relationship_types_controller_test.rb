require 'test/test_helper'

class RelationshipTypesControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person

    @project = Factory.create(:project)
    @project.project_memberships.create(:person => @person, :author => true)
  end
  
  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    should assign_to(:relationship_type)
    should render_template(:choose_templates)
  end
  
  context "on POST to :create without templates" do
    setup do
      @old_count = RelationshipType.count
      post :create, :project_id => @project.id, :relationship_type => {
        :left_description => "is related to"
      }
    end

    should assign_to(:relationship_type)
    should render_template(:choose_templates)
    should_not set_the_flash

    should "not create a relationship type" do
      assert_equal @old_count, RelationshipType.count
    end
  end
  
  context "with templates" do
    setup do
      @a = @project.doc_templates.create(:name => "A")
      @b = @project.doc_templates.create(:name => "B")
    end
    
    context "on GET to :new" do
      setup do      
        get :new, :project_id => @project.id, :relationship_type => {
          :left_template_id => @a.id,
          :right_template_id => @b.id
        }
      end
      
      should assign_to(:relationship_type)
      should render_template(:new)
    end
  
    context "on POST to :create" do
      setup do
        @old_count = RelationshipType.count
        post :create, :project_id => @project.id, :relationship_type => {
          :left_template_id => @a.id,
          :right_template_id => @b.id,
          :left_description => "is related to"
        }
      end
  
      should assign_to(:relationship_type)
      should respond_with(:redirect)
      should_not set_the_flash
  
      should "create a relationship type" do
        assert_equal @old_count + 1, RelationshipType.count
      end
  
      should "redirect to the left template" do
        assert_redirected_to doc_template_path(@project, @a)
      end
    end
  end
  
  context "with a relationship type" do
    setup do
      @rt = Factory.create(:relationship_type, :project => @project)
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @rt.id, :project_id => @project.id
      end

      should assign_to(:relationship_type)
      should respond_with(:success)
      should render_template("edit")
    end

    context "on PUT to :update" do
      setup do
        @new_desc = "is taller than"
        put :update, :id => @rt.id, :project_id => @project.id,
          :relationship_type => { :left_description => @new_desc }
      end

      should assign_to(:relationship_type)
      should respond_with(:redirect)
      should_not set_the_flash

      should "update the relationship type" do
        assert_equal @new_desc, assigns(:relationship_type).left_description
        @rt.reload
        assert_equal @new_desc, @rt.left_description
      end

      should "redirect to the left template" do
        assert_redirected_to doc_template_path(@project, @rt.left_template)
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = RelationshipType.count
        delete :destroy, :id => @rt.id, :project_id => @project.id
      end

      should assign_to(:relationship_type)
      should respond_with(:redirect)
      should_not set_the_flash

      should "destroy a relationship type" do
        assert_equal @old_count - 1, RelationshipType.count
      end
    end
  end
end
