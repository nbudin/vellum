require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTest < ActiveSupport::TestCase
  fixtures :relationships, :relationship_types, :structure_templates, :projects
  
  def setup
    @project = projects(:people)
  end

  def test_valid_relationship
    p1 = Structure.new(:structure_template => structure_templates(:person), :project => @project)
    p2 = Structure.new(:structure_template => structure_templates(:person), :project => @project)
    assert p1.save
    assert p2.save

    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p1, :right => p2, :project => @project)
    assert r.save, r.errors.full_messages.join("\n")
  end

  def test_circular_relationship
    p = Structure.new(:structure_template => structure_templates(:person), :project => @project)

    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p, :right => p, :project => @project)
    assert !r.valid?
  end

  def test_incomplete_relationships
    r = Relationship.new(:relationship_type => relationship_types(:parent), :project => @project)
    assert !r.valid?

    p = Structure.new(:structure_template => structure_templates(:person), :project => @project)
    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p, :project => @project)
    assert !r.valid?

    r = Relationship.new(:relationship_type => relationship_types(:parent), :right => p, :project => @project)
    assert !r.valid?

    p2 = Structure.new(:structure_template => structure_templates(:person), :project => @project)
    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p, :right => p2)
    assert !r.valid?
  end

  def test_untyped_relationships
    p1 = Structure.new(:structure_template => structure_templates(:person), :project => @project)
    p2 = Structure.new(:structure_template => structure_templates(:person), :project => @project)

    r = Relationship.new(:left => p1, :right => p2, :project => @project)
    assert !r.valid?
  end
end
