require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTest < ActiveSupport::TestCase
  fixtures :relationships, :relationship_types, :structure_templates, :projects
  
  def build_structure
    Factory.build(:structure, :project => @p, :structure_template => @t)
  end
  
  def setup
    @t = Factory.create(:structure_template)
    @rt = @t.template_schema.relationship_types.create(:left_template => @t, :right_template => @t)
    @p = Factory.build(:project, :template_schema => @t.template_schema)
  end
  
  should_validate_presence_of :left, :right, :project, :relationship_type
  
  context "A new relationship" do
    setup do
      @s1 = build_structure
      @s2 = build_structure
      
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @s1, :right => @s2, :project => @p)
    end
    
    should "pass validation" do
      assert @r.valid?, @r.errors.full_messages.join("\n")
    end
  end
  
  context "A circular relationship" do
    setup do
      @s1 = build_structure
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @s1, :right => @s1, :project => @p)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
  
  context "A relationship from the wrong project" do
    setup do
      @s1 = build_structure
      @s2 = build_structure
      @p2 = Factory.build(:project, :template_schema => @t.template_schema)
      
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @s1, :right => @s2, :project => @p2)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
  
  context "A duplicate relationship" do
    setup do
      @p.save
      
      @s1 = build_structure
      @s2 = build_structure
      [@s1, @s2].each do |s|
        s.save
      end
      
      @r = Factory.create(:relationship, :relationship_type => @rt, :left => @s1, :right => @s2, :project => @p)
      [@s1, @s2].each do |s|
        s.reload
      end
      
      @r2 = Factory.build(:relationship, :relationship_type => @rt, :left => @s1, :right => @s2, :project => @p)
    end
    
    should "be invalid" do
      assert !@r2.valid?
    end
    
    should "not prevent other relationships from being created" do
      assert @rt2 = @t.template_schema.relationship_types.create(:left_template => @t, :right_template => @t)
      @r3 = Factory.build(:relationship, :relationship_type => @rt2, :left => @s1, :right => @s2, :project => @p)
      
      assert @r3.valid?, @r.errors.full_messages.join("\n")
      assert @r3.save
    end
  end
end
