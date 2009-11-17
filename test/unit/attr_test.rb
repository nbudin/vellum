require File.dirname(__FILE__) + '/../test_helper'

class AttrTest < ActiveSupport::TestCase
  context "A required attr" do
    setup do
      @attr = Factory.create(:attr, :required => true)
    end
    
    context "with an attached structure" do
      setup do
        @project = Factory.build(:project, :template_schema => @attr.structure_template.template_schema)
        @structure = Factory.build(:structure, :project => @project, :structure_template => @attr.structure_template)
      end
      
      should "invalidate the structure unless set" do
        assert !@structure.valid?
      end
    
      context "having had the attr set" do
        setup do
          @attr.attr_configuration = Factory.create(:text_field, :attr => @attr)
          @structure.obtain_attr_value(@attr).save!
        end
        
        should "let the structure validate" do
          assert @structure.valid?, @structure.errors.full_messages.join("\n")
        end
      end
    end
  end
end
