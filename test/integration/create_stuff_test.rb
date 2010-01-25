require 'test_helper'

class CreateStuffTest < ActionController::IntegrationTest
  context "logged in" do
    setup do
      @person = Person.create :firstname => "Test", :lastname => "User"
      @account = @person.create_account :password => "password", :active => true
      @address = "person#{@person.id}@test.com"
      @email_address = @person.email_addresses.create :address => @address, :primary => true

      visit "/"
      click_link "Log in"

      fill_in "Email address", :with => @address
      choose "Yes, my password is:"
      fill_in "login[password]", :with => "password"
      click_button "Log in"

      assert_equal @person.id, session[:person]
    end

    should "make some templates" do
      click_link "Template Schemas"

      fill_in "template_schema[name]", :with => "My new template schema"
      click_button "Create template schema..."

      fill_in "structure_template[name]", :with => "Character"
      click_button "Create template..."

      click_link "Add TextField"
      fill_in "attr[name]", :with => "HP"
      click_button "Create"

      click_link "My new template schema"
      fill_in "structure_template[name]", :with => "Organization"
      click_button "Create template..."

      fill_in "relationship_type[left_description]", :with => "includes"
      select "Character", :from => "relationship_type[right_template_id]"
      click_button "Create relationship type..."
    end

    context "with basic templates" do
      setup do
        @includes = Factory.create(:relationship_type, :left_description => "includes")
        
        @character = @includes.left_template
        @character.name = "Character"
        assert @character.save

        @character_sheet = @character.attrs.create(:name => "Sheet")
        @character_sheet.attr_configuration = DocField.create
        assert @character_sheet.save

        @organization = @includes.right_template
        @organization.name = "Organization"
        assert @organization.save

        @org_sheet = @organization.attrs.create(:name => "Sheet")
        @org_sheet.attr_configuration = DocField.create
        assert @org_sheet.save

        @schema = @character.template_schema
        @schema.name = "Characters and Organizations"
        assert @schema.save

        @schema.grant(@person)
      end

      should "create a project" do
        visit "/"
        click_link "Projects"

        fill_in "project[name]", :with => "My new project"
        select @schema.name, :from => "project[template_schema_id]"
        click_button "Create project..."
      end

      context "and a project" do
        setup do
          @project = Project.create(:name => "Louisiana Purchase",
            :template_schema => @schema)
          @project.grant(@person)
        end

        should "write a character sheet" do
          visit "/"
          click_link "Projects"

          click_link @project.name
          assert_contain "Characters"
          click_link "New character"
          
          fill_in "structure[name]", :with => "Thomas Jefferson"
          fill_in @character_sheet.name, :with => "You want to buy some land."
          click_button "Create"

          assert_contain "Thomas Jefferson"
        end

        should "write an organization sheet" do
          visit "/"
          click_link "Projects"

          click_link @project.name
          assert_contain "Organizations"
          click_link "New organization"

          fill_in "structure[name]", :with => "France"
          fill_in @character_sheet.name, :with => "Oui oui!"
          click_button "Create"

          assert_contain "France"
        end

        context "and two structures" do
          setup do
            @tom = @project.structures.create(:structure_template => @character, :name => "Thomas Jefferson")
            assert @tom_sheet = @tom.obtain_attr_value("Sheet")
            @tom_sheet.doc_content = "You want to buy some land."
            assert @tom_sheet.save

            @france = @project.structures.create(:structure_template => @organization, :name => "France")
            assert @france_sheet = @france.obtain_attr_value("Sheet")
            @france_sheet.doc_content = "Oui oui!"
            assert @france_sheet.save
          end

          should "link structures together with a relationship" do
            visit structure_path(@project, @tom)

            save_and_open_page
          end
        end
      end
    end
  end
end
