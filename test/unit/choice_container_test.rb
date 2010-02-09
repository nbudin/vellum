require 'test_helper'
require 'choice_container'

class SimpleChoiceContainer
  attr_accessor :choices_str

  def read_attribute(name)
    self.send("#{name}_str")
  end

  def write_attribute(name, value)
    self.send("#{name}_str=", value)
  end

  include ChoiceContainer
end

class ChoiceContainerTest < ActiveSupport::TestCase
  context "An empty choice container" do
    setup do
      @cc = SimpleChoiceContainer.new
    end

    should "return an empty choice set" do
      assert_equal 0, @cc.choices.size
    end

    should "accept choices being added" do
      @cc.choices = ["a", "b"]
      assert_equal 2, @cc.choices.size
    end
  end

  context "A choice container with a blank choice string" do
    setup do
      @cc = SimpleChoiceContainer.new
      @cc.choices_str = ""
    end

    should "return an empty choice set" do
      assert_equal 0, @cc.choices.size
    end
  end

  context "A choice container with choices in it" do
    setup do
      @cc = SimpleChoiceContainer.new
      @cc.choices_str = "a|b|c|d|e"
    end

    should "return the right choice set" do
      assert_equal 5, @cc.choices.size
      assert_equal %w{a b c d e}, @cc.choices
    end

    should "remove choices correctly" do
      @cc.choices = %w{a b c e}
      assert_equal %w{a b c e}, @cc.choices
      assert_equal "a|b|c|e", @cc.choices_str
    end
  end
end