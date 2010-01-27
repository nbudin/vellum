require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTypeTest < ActiveSupport::TestCase
  context "A relationship of the wrong type" do
    setup do
      @s1 = Factory.build(:structure)
      @project = @s1.project

      @s2 = Factory.build(:structure, :structure_template => @s1.structure_template, :project => @project)
      @t2 = @project.structure_templates.new

      @rt = @project.relationship_types.new(:left_template => @t2, :right_template => @t2)
      @r = @project.relationships.new(:relationship_type => @rt, :left => @s1, :right => @s2)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
end
