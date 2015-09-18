require File.dirname(__FILE__) + '/../test_helper'

class DocTest < ActiveSupport::TestCase
  describe "A doc" do
    setup do
      @doc = FactoryGirl.build(:doc, :name => "Bob")
    end
    
    it "should be valid" do
      assert @doc.valid?
    end

    it "should generate attrs correctly" do
      assert @doc.attrs
      assert @doc.attrs.is_a? Doc::AttrSet
      assert a = @doc.attrs["new attr"]
      assert a.is_a? Attr
      assert @doc.attrs["new attr"] === a
      assert_equal @doc, a.doc
    end

    it "should return the right value for name" do
      assert_equal "Bob", @doc.name
    end

    it "should not start out assigned to anyone" do
      assert_nil @doc.assignee
    end
    
    it "should automatically sanitize content on save" do
      @doc.content = "<span class=\"invalid-class\">Sanitized</span>"
      assert @doc.save
      assert_equal "Sanitized", @doc.content
    end

    describe "having been saved" do
      setup do
        assert @doc.save
      end

      it "should have a position" do
        assert_not_nil @doc.position
      end
    end

    describe "with an attr" do
      setup do
        assert @doc.save
        @attr_name = "Favorite Color"
        assert @attr = @doc.attrs[@attr_name]
      end

      it "should return the same attr on subsequent obtains" do
        assert attr = @doc.attrs[@attr_name]
        assert attr === @attr
      end

      describe "with choices" do
        setup do
          assert @ta = @doc.doc_template.doc_template_attrs.create(:name => @attr_name,
            :ui_type => "multiple", :choices => %w{red green blue})
        end

        it "should accept hash values for attrs_attributes=" do
          @doc.attrs_attributes = [ 
            { 
              'name' => @attr.name, 
              'multiple_value' => { 
                0 => { 'choice' => "red", 'selected' => true },
                1 => { 'choice' => "green", 'selected' => true },
                2 => { 'choice' => "blue", 'selected' => false } 
              } 
            }
          ]
          assert_equal "red, green", @attr.value
        end
      end
      
      it "should sanitize attr content on save" do
        @attr.value = "<badelement>Content</badelement>"
        assert @doc.save
        assert_equal "Content", @doc.attrs[@attr_name].value
      end

      describe "having a value" do
        setup do
          @attr.value = "Yellow"
        end

        it "should return the right value on retrieval" do
          assert_equal "Yellow", @doc.attrs[@attr_name].value
        end

        it "should respond appropriately to attrs_attributes" do
          assert @avs = @doc.attrs_attributes
          assert_equal "Yellow", @avs.select { |pair| pair['name'] == @attr_name }.first['value']
          assert_equal 1, @avs.size
        end

        it "should take attr values from attrs_attributes=" do
          @doc.attrs_attributes = [ { 'name' => @attr.name, 'value' => "Fuschia" } ]
          assert_equal "Fuschia", @attr.value
          assert_equal "Fuschia", @doc.attrs[@attr.name].value
          assert_equal "Fuschia", @doc.attrs_attributes.select {|pair| pair['name'] == @attr_name }.first['value']
        end

        it "should take attr values from slugified attrs_attributes=" do
          name = @attr.name
          @doc.attrs_attributes = [ { 'name' => Attr::WithSlug.slug_for(name), 'value' => "Hot pink" } ]
          assert_equal "Hot pink", @attr.value
          assert_equal name, @attr.name
          assert_equal Attr::WithSlug.slug_for(name), @attr.slug
        end

        describe "having been saved" do
          setup do
            @version1 = @doc.version
            assert @doc.save
            assert @doc = Doc.find(@doc.id)
            @version2 = @doc.version
          end

          it "should have an updated version number" do
            assert_equal @version1 + 1, @version2
          end

          it "should return the right value on retrieval" do
            assert_equal "Yellow", @doc.attrs[@attr_name].value
          end

          it "should not have modified the old version" do
            assert @old_doc = @doc.find_version(@version1)
            assert @old_doc.attrs.find_by_name(@attr_name).nil?
          end

          describe "and the attr value changed" do
            setup do
              @doc.attrs[@attr_name].value = "Red"
              assert @doc.save
              assert @doc = Doc.find(@doc.id)
              @version3 = @doc.version
            end

            it "should preserve the version history" do
              assert @doc1 = @doc.find_version(@version1)
              assert @doc2 = @doc.find_version(@version2)
              assert @doc3 = @doc.find_version(@version3)

              assert @doc1.attrs.find_by_name(@attr_name).nil?
              assert_equal "Yellow", @doc2.attrs.find_by_name(@attr_name).value
              assert_equal "Red", @doc3.attrs.find_by_name(@attr_name).value
            end
          end

          describe "and the attr deleted" do
            setup do
              assert @doc.attrs_attributes.any? { |attrs| attrs['name'] == @attr_name }
              @doc.attrs.delete(@attr_name)
              assert !@doc.attrs_attributes.any? { |attrs| attrs['name'] == @attr_name }

              assert @doc.save
              assert @doc = Doc.find(@doc.id)
              @version3 = @doc.version
            end

            it "should not have the attr in the working set" do
              assert !@doc.attrs_attributes.any? {|attrs| pair['name'] == @attr_name }
            end

            it "should not have the attr on the latest version" do
              assert @doc3 = @doc.find_version(@version3)
              assert_nil @doc3.attrs.find_by_name(@attr_name)
            end

            it "should still have the attr on the previous version" do
              assert @doc2 = @doc.find_version(@version2)
              assert_equal "Yellow", @doc2.attrs.find_by_name(@attr_name).value
            end
          end
        end
      end
    end

    describe "with a related doc" do
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

      it "should show the relationship on both docs" do
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

    describe "with template attrs" do
      setup do
        @doc_template = @doc.doc_template
        assert @doc_template_attr = @doc_template.doc_template_attrs.new(:name => "Age")
        @doc_template.doc_template_attrs << @doc_template_attr
        assert @doc_template.doc_template_attrs.include? @doc_template_attr

        @doc.reload_working_attrs
        assert @doc.doc_template.doc_template_attrs.include? @doc_template_attr
      end

      it "should automatically include the template attrs" do
        assert @doc.attrs.any? { |attr| attr.name == @doc_template_attr.name }

        attr = @doc.attrs.select { |attr| attr.name == @doc_template_attr.name }.first
        assert attr.from_template?
        assert_equal @doc_template_attr, attr.template_attr
      end
    end
  end
end
