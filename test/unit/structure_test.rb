require File.dirname(__FILE__) + '/../test_helper'

class StructureTest < Test::Unit::TestCase
  fixtures :structures, :templates

  def test_create_structure
    bob = Structure.new :template => templates(:person)
    bob.attr("Name").value = "Bob"
    assert bob.save
  end
end
