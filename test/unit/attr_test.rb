require File.dirname(__FILE__) + '/../test_helper'

class AttrTest < Test::Unit::TestCase
  fixtures :attrs

  def test_required_attrs
    t = Template.new
    a = Attr.new :template => t, :required => true

    s = Structure.new :template => t
    assert !s.valid?
  end
end
