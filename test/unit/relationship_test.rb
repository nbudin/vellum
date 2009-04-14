require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTest < ActiveSupport::TestCase
  fixtures :relationships, :relationship_types, :structure_templates

  def test_valid_relationship
    p1 = Structure.new(:structure_template => structure_templates(:person))
    p2 = Structure.new(:structure_template => structure_templates(:person))
    assert p1.save
    assert p2.save

    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p1, :right => p2)
    assert r.save
  end

  def test_circular_relationship
    p = Structure.new(:structure_template => structure_templates(:person))

    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p, :right => p)
    assert !r.valid?
  end

  def test_incomplete_relationships
    r = Relationship.new(:relationship_type => relationship_types(:parent))
    assert !r.valid?

    p = Structure.new(:structure_template => structure_templates(:person))
    r = Relationship.new(:relationship_type => relationship_types(:parent), :left => p)
    assert !r.valid?

    r = Relationship.new(:relationship_type => relationship_types(:parent), :right => p)
    assert !r.valid?
  end

  def test_untyped_relationships
    p1 = Structure.new(:structure_template => structure_templates(:person))
    p2 = Structure.new(:structure_template => structure_templates(:person))

    r = Relationship.new(:left => p1, :right => p2)
    assert !r.valid?
  end
end
