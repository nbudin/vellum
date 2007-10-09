require File.dirname(__FILE__) + '/../test_helper'

class StructureTemplateTest < Test::Unit::TestCase
  fixtures :structure_templates

  def test_new_template
    t = StructureTemplate.new :name => "Carrot"
    assert t.save
  end

  def test_parent_template
    veg = StructureTemplate.new :name => "Vegetable"
    lettuce = StructureTemplate.new :name => "Lettuce", :parent => veg

    assert lettuce.save
    assert veg.save

    assert lettuce = StructureTemplate.find(lettuce.id)
    assert veg = StructureTemplate.find(veg.id)
    assert !veg.children.index(lettuce).nil?
    assert lettuce.parent == veg
  end
end
