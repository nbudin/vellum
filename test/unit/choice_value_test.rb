require 'test_helper'

class ChoiceValueTest < ActiveSupport::TestCase
  fixtures :choices, :choice_fields

  def build_value(field)
    attr = Attr.create :attr_configuration => field
    v = ChoiceValue.create
    avm = AttrValueMetadata.create :attr => attr, :value => v
    v.reload
    return v
  end

  test "simple" do
    v = build_value(choice_fields(:filingstatus))
    v.choices.push choices(:single)
    v.save
    assert v.valid?
    assert_equal v.value, "single"
  end

  test "nil_value" do
    v = build_value(choice_fields(:filingstatus))
    assert v.valid?
    assert_nil v.value
  end
  
  test "nil_value_multiple" do
    v = build_value(choice_fields(:toppings))
    assert v.valid?
    assert_equal [], v.value
  end

  test "invalid_choice" do
    v = build_value(choice_fields(:filingstatus))
    v.choices.push choices(:ketchup)
    v.save
    assert_equal v.valid?, false
  end

  test "multiple" do
    v = build_value(choice_fields(:toppings))
    v.choices.push choices(:ketchup)
    v.choices.push choices(:mayo)
    v.save
    assert v.valid?
    assert_equal 2, v.choices.count
    assert v.value.include?("mayo")
    assert v.value.include?("ketchup")
  end

  test "invalid_multiple" do
    v = build_value(choice_fields(:filingstatus))
    v.choices.push choices(:single)
    v.choices.push choices(:married)
    v.save
    assert_equal v.valid?, false
  end
end
