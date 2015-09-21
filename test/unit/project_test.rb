require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  describe "A project" do
    setup do
      assert @project = FactoryGirl.create(:project)
    end

    describe "cloning another project's templates" do
      setup do
        assert @lp = FactoryGirl.create(:louisiana_purchase)
        assert @character = @lp.doc_templates.find_by(name: "Character")
        assert @hp = @character.doc_template_attrs.find_by(name: "HP")
        assert @org = @lp.doc_templates.find_by(name: "Organization")
        assert @includes = @lp.relationship_types.first
        assert_equal "Organization includes Character", @includes.left_name
        assert @lp.docs.size > 0
        assert @lp.relationships.size > 0

        @project.clone_templates_from(@lp)
      end

      it "should have a clone of the templates" do
        assert new_char = @project.doc_templates.select { |t| t.name == "Character" }.first
        assert !@project.doc_templates.include?(@character)
        assert new_hp = new_char.doc_template_attrs.select { |a| a.name == "HP" }.first
        assert !@character.doc_template_attrs.include?(new_hp)

        assert @project.doc_templates.any? { |t| t.name == "Organization" }
        assert !@project.doc_templates.include?(@organization)
      end

      it "should have a clone of the relationship types" do
        assert new_rt = @project.relationship_types.select { |rt|
          rt.left_name == "Organization includes Character"
          }.first
        assert new_rt.left_template != @organization
        assert new_rt.right_template != @character
        assert @project.doc_templates.include?(new_rt.left_template)
        assert @project.doc_templates.include?(new_rt.right_template)
        assert !@lp.relationship_types.include?(new_rt)
      end

      it "should not have any docs or relationships" do
        assert_equal 0, @project.docs.size
        assert_equal 0, @project.relationships.size
      end

      it "should be valid" do
        assert @project.valid?
        assert @project.save
      end
    end
  end
end
