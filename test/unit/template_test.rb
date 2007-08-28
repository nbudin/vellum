require File.dirname(__FILE__) + '/../test_helper'

class TemplateTest < Test::Unit::TestCase
  fixtures :templates

  def test_new_template
    t = Template.new :name => "Carrot"
    assert t.save
  end

  def test_parent_template
    veg = Template.new :name => "Vegetable"
    lettuce = Template.new :name => "Lettuce", :parent => veg

    assert lettuce.save
    assert veg.save

    assert lettuce = Template.find(lettuce.id)
    assert veg = Template.find(veg.id)
    assert !veg.children.index(lettuce).nil?
    assert lettuce.parent == veg
  end
end
