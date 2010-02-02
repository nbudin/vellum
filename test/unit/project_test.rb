require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "A project" do
    setup do
      assert @project = Factory.create(:project)
    end

    context "cloning another project's templates" do
      setup do
        assert @lp = Factory.create(:louisiana_purchase)
        assert @character = @lp.structure_templates.find_by_name("Character")
        assert @hp = @character.attrs.find_by_name("HP")
        assert @org = @lp.structure_templates.find_by_name("Organization")
        assert @includes = @lp.relationship_types.first
        assert_equal "Organization includes Character", @includes.left_name
        assert @lp.structures.size > 0
        assert @lp.relationships.size > 0

        @project.clone_templates_from(@lp)
      end

      should "have a clone of the templates" do
        assert new_char = @project.structure_templates.select { |t| t.name == "Character" }.first
        assert !@project.structure_templates.include?(@character)
        assert new_hp = new_char.attrs.select { |a| a.name == "HP" }.first
        assert !@character.attrs.include?(new_hp)

        assert @project.structure_templates.any? { |t| t.name == "Organization" }
        assert !@project.structure_templates.include?(@organization)
      end

      should "have a clone of the relationship types" do
        assert new_rt = @project.relationship_types.select { |rt|
          rt.left_name == "Organization includes Character"
          }.first
        assert new_rt.left_template != @organization
        assert new_rt.right_template != @character
        assert @project.structure_templates.include?(new_rt.left_template)
        assert @project.structure_templates.include?(new_rt.right_template)
        assert !@lp.relationship_types.include?(new_rt)
      end

      should "not have any structures or relationships" do
        assert_equal 0, @project.structures.size
        assert_equal 0, @project.relationships.size
      end
    end
  end
end
