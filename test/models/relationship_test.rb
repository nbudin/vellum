require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def build_doc
    FactoryGirl.build(:doc, :project => @p, :doc_template => @t)
  end

  setup do
    @t = FactoryGirl.create(:doc_template)
    @p = @t.project
    @rt = @p.relationship_types.create(:left_template => @t, :right_template => @t)
  end

  describe "A new relationship" do
    setup do
      @d1 = build_doc
      @d2 = build_doc

      @r = FactoryGirl.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
    end

    it "should pass validation" do
      assert @r.valid?, @r.errors.full_messages.join("\n")
    end
  end

  describe "A circular relationship" do
    setup do
      @d1 = build_doc
      @r = FactoryGirl.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d1, :project => @p)
    end

    it "should be invalid" do
      assert !@r.valid?
    end
  end

  describe "A relationship from the wrong project" do
    setup do
      @d1 = build_doc
      @d2 = build_doc
      @p2 = FactoryGirl.build(:project)

      @r = FactoryGirl.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p2)
    end

    it "should be invalid" do
      assert !@r.valid?
    end
  end

  describe "A duplicate relationship" do
    setup do
      @p.save

      @d1 = build_doc
      @d2 = build_doc
      [@d1, @d2].each do |s|
        s.save
      end

      @r = FactoryGirl.create(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
      [@d1, @d2].each do |s|
        s.reload
      end

      @r2 = FactoryGirl.build(:relationship, :relationship_type => @rt, :left => @d1, :right => @d2, :project => @p)
    end

    it "should be invalid" do
      assert !@r2.valid?
    end

    it "should not prevent other relationships from being created" do
      assert @rt2 = @p.relationship_types.create(:left_template => @t, :right_template => @t)
      @r3 = FactoryGirl.build(:relationship, :relationship_type => @rt2, :left => @d1, :right => @d2, :project => @p)

      assert @r3.valid?, @r.errors.full_messages.join("\n")
      assert @r3.save
    end
  end
end
