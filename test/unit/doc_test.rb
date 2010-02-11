require File.dirname(__FILE__) + '/../test_helper'

class DocTest < ActiveSupport::TestCase
  should_belong_to :project
  should_belong_to :doc_template
  should_belong_to :creator
  should_have_many :versions

  context "A doc" do
    setup do
      @doc = Factory.build(:doc, :name => "Bob")
    end
    
    should "be valid" do
      assert_valid @doc
    end

    should "generate attrs correctly" do
      assert @doc.attrs
      assert @doc.attrs.is_a? Doc::AttrSet
      assert a = @doc.attrs["new attr"]
      assert a.is_a? Attr
      assert @doc.attrs["new attr"] === a
    end

    should "return the right value for name" do
      assert_equal "Bob", @doc.name
    end

    should "not start out assigned to anyone" do
      assert_nil @doc.assignee
    end

    context "with an attr" do
      setup do
        assert @doc.save
        @attr_name = "Favorite Color"
        assert @attr = @doc.attrs[@attr_name]
      end

      should "return the same attr on subsequent obtains" do
        assert attr = @doc.attrs[@attr_name]
        assert attr === @attr
      end

      context "having a value" do
        setup do
          @attr.value = "Yellow"
        end

        should "return the right value on retrieval" do
          assert_equal "Yellow", @doc.attrs[@attr_name].value
        end

        should "respond appropriately to attr_values" do
          assert @avs = @doc.attr_values
          assert_equal "Yellow", @avs[@attr_name]
          assert_equal 1, @avs.size
        end

        should "take attr values from attr_values=" do
          @doc.attr_values = { @attr.name => "Fuschia" }
          assert_equal "Fuschia", @attr.value
          assert_equal "Fuschia", @doc.attrs[@attr.name].value
          assert_equal "Fuschia", @doc.attr_values[@attr.name]
        end

        context "having been saved" do
          setup do
            @version1 = @doc.version
            assert @doc.save
            assert @doc = Doc.find(@doc.id)
            @version2 = @doc.version
          end

          should "have an updated version number" do
            assert_equal @version1 + 1, @version2
          end

          should "return the right value on retrieval" do
            assert_equal "Yellow", @doc.attrs[@attr_name].value
          end

          should "not have modified the old version" do
            assert @old_doc = @doc.find_version(@version1)
            assert @old_doc.attrs.find_by_name(@attr_name).nil?
          end

          context "and the attr value changed" do
            setup do
              @doc.attrs[@attr_name].value = "Red"
              assert @doc.save
              assert @doc = Doc.find(@doc.id)
              @version3 = @doc.version
            end

            should "preserve the version history" do
              assert @doc1 = @doc.find_version(@version1)
              assert @doc2 = @doc.find_version(@version2)
              assert @doc3 = @doc.find_version(@version3)

              assert @doc1.attrs.find_by_name(@attr_name).nil?
              assert_equal "Yellow", @doc2.attrs.find_by_name(@attr_name).value
              assert_equal "Red", @doc3.attrs.find_by_name(@attr_name).value
            end
          end

          context "and the attr deleted" do
            setup do
              @doc.attrs.delete(@attr_name)
              assert_nil @doc.attr_values[@attr_name]

              assert @doc.save
              assert @doc = Doc.find(@doc.id)
              @version3 = @doc.version
            end

            should "not have the attr in the working set" do
              assert_nil @doc.attr_values[@attr_name]
            end

            should "not have the attr on the latest version" do
              assert @doc3 = @doc.find_version(@version3)
              assert_nil @doc3.attrs.find_by_name(@attr_name)
            end

            should "still have the attr on the previous version" do
              assert @doc2 = @doc.find_version(@version2)
              assert_equal "Yellow", @doc2.attrs.find_by_name(@attr_name).value
            end
          end
        end
      end
    end

    context "with a related doc" do
      setup do
        assert @doc.save

        @project = @doc.project
        assert @rt = @project.relationship_types.create(:left_template => @doc.doc_template,
                                                 :right_template => @doc.doc_template,
                                                 :left_description => "is shorter than",
                                                 :right_description => "is taller than")

        assert @joe = @project.docs.create(:doc_template => @doc.doc_template, :name => "Joe")
        assert @r = @project.relationships.create(:relationship_type => @rt, :left => @joe, :right => @doc)

        @doc.reload
        @joe.reload
      end

      should "show the relationship on both docs" do
        assert @doc.inward_relationships.include?(@r), "@r doesn't show up on Bob's inward relationships"
        assert @doc.relationships.include?(@r), "@r doesn't show up on Bob's inward relationships"
        @bob_related = @doc.related_docs(@rt, "inward")
        assert @bob_related.include?(@joe), "related_structures should include Joe but is #{@bob_related.inspect}"
        @bob_related = @doc.related_docs("is taller than", "inward")
        assert @bob_related.include?(@joe), "related_structures should include Joe but is #{@bob_related.inspect}"
        @bob_related = @doc.related_docs("is taller than")
        assert @bob_related.include?(@joe), "related_structures should include Joe but is #{@bob_related.inspect}"

        assert @joe.outward_relationships.include?(@r), "@r doesn't show up on Joe's outward relationships"
        assert @joe.relationships.include?(@r), "@r doesn't show up on Joe's inward relationships"
        @joe_related = @joe.related_docs(@rt, "outward")
        assert @joe_related.include?(@doc), "related_structures should include Bob but is #{@joe_related.inspect}"
        @joe_related = @joe.related_docs("is shorter than", "outward")
        assert @joe_related.include?(@doc), "related_structures should include Bob but is #{@joe_related.inspect}"
        @joe_related = @joe.related_docs("is shorter than")
        assert @joe_related.include?(@doc), "related_structures should include Bob but is #{@joe_related.inspect}"
      end
    end
  end
end
