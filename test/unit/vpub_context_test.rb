require File.dirname(__FILE__) + '/../test_helper'

class VPubContextTest < ActiveSupport::TestCase
  context "A VPub context" do
    setup do
      @person = Factory.create(:doc_template, :name => "Person")
        
      @project = @person.project
      @bob = Factory.build(:doc, :doc_template => @person,
        :project => @project, :name => "Bob", :content => "<p>Here we have <b>Bob</b>.<br/>Bob likes to ski.</p>")
      
      @context = VPubContext.new(:project => @project, :doc => @bob)
      @parser = Radius::Parser.new(@context, :tag_prefix => 'v')
    end
  
    should "parse a minimal template" do
      assert_equal "test", @parser.parse("test")
    end
    
    should "return a structure's name" do
      assert_equal "Bob", @parser.parse('<v:name/>')
    end
    
    should "return the doc's content" do
      assert_equal @bob.content, @parser.parse('<v:content/>')
      @fo_content = FormatConversions.html_to_fo(@bob.content)
      assert_equal @fo_content, @parser.parse('<v:content format="fo"/>')
      @context.format = "fo"
      assert_equal @fo_content, @parser.parse('<v:content/>')
    end
    
    context "with a valued attribute" do
      setup do
        @height_attr = @person.doc_template_attrs.create(:name => "Height")
        
        @bob_height = @bob.attrs["Height"]
        @bob_height.value = "5 ft 7 in"
      end
      
      should "return the attr value" do
        assert_equal "5 ft 7 in", @parser.parse('<v:attr:value name="Height"/>')
        assert_equal "5 ft 7 in", @parser.parse('<v:attr name="Height"><v:value/></v:attr>')
      end
            
      should "evaluate an if-equal condition" do
        tmpl = "<v:attr:if_value name=\"Height\" eq=\"5 ft 7 in\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 5 in"
        assert_equal "", @parser.parse(tmpl)
      end
      
      should "evaluate an if-not-equal condition" do
        tmpl = "<v:attr:if_value name=\"Height\" ne=\"6 ft 6 in\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 6 in"
        assert_equal "", @parser.parse(tmpl)
      end
      
      should "evaluate an if-match condition" do
        tmpl = "<v:attr:if_value name=\"Height\" match=\"^5\\s+\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 5 in"
        assert_equal "", @parser.parse(tmpl)
      end
    end
    
    context "with a rich text attribute" do
      setup do
        @notes_attr = @person.doc_template_attrs.create(:name => "Notes", :ui_type => "textarea")

        @bob_notes = @bob.attrs["Notes"]
        @bob_notes.value = "<p>Bob is a <b>good</b> guy.</p>"
      end
      
      should "return the content" do
        assert_equal @bob_notes.value, @parser.parse('<v:attr:value name="Notes"/>')
        assert_equal @bob_notes.value, @parser.parse('<v:attr name="Notes"><v:value /></v:attr>')
      end
      
      should "return the content in the specified format" do
        assert_equal @bob_notes.value(:fo), @parser.parse('<v:attr:value name="Notes" format="fo"/>')
        @context.format = 'fo'
        assert_equal @bob_notes.value(:fo), @parser.parse('<v:attr:value name="Notes"/>')
      end
    end
    
    context "with a related structure" do
      setup do
        @taller = @project.relationship_types.create(
          :left_template => @person, :right_template => @person,
          :left_description => "is taller than", :right_description => "is shorter than")
        
        @bob.save
        @joe = Factory.create(:doc, :doc_template => @person,
          :project => @project, :name => "Joe")
        @bob_taller = Factory.create(:relationship, :relationship_type => @taller,
          :left => @bob, :right => @joe, :project => @project)
        @bob.reload
      end
      
      should "iterate through relationships" do
        assert_equal @joe.name, @parser.parse('<v:each_related how="is taller than"><v:name/></v:each_related>')
      end
      
      context "in a recursive loop" do
        setup do
          @joe_taller = Factory.create(:relationship, :relationship_type => @taller,
            :left => @joe, :right => @bob, :project => @project)
          @bob.reload
          @joe.reload
        end
        
        should "not enter an infinite loop" do
          assert_equal @joe.name, @parser.parse('<v:each_related how="is taller than"><v:name/></v:each_related>')
        end
      end
    end
  end
end