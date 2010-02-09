require File.dirname(__FILE__) + '/../test_helper'

class AttrTest < ActiveSupport::TestCase
  should_belong_to :doc_version

  context "with an existing Attr" do
    setup do
      assert @doc = Factory.create(:doc)
      assert @attr = @doc.attrs["Test name"]
      assert @doc.save
    end

    subject { @attr }
    should_validate_uniqueness_of :name, :scoped_to => "doc_version_id"
  end
end
