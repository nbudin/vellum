require 'test_helper'

class DocTemplateTest < ActiveSupport::TestCase
  should belong_to(:project)
  should have_many(:docs)
  should have_many(:doc_template_attrs)
  should validate_presence_of(:name)

  context "A newly created DocTemplate" do
    setup do
      @veg = DocTemplate.new :name => "Vegetable"
    end

    should "save cleanly" do
      assert @veg.save
    end
  end
end
