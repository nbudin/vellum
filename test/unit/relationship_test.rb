require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def build_doc
    Factory.build(:doc, :project => @p, :doc_template => @t)
  end
  
  def setup
    @t = Factory.create(:doc_template)
    @p = @t.project
    @rt = @p.relationship_types.create(:left_template => @t, :right_template => @t)
  end
  
  [:left, :right, :project, :relationship_type].each do |f|
    should validate_presence_of(f)
  end
  
  context "A new relationship" do
    setup do
      @d1 = build_doc
      @d2 = build_doc
      
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
    end
    
    should "pass validation" do
      assert @r.valid?, @r.errors.full_messages.join("\n")
    end
  end
  
  context "A circular relationship" do
    setup do
      @d1 = build_doc
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d1, :project => @p)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
  
  context "A relationship from the wrong project" do
    setup do
      @d1 = build_doc
      @d2 = build_doc
      @p2 = Factory.build(:project)
      
      @r = Factory.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p2)
    end
    
    should "be invalid" do
      assert !@r.valid?
    end
  end
  
  context "A duplicate relationship" do
    setup do
      @p.save
      
      @d1 = build_doc
      @d2 = build_doc
      [@d1, @d2].each do |s|
        s.save
      end
      
      @r = Factory.create(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
      [@d1, @d2].each do |s|
        s.reload
      end
      
      @r2 = Factory.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
    end
    
    should "be invalid" do
      assert !@r2.valid?
    end
    
    should "not prevent other relationships from being created" do
      assert @rt2 = @p.relationship_types.create(:left_template => @t, :right_template => @t)
      @r3 = Factory.build(:relationship, :relationship_type => @rt2, :left => @d1, :right => @d2, :project => @p)
      
      assert @r3.valid?, @r.errors.full_messages.join("\n")
      assert @r3.save
    end
  end
end
