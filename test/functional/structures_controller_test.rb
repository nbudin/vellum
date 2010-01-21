require 'test_helper'

class StructuresControllerTest < ActionController::TestCase
  def setup
    create_logged_in_person
    
    @field = Factory.create(:text_field)
    @attr_name = "Favorite color"
    @attr = Factory.create(:attr, :name => "Favorite color")
    @attr.attr_configuration = @field
    @attr.save!
    @tmpl = @attr.structure_template
    @schema = @tmpl.template_schema
    @schema.grant(@person)

    @project = Factory.create(:project, :template_schema => @schema)
    @project.grant(@person)
  end

  context "on GET to :index" do
    setup do
      get :index, :project_id => @project.id
    end

    should_respond_with :success
    should_assign_to :structures
  end

  context "on GET to :new" do
    setup do
      get :new, :project_id => @project.id, :template_id => @tmpl.id
    end

    should_respond_with :success
    should_assign_to :structure
    should_render_template "new"
  end

  context "on POST to :create" do
    setup do
      @old_count = Structure.count
      @name = "William"
      @color = "orange"
      post :create, { :project_id => @project.id, :template_id => @tmpl.id,
        :structure => {
          :name => @name,
          :attr_values => {
            @attr.id => {
              :value => @color
            }
          }
        }
      }
    end

    should_respond_with :redirect
    should_assign_to :structure
    should_not_set_the_flash

    should "create a structure with the appropriate attrs" do
      assert_equal @old_count + 1, Structure.count
      assert_equal @name, assigns(:structure).name
      assert_equal @color, assigns(:structure).attr_value(@attr).value
      assert_equal @color, assigns(:structure).attr_value(@attr_name).value
    end

    should "redirect to the new structure" do
      assert_redirected_to structure_path(@project, assigns(:structure))
    end
  end

  context "with a structure" do
    setup do
      @name = "Melissa"
      @color = "purple"

      @structure = @project.structures.create(:name => @name, :structure_template => @tmpl)
      @av = @structure.obtain_attr_value(@attr_name)
      @av.value = @color
      @av.save
      @structure.reload
    end

    context "on GET to :show" do
      setup do
        get :show, :id => @structure.id, :project_id => @project.id
      end

      should_respond_with :success
      should_assign_to :structure
      should_render_template "show"
    end
    
    context "on GET to :edit" do
      setup do
        get :edit, :id => @structure.id, :project_id => @project.id
      end
      
      should_respond_with :success
      should_assign_to :structure
      should_render_template "edit"
    end

    context "on PUT to :update" do
      setup do
        @new_color = "turquoise"

        put :update, :id => @structure.id, :project_id => @project.id,
          :structure => {
            :attr_values => {
              @attr.id => {
                :value => @new_color
              }
            }
          }
      end

      should_respond_with :redirect
      should_assign_to :structure
      should_not_set_the_flash

      should "update the structure" do
        assert_equal @new_color, assigns(:structure).attr_value(@attr).value
        assert_equal @new_color, assigns(:structure).attr_value(@attr_name).value
      end

      should "redirect back to the structure" do
        assert_redirected_to structure_path(@project, @structure)
      end
    end

    context "on DELETE to :destroy" do
      setup do
        @old_count = Structure.count
        delete :destroy, :id => @structure.id, :project_id => @project.id
      end

      should_respond_with :redirect
      should_assign_to :structure
      should_not_set_the_flash

      should "destroy a structure" do
        assert_equal @old_count - 1, Structure.count
      end

      should "redirect back to the project" do
        assert_redirected_to project_path(@project)
      end
    end
  end
end
