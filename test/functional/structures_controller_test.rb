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
    @project = @tmpl.project
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

      @structure = @project.structures.create(:name => @name, :structure_template => @tmpl,
        :position => 1)
      @av = @structure.obtain_attr_value(@attr_name)
      @av.value = @color
      @av.save
      @structure.reload
    end

    context "on GET to :index.json with the appropriate template" do
      setup do
        get :index, :project_id => @project.id, :template_id => @tmpl.id, :format => "json"
      end

      should_respond_with :success
      should_assign_to :structures
      should_respond_with_json
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

    context "on PUT to :update with new assignee" do
      setup do
        assert @person.primary_email_address
        @site_settings = SiteSettings.instance
        @site_settings.site_name = "Test Site"
        @site_settings.site_email = "vellum@example.com"
        @site_settings.save

        put :update, :id => @structure.id, :project_id => @project.id,
          :structure => { :assignee_id => @person.id }
      end

      should_assign_to :structure

      should "reassign the structure" do
        assert_equal @person.id, assigns(:structure).assignee.id
      end

      should "send email to the new assignee" do
        assert_sent_email do |email|
          email.subject =~ /\[#{@project.name}\]/ &&
            email.subject.include?(@structure.name) &&
            email.from.include?(@site_settings.site_email) &&
            email.to.include?(@person.primary_email_address) &&
            email.body.include?("assigned to you")
        end
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

    context "and another structure" do
      setup do
        @d2 = @project.structures.create(:name => "Another", :structure_template => @tmpl,
          :position => 2)
      end

      context "on POST to :sort" do
        setup do
          assert @structure.position < @d2.position
          
          post :sort, :project_id => @project.id,
            "structures_#{@tmpl.id}".to_sym => [ @d2.id.to_s, @structure.id.to_s ]
        end

        should_respond_with :success

        should "sort the structures" do
          @structure.reload
          @d2.reload

          assert @d2.position < @structure.position
        end
      end
    end
  end
end
