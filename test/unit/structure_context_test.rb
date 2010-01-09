require File.dirname(__FILE__) + '/../test_helper'

class StructureContextTest < ActiveSupport::TestCase
  context "A VPub context" do
    setup do
      @person = Factory.create(:structure_template, :name => "Person")
        
      @project = Factory.create(:project, :template_schema => @person.template_schema)
      @bob = Factory.build(:structure, :structure_template => @person, 
        :project => @project, :name => "Bob")
      
      @context = StructureContext.new(@bob)
      @parser = Radius::Parser.new(@context, :tag_prefix => 'v')
    end
  
    should "parse a minimal template" do
      assert_equal "test", @parser.parse("test")
    end
    
    should "return a structure's name" do
      assert_equal "Bob", @parser.parse('<v:name/>')
    end
    
    context "with a valued attribute" do
      setup do
        @height_attr = Factory.create(:attr, :name => "Height", :structure_template => @person,
          :attr_configuration => Factory.create(:text_field))
        
        @bob_height = @bob.obtain_attr_value("Height")
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
    
    context "with a doc attribute" do
      setup do
        @notes_attr = Factory.create(:attr, :name => "Notes", :structure_template => @person,
          :attr_configuration => Factory.create(:doc_field))
        
        @bob_notes = @bob.obtain_attr_value("Notes")
        @bob_notes.doc_content = "<p>Bob is a <b>good</b> guy.</p>"
      end
      
      should "return the doc content" do
        assert_equal @bob_notes.doc_content, @parser.parse('<v:attr:doc:content name="Notes"/>')
        assert_equal @bob_notes.doc_content, @parser.parse('<v:attr:doc name="Notes"><v:content /></v:attr:doc>')
        assert_equal @bob_notes.doc_content, @parser.parse('<v:attr name="Notes"><v:doc:content/></v:attr>')
        assert_equal @bob_notes.doc_content, @parser.parse('<v:attr name="Notes"><v:doc><v:content/></v:doc></v:attr>')
      end
      
      should "return the doc content in the specified format" do
        assert_equal @bob_notes.doc_content(:fo), @parser.parse('<v:attr:doc:content name="Notes" format="fo"/>')
        @context.format = 'fo'
        assert_equal @bob_notes.doc_content(:fo), @parser.parse('<v:attr:doc:content name="Notes"/>')
      end
    end
    
    context "with a related structure" do
      setup do
        @taller = @person.template_schema.relationship_types.create(
          :left_template => @person, :right_template => @person,
          :left_description => "is taller than", :right_description => "is shorter than")
        
        @bob.save
        @joe = Factory.create(:structure, :structure_template => @person, 
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