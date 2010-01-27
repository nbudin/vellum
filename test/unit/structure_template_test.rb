require File.dirname(__FILE__) + '/../test_helper'

class StructureTemplateTest < ActiveSupport::TestCase
  should_belong_to :project
  should_have_many :structures
  should_have_many :attrs

  context "A newly created StructureTemplate" do
    setup do
      @veg = StructureTemplate.new :name => "Vegetable"
    end
    
    should "save cleanly" do
      assert_save @veg
    end
  end
end
