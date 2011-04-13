require File.dirname(__FILE__) + '/../test_helper'

class AbilityTest < ActiveSupport::TestCase
  class << self
    def should_have_project_abilities(abilities)
      %w{read create update destroy}.each do |action|
        if abilities.include?(action)
          should "be able to #{action} the project itself" do
            assert @ability.can?(action, @project)
          end
        else
          should "not be able to #{action} the project itself" do
            assert !@ability.can?(action, @project)
          end
        end
      end
    end

    def should_have_content_abilities(abilities)
      %w{read create update destroy}.each do |action|
        [Doc, DocTemplate, Map, PublicationTemplate, RelationshipType, Relationship].each do |project_contents|
          obj = project_contents.new(:project => @project)
          if abilities.include?(action)
            should "be able to #{action} a #{project_contents.name} in the project" do
              assert @ability.can?(action, obj)
            end
          else
            should "not be able to #{action} a #{project_contents.name} in the project" do
              assert !@ability.can?(action, obj)
            end
          end
        end
      end
    end
  end
  
  context "An admin/author" do
    setup do
      @project = Factory.create(:project)
      @person = Factory.create(:person)
      @project.project_memberships.create(:person => @person, :admin => true, :author => true)
      @ability = Ability.new(@person)
    end
    
    should_have_project_abilities(%w{read create update destroy})
    should_have_content_abilities(%w{read create update destroy})
  end
end