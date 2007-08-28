require File.dirname(__FILE__) + '/../test_helper'

class StructureTest < Test::Unit::TestCase
  fixtures :structures, :templates, :text_fields

  def test_create_structure
    bob = Structure.new :template => templates(:person)
    assert bob.save
    assert name = bob.attr_value("Name")
    name.value = "Bob"
    name.save

    bob = Structure.find(bob.id)
    assert bob.attr_value("Name").value == "Bob"
  end
end
