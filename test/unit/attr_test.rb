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

  context "with an existing template attr" do
    setup do
      assert @ta = Factory.create(:doc_template_attr, :name => "Quest",
        :ui_type => "textarea")
      assert @tmpl = @ta.doc_template
      assert @doc = Factory.create(:doc, :doc_template => @tmpl,
        :project => @tmpl.project)
      assert @attr = @doc.attrs["Quest"]
    end

    should "correctly identify the template" do
      assert @attr.template_attr.from_template?
      assert_equal @ta, @attr.template_attr
    end

    should "return the right UI type" do
      assert_equal "textarea", @attr.ui_type
    end
  end
end
