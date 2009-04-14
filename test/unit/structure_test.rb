require File.dirname(__FILE__) + '/../test_helper'

class StructureTest < ActiveSupport::TestCase
  fixtures :structures, :structure_templates, :text_fields, :relationship_types

  def test_create_structure
    bob = Structure.new :structure_template => structure_templates(:person)
    assert bob.save
    assert name = bob.attr_value("Name")
    name.value = "Bob"
    name.save

    bob = Structure.find(bob.id)
    assert bob.attr_value("Name").value == "Bob"
  end

  def test_related_structures
    david = Structure.new(:structure_template => structure_templates(:worker))
    gareth = Structure.new(:structure_template => structure_templates(:worker))
    assert david.save
    assert gareth.save

    david_is_gareths_boss = Relationship.new(:left => david, :right => gareth, :relationship_type => relationship_types(:manager))
    assert david_is_gareths_boss.save

    david = Structure.find(david.id)
    gareth = Structure.find(gareth.id)
    assert david.relationships[0].relationship_type == relationship_types(:manager)
    assert gareth.relationships[0].relationship_type == relationship_types(:manager)
    assert david.relationships[0].other(david) == gareth
    assert gareth.relationships[0].other(gareth) == david
    assert david.relationships[0] = gareth.relationships[0]
  end
end
