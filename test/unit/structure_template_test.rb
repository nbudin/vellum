require File.dirname(__FILE__) + '/../test_helper'

class StructureTemplateTest < ActiveSupport::TestCase
  fixtures :structure_templates

  context "A newly created StructureTemplate" do
    setup do
      @veg = StructureTemplate.new :name => "Vegetable"
    end
    
    should "save cleanly" do
      assert_save @veg
    end
    
    context "with a child template" do
      setup do
        @lettuce = StructureTemplate.new :name => "Lettuce", :parent => @veg
        assert_save @lettuce
      end
      
      should "contain its child" do
        assert !@veg.children.index(@lettuce).nil?
      end
      
      should "have a backreference from the child" do
        assert_equal @veg, @lettuce.parent
      end
    end
  end
end
