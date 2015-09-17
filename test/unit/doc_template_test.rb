require 'test_helper'

class DocTemplateTest < ActiveSupport::TestCase
  describe "A newly created DocTemplate" do
    setup do
      @veg = DocTemplate.new :name => "Vegetable"
    end

    it "should save cleanly" do
      assert @veg.save
    end
  end
end
