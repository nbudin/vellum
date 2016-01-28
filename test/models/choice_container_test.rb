require 'test_helper'
require 'choice_container'

class SimpleChoiceContainer
  include ChoiceContainer
  
  def initialize
    @choices = []
  end
  
  def choices_str=(str)
    self.choices = ChoiceContainer::ChoicesCoder.new.load(str)
  end
  
  def choices_str
    ChoiceContainer::ChoicesCoder.new.dump(self.choices)
  end
end

class ChoiceContainerTest < ActiveSupport::TestCase
  describe "An empty choice container" do
    setup do
      @cc = SimpleChoiceContainer.new
    end

    it "should return an empty choice set" do
      assert_equal 0, @cc.choices.size
    end

    it "should accept choices being added" do
      @cc.choices = ["a", "b"]
      assert_equal 2, @cc.choices.size
    end
  end

  describe "A choice container with a blank choice string" do
    setup do
      @cc = SimpleChoiceContainer.new
      @cc.choices_str = ""
    end

    it "should return an empty choice set" do
      assert_equal 0, @cc.choices.size
    end
  end

  describe "A choice container with choices in it" do
    setup do
      @cc = SimpleChoiceContainer.new
      @cc.choices_str = "a,b,c,d,e"
    end

    it "should return the right choice set" do
      assert_equal 5, @cc.choices.size
      assert_equal %w{a b c d e}, @cc.choices
      assert_equal "a, b, c, d, e", @cc.human_choices
    end

    it "should remove choices correctly" do
      @cc.choices = %w{a b c e}
      assert_equal %w{a b c e}, @cc.choices
      assert_equal "a,b,c,e", @cc.choices_str
      assert_equal "a, b, c, e", @cc.human_choices
    end

    it "should remove human choices correctly" do
      @cc.human_choices = "a, b, c, e"
      assert_equal %w{a b c e}, @cc.choices
      assert_equal "a,b,c,e", @cc.choices_str
      assert_equal "a, b, c, e", @cc.human_choices
    end
  end
end