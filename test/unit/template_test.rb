require File.dirname(__FILE__) + '/../test_helper'

class TemplateTest < Test::Unit::TestCase
  fixtures :templates

  def test_new_template
    t = Template.new :name => "Carrot"
    assert t.save
  end
end
