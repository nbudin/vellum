require File.dirname(__FILE__) + '/../test_helper'

class DocTest < ActiveSupport::TestCase
  should_have_one :doc_value
  should_validate_presence_of :doc_value
  should_belong_to :author
  should_have_many :versions

  context "A newly created doc" do
    setup do
      build_schema_for_attr_value(:doc_field, :doc_value)
      @doc = Factory.build(:doc, :doc_value => @value)
    end
    
    should "be valid" do
      assert_valid @doc
    end
    
    should "have its project set correctly" do
      assert @doc.doc_value.project == @project
    end
  end
end
