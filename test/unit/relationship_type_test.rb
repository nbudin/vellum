require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTypeTest < ActiveSupport::TestCase
  context "A relationship of the wrong type" do
    setup do
      @d1 = Factory.build(:doc)
      @project = @d1.project

      @d2 = Factory.build(:doc, :doc_template => @d1.doc_template, :project => @project)
      @t2 = @project.doc_templates.new

      @rt = @project.relationship_types.new(:left_template => @t2, :right_template => @t2)
      @r = @project.relationships.new(:relationship_type => @rt, :left => @d1, :right => @d2)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
end
