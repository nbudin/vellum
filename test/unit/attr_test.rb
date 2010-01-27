require File.dirname(__FILE__) + '/../test_helper'

class AttrTest < ActiveSupport::TestCase
  context "A required attr" do
    setup do
      @attr = Factory.create(:attr, :required => true)
    end
    
    context "with an attached structure" do
      setup do
        @structure = Factory.build(:structure, :structure_template => @attr.structure_template)
        @project = @structure.project
      end
      
      should "invalidate the structure unless set" do
        assert !@structure.valid?
      end
    
      context "having had the attr set" do
        setup do
          @project.save!
          @attr.attr_configuration = Factory.create(:text_field, :attr => @attr)
          @structure.obtain_attr_value(@attr)
          @structure.save
        end
        
        should "let the structure validate" do
          assert @structure.valid?, @structure.errors.full_messages.join("\n")
        end
      end
    end
  end
end
