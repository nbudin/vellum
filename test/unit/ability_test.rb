require File.dirname(__FILE__) + '/../test_helper'

class AbilityTest < ActiveSupport::TestCase
  def assert_has_project_abilities(abilities)
    %w{read create update destroy copy_templates change_permissions}.each do |action|
      if abilities.include?(action)
        assert @ability.can?(action.to_sym, @project), "Should be able to #{action} the project"
      else
        assert !@ability.can?(action.to_sym, @project), "Should not be able to #{action} the project"
      end
    end
  end

  def assert_has_content_abilities(abilities)
    map = @project.maps.create

    %w{read create update destroy}.each do |action|
      [Doc, DocTemplate, Map, PublicationTemplate, RelationshipType, Relationship].each do |klass|
        obj = klass.new(:project => @project)
        if abilities.include?(action)
          assert @ability.can?(action.to_sym, obj), "Should be able to #{action} a #{klass.name} in the project"
        else
          assert !@ability.can?(action.to_sym, obj), "Should not be able to #{action} a #{klass.name} in the project"
        end
      end
      
      [MappedDocTemplate, MappedRelationshipType].each do |klass|
        obj = klass.new(:map => map)
        if abilities.include?(action)
          assert @ability.can?(action.to_sym, obj), "Should be able to #{action} a #{klass.name} in the project"
        else
          assert !@ability.can?(action.to_sym, obj), "Should not be able to #{action} a #{klass.name} in the project"
        end
      end
    end
  end
  
  def build_membership_and_ability(attributes={})
    @membership = FactoryGirl.create(:project_membership, attributes)
    @project = @membership.project
    @person = @membership.person
    @ability = Ability.new(@person)
  end
  
  describe "A global admin" do
    setup do
      @project = FactoryGirl.create(:project)
      @person = FactoryGirl.create(:person, :admin => true)
      @ability = Ability.new(@person)
    end
    
    it "should have all permissions" do
      assert_has_project_abilities(%w{read create update destroy copy_templates change_permissions})
      assert_has_content_abilities(%w{read create update destroy})
    end
  end
  
  describe "A project admin/author" do
    setup { build_membership_and_ability(:admin => true, :author => true) }
    
    it "should have appropriate permissions" do
      assert_has_project_abilities(%w{read create update destroy copy_templates change_permissions})
      assert_has_content_abilities(%w{read create update destroy})
    end
  end
  
  describe "A project admin" do
    setup { build_membership_and_ability(:admin => true, :author => false) }

    
    it "should have appropriate permissions" do
      assert_has_project_abilities(%w{read create destroy copy_templates change_permissions})
      assert_has_content_abilities(%w{read})
    end
  end
  
  describe "A project author" do
    setup { build_membership_and_ability(:admin => false, :author => true) }

    it "should have appropriate permissions" do
      assert_has_project_abilities(%w{read create update copy_templates})
      assert_has_content_abilities(%w{read create update destroy})
    end
  end
  
  describe "An unprivileged member" do
    setup { build_membership_and_ability(:admin => false, :author => false) }
    
    it "should have appropriate permissions" do
      assert_has_project_abilities(%w{read create copy_templates})
      assert_has_content_abilities(%w{read})
    end
  end
  
  describe "A non-member" do
    setup do
      @project = FactoryGirl.create(:project)
      @person = FactoryGirl.create(:person)
    end
    
    it "should have appropriate permissions" do
      @ability = Ability.new(@person)
      assert_has_project_abilities(%w{create})
      assert_has_content_abilities([])
    end
    
    describe "of a public project" do
      setup do
        @project.public_visibility = "visible"
        assert @project.save
      end
      
      it "should be able to read the project" do
        @ability = Ability.new(@person)
        assert_has_project_abilities(%w{create read})
        assert_has_content_abilities(%w{read})
      end
    end
    
    describe "of a copy-templates project" do
      setup do
        @project.public_visibility = "copy_templates"
        assert @project.save
      end
      
      it "should be able to copy templates from the project" do
        @ability = Ability.new(@person)
        assert_has_project_abilities(%w{create copy_templates})
        assert_has_content_abilities([])
      end
    end
    
    describe "An anonymous user" do
      setup do
        @project = FactoryGirl.create(:project)
        @person = nil
        @ability = Ability.new(@person)
      end
      
      it "should have no permissions" do
        @ability = Ability.new(@person)
        assert_has_project_abilities([])
        assert_has_content_abilities([])
      end
    end
  end
    
end