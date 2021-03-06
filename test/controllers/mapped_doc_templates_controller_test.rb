require 'test_helper'

class MappedDocTemplatesControllerTest < ActionController::TestCase
  setup do
    create_logged_in_person
    @doc_template = FactoryGirl.create(:doc_template)
    @project = @doc_template.project
    @project.project_memberships.create(:person => @person, :admin => true, :author => true)
    @map = FactoryGirl.create(:map, :project => @project)

    @referer = "http://back.com"
    @request.env["HTTP_REFERER"] = @referer
  end

  describe "on POST to :create" do
    setup do
      @old_count = MappedDocTemplate.count

      post :create, :project_id => @project.id, :map_id => @map.id,
        :doc_template_id => @doc_template.id
    end

    it "should respond correctly" do
      must respond_with(:redirect)
      wont set_flash
    end

    it "should create a mapped doc template" do
      assert_equal @old_count + 1, MappedDocTemplate.count
      assert @map.mapped_doc_templates.all.include?(assigns(:mapped_doc_template))
    end

    it "should redirect to referer" do
      assert_redirected_to @referer
    end
  end

  describe "with a mapped structure template" do
    setup do
      @mdt = @map.mapped_doc_templates.create(:doc_template => @doc_template)
    end

    describe "on PUT to :update" do
      setup do
        put :update, :id => @mdt.id, :map_id => @mdt.map.id, :project_id => @mdt.map.project.id,
          :mapped_doc_template => { :color => "black" }
      end

      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should update the mapped doc template" do
        assert_equal "black", assigns(:mapped_doc_template).color
        @mdt.reload
        assert_equal "black", @mdt.color
      end

      it "should redirect to referer" do
        assert_redirected_to @referer
      end
    end

    describe "on DELETE to :destroy" do
      setup do
        @old_count = MappedDocTemplate.count
        delete :destroy, :id => @mdt.id, :map_id => @mdt.map.id, :project_id => @mdt.map.project.id
      end
      
      it "should respond correctly" do
        must respond_with(:redirect)
        wont set_flash
      end

      it "should destroy a mapped doc template" do
        assert_equal @old_count - 1, MappedDocTemplate.count
      end
    end
  end
end
