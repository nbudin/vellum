require File.dirname(__FILE__) + '/../test_helper'

class AttrTest < ActiveSupport::TestCase
  describe "with an existing Attr" do
    setup do
      assert @doc = FactoryGirl.create(:doc)
      assert @attr = @doc.attrs["Test name"]
      assert @doc.save
    end

    subject { @attr }
    
    it "should allow the proper values for names" do
      ["a name", "rather-usual", "10 lbs"].each do |value|
        must allow_value(value).for(:name)
      end
      ["field_name", "can't", "include!", "weirdness.", nil, ""].each do |value|
        wont allow_value(value).for(:name)
      end
    end

    it "should normalize for slug properly" do
      assert_equal "test_name", @attr.slug
    end

    it "should return the same instance for a slug-normalized equivalent name" do
      assert @attr = @doc.attrs[@attr.name]
      assert @attr === @doc.attrs[@attr.name]
      assert @attr === @doc.attrs["test NAME"]
      assert @attr === @doc.attrs["TEST_NAME"]
    end
  end

  describe "with an existing template attr" do
    setup do
      # create a different template attr too, to make sure we're getting the right positions
      assert @other_ta = FactoryGirl.create(:doc_template_attr, :name => "Gender",
        :ui_type => "text")
      assert @tmpl = @other_ta.doc_template
      assert @ta = FactoryGirl.create(:doc_template_attr, :name => "Quest",
        :ui_type => "textarea", :doc_template => @tmpl)
      assert @doc = FactoryGirl.create(:doc, :doc_template => @tmpl,
        :project => @tmpl.project)
      assert @attr = @doc.attrs["Quest"]
    end

    it "should correctly identify the template" do
      assert @attr.from_template?
      assert_equal @ta, @attr.template_attr
    end

    it "should return the right UI type" do
      assert_equal "textarea", @attr.ui_type
    end

    it "should return the right position" do
      assert_equal @ta.position, @attr.position
    end

    describe "with choices" do
      setup do
        @ta.ui_type = "radio"
        @ta.choices = ["to seek the Grail", "to star in a movie"]
        assert @ta.save
        @attr.doc.reload
        assert @attr = @doc.attrs["Quest"]
      end

      it "should return the right choices" do
        assert_equal ["to seek the Grail", "to star in a movie"], @attr.choices
      end

      it "should accept hash values" do
        @attr.multiple_value = { 0 => { 'choice' => "to seek the Grail", 'selected' => true },
            1 => { 'choice' => "to star in a movie", 'selected' => false }
        }
        assert_equal "to seek the Grail", @attr.value
      end

      it "should reject hash values that are not in the choices list" do
        @attr.multiple_value = { 0 => { 'choice' => "a", :selected => 1 } }
        assert_equal "", @attr.value
      end
    end
  end
end
