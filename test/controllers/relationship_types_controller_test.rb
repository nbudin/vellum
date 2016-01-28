require 'test_helper'

class RelationshipTypesControllerTest < ActionController::TestCase
  setup do
    create_logged_in_person

    @project = FactoryGirl.create(:project)
    @project.project_memberships.create(:person => @person, :author => true)
  end
  
  describe "on GET to :new" do
    setup do
      get :new, :project_id => @project.id
    end
    
    it "should respond correctly" do
      must render_template(:choose_templates)
    end
  end
  
  describe "on POST to :create without templates" do
    setup do
      @old_count = RelationshipType.count
      post :create, :project_id => @project.id, :relationship_type => {
        :left_description => "is related to"
      }
    end

    it "should respond correctly" do
      must render_template(:choose_templates)
      wont set_flash
    end

    it "should not create a relationship type" do
      assert_equal @old_count, RelationshipType.count
    end
  end
  
  describe "with templates" do
    setup do
      @a = @project.doc_templates.create(:name => "A")
      @b = @project.doc_templates.create(:name => "B")
    end
    
    describe "on GET to :new" do
      setup do      
        get :new, :project_id => @project.id, :relationship_type => {
          :left_template_id => @a.id,
          :right_template_id => @b.id
        }
      end
      
      it "should respond correctly" do
        must render_template(:new)
      end
    end
  
    describe "on POST to :create" do
      setup do
        @old_count = RelationshipType.count
        post :create, :project_id => @project.id, :relationship_type => {
          :left_template_id => @a.id,
          :right_template_id => @b.id,
          :left_description => "is related to"
        }
      end
  
      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end
  
      it "should create a relationship type" do
        assert_equal @old_count + 1, RelationshipType.count
      end
  
      it "should redirect to the left template" do
        assert_redirected_to doc_template_path(@project, @a)
      end
    end
  end
  
  describe "with a relationship type" do
    setup do
      @rt = FactoryGirl.create(:relationship_type, :project => @project)
    end

    describe "on GET to :edit" do
      setup do
        get :edit, :id => @rt.id, :project_id => @project.id
      end

      it "should respond correctly" do
        must respond_with(:success)
        must render_template("edit")
      end
    end

    describe "on PUT to :update" do
      setup do
        @new_desc = "is taller than"
        put :update, :id => @rt.id, :project_id => @project.id,
          :relationship_type => { :left_description => @new_desc }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should update the relationship type" do
        assert_equal @new_desc, assigns(:relationship_type).left_description
        @rt.reload
        assert_equal @new_desc, @rt.left_description
      end

      it "should redirect to the left template" do
        assert_redirected_to doc_template_path(@project, @rt.left_template)
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = RelationshipType.count
        delete :destroy, :id => @rt.id, :project_id => @project.id
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should destroy a relationship type" do
        assert_equal @old_count - 1, RelationshipType.count
      end
    end
  end
end
