require File.dirname(__FILE__) + '/../test_helper'

class DocTest < ActiveSupport::TestCase
  should_have_one :doc_value
  should_validate_presence_of :doc_value
  should_belong_to :author
  should_belong_to :project
  should_validate_presence_of :project
  should_have_many :versions

  context "A newly created doc" do
    setup do
      build_schema_for_attr_value(:doc_field, :doc_value)
      @doc = Factory.build(:doc, :doc_value => @value)
    end
    
    should "be valid" do
      assert_valid @doc
    end
    
    context "having had validation run" do
      setup do
        @doc.valid?
      end
      
      should "have its project set correctly" do
        assert_equal @doc.doc_value.structure.project, @doc.project
      end
    end
  end
end
