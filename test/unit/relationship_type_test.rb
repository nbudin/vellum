require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTypeTest < Test::Unit::TestCase
  fixtures :relationship_types, :templates

  def test_illegal_type
    p1 = Structure.new(:template => templates(:person))
    p2 = Structure.new(:template => templates(:person))

    r = Relationship.new(:relationship_type => relationship_types(:manager), :left => p1, :right => p2)
    assert !r.valid?
  end
end
