require 'test_helper'

class DocTemplateTest < ActiveSupport::TestCase
  should_belong_to :project
  should_have_many :docs
  should_have_many :doc_template_attrs
  should_validate_presence_of :name

  context "A newly created DocTemplate" do
    setup do
      @veg = DocTemplate.new :name => "Vegetable"
    end

    should "save cleanly" do
      assert_save @veg
    end
  end
end
