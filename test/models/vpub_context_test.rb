require File.expand_path('../../test_helper', __FILE__)

class VPubContextTest < ActiveSupport::TestCase
  describe "A VPub context" do
    setup do
      @person = FactoryGirl.create(:doc_template, :name => "Person")
        
      @project = @person.project
      @bob = FactoryGirl.build(:doc, :doc_template => @person,
        :project => @project, :name => "Bob", :content => "<p>Here we have <b>Bob</b>.<br/>Bob likes to ski.</p>")
      
      @context = VPubContext.new(:project => @project, :doc => @bob)
      @parser = Radius::Parser.new(@context, :tag_prefix => 'v')
    end
  
    it "should parse a minimal template" do
      assert_equal "test", @parser.parse("test")
    end
    
    it "should return a structure's name" do
      assert_equal "Bob", @parser.parse('<v:name/>')
    end
    
    it "should return the doc's content" do
      assert_equal @bob.content, @parser.parse('<v:content/>')
      @fo_content = FormatConversions.convert(@bob.content, :fo)
      assert_equal @fo_content, @parser.parse('<v:content format="fo"/>')
      @context.format = "fo"
      assert_equal @fo_content, @parser.parse('<v:content/>')
    end

    it "should repeat content a static number of times" do
      assert_equal "test test test ", @parser.parse('<v:repeat times="3">test </v:repeat>')
      assert_equal "test test test ", @parser.parse('<v:repeat times="3 times">test </v:repeat>')
      assert_equal "", @parser.parse('<v:repeat times="0">test </v:repeat>')
      assert_equal "test ", @parser.parse('<v:repeat times="1">test </v:repeat>')
      assert_equal "test test test test test test test test test test test test ", @parser.parse('<v:repeat times="12">test </v:repeat>')
    end
    
    describe "with a valued attribute" do
      setup do
        @height_attr = @person.doc_template_attrs.create(:name => "Height")
        @cats_attr = @person.doc_template_attrs.create(:name => "Cats")
        
        @bob_height = @bob.attrs["Height"]
        @bob_height.value = "5 ft 7 in"

        @bob_cats = @bob.attrs["Cats"]
        @bob_cats.value = "3"
      end
      
      it "should return the attr value" do
        assert_equal "5 ft 7 in", @parser.parse('<v:attr:value name="Height"/>')
        assert_equal "5 ft 7 in", @parser.parse('<v:attr name="Height"><v:value/></v:attr>')
      end
            
      it "should evaluate an if-equal condition" do
        tmpl = "<v:attr:if_value name=\"Height\" eq=\"5 ft 7 in\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 5 in"
        assert_equal "", @parser.parse(tmpl)
      end
      
      it "should evaluate an if-not-equal condition" do
        tmpl = "<v:attr:if_value name=\"Height\" ne=\"6 ft 6 in\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 6 in"
        assert_equal "", @parser.parse(tmpl)
      end
      
      it "should evaluate an if-match condition" do
        tmpl = "<v:attr:if_value name=\"Height\" match=\"^5\\s+\">yes</v:attr:if_value>"
        assert_equal "yes", @parser.parse(tmpl)
        @bob_height.value = "6 ft 5 in"
        assert_equal "", @parser.parse(tmpl)
      end

      it "should repeat content based on an attr value" do
        assert_equal "kitty!kitty!kitty!", @parser.parse('<v:repeat times="@Cats">kitty!</v:repeat>')
        assert_equal "kitty!kitty!kitty!kitty!kitty!", @parser.parse('<v:repeat times="@Height">kitty!</v:repeat>')
      end
    end
    
    describe "with a per-document attribute" do
      setup do
        @bob.attrs["Favorite candy"].value = "Snickers"
        assert @person.save
      end
      
      it "should render the attribute" do
        tmpl = '<v:attr:value name="Favorite Candy"/>'
        assert_equal "Snickers", @parser.parse(tmpl)
      end
      
      it "should correctly evaluate an if_value for that attribute" do
        tmpl = '<v:attr:if_value name="Favorite Candy" eq="Snickers">yum</v:attr:if_value>'
        assert_equal "yum", @parser.parse(tmpl)

        tmpl = '<v:attr:if_value name="Favorite Candy" ne="Smarties">yuck</v:attr:if_value>'
        assert_equal "yuck", @parser.parse(tmpl)
      end
      
      it "should evaluate nonexistent per-document attributes as an empty string" do
        tmpl = '<v:attr:value name="Favorite Dog"/>'
        assert_equal "", @parser.parse(tmpl)
        
        tmpl = '<v:attr:if_value name="Favorite Dog" eq="">Guess he doesn\'t like dogs then</v:attr:if_value>'
        assert_equal "Guess he doesn't like dogs then", @parser.parse(tmpl)
      end
    end
    
    describe "with a rich text attribute" do
      setup do
        @notes_attr = @person.doc_template_attrs.create(:name => "Notes", :ui_type => "textarea")

        @bob_notes = @bob.attrs["Notes"]
        @bob_notes.value = "<p>Bob is a <b>good</b> guy.</p>"
      end
      
      it "should return the content" do
        assert_equal @bob_notes.value, @parser.parse('<v:attr:value name="Notes"/>')
        assert_equal @bob_notes.value, @parser.parse('<v:attr name="Notes"><v:value /></v:attr>')
      end
      
      it "should return the content in the specified format" do
        assert_equal @bob_notes.value(:fo), @parser.parse('<v:attr:value name="Notes" format="fo"/>')
        @context.format = 'fo'
        assert_equal @bob_notes.value(:fo), @parser.parse('<v:attr:value name="Notes"/>')
      end
    end
    
    describe "with a related structure" do
      setup do
        @taller = @project.relationship_types.create(
          :left_template => @person, :right_template => @person,
          :left_description => "is taller than", :right_description => "is shorter than")
        
        @bob.save
        @joe = FactoryGirl.create(:doc, :doc_template => @person,
          :project => @project, :name => "Joe")
        @bob_taller = FactoryGirl.create(:relationship, :relationship_type => @taller,
          :left => @bob, :right => @joe, :project => @project)
        @bob.reload
      end
      
      it "should iterate through relationships" do
        assert_equal @joe.name, @parser.parse('<v:each_related how="is taller than"><v:name/></v:each_related>')
      end
      
      it "should iterate through docs by template" do
        assert_equal "BobJoe", @parser.parse('<v:each_doc template="Person"><v:name/></v:each_doc>')
        assert_equal "JoeBob", @parser.parse('<v:each_doc template="Person" sort="-@name"><v:name/></v:each_doc>')
      end
      
      describe "in a recursive loop" do
        setup do
          @joe_taller = FactoryGirl.create(:relationship, :relationship_type => @taller,
            :left => @joe, :right => @bob, :project => @project)
          @bob.reload
          @joe.reload
        end
        
        it "should not enter an infinite loop" do
          assert_equal @joe.name, @parser.parse('<v:each_related how="is taller than"><v:name/></v:each_related>')
        end
      end
      
      describe "and another related structure" do
        setup do
          @tim = FactoryGirl.create(:doc, :doc_template => @person,
            :project => @project, :name => "Tim")
          @tim_taller = FactoryGirl.create(:relationship, :relationship_type => @taller,
            :left => @bob, :right => @tim, :project => @project)
            
          @tim.attrs['Favorite Color'].value = 'green'
          @tim.attrs['Sandwich'].value = 'BLT'
          @tim.attrs['Number'].value = '13'
          @tim.save
          @joe.attrs['Favorite Color'].value = 'blue'
          @joe.attrs['Sandwich'].value = 'BLT'
          @joe.attrs['Number'].value = '5'
          @joe.save
          
          @bob.reload
        end
        
        it "should sort properly" do
          assert_equal "#{@joe.name}#{@tim.name}",
            @parser.parse('<v:each_related how="is taller than" sort="@name"><v:name/></v:each_related>')
          assert_equal "#{@tim.name}#{@joe.name}",
            @parser.parse('<v:each_related how="is taller than" sort="-@name"><v:name/></v:each_related>')
          
          assert_equal "#{@joe.name}#{@tim.name}",
            @parser.parse('<v:each_related how="is taller than" sort="Favorite Color"><v:name/></v:each_related>')
          assert_equal "#{@tim.name}#{@joe.name}",
            @parser.parse('<v:each_related how="is taller than" sort="-Favorite Color"><v:name/></v:each_related>')
          
          assert_equal "#{@joe.name}#{@tim.name}",
            @parser.parse('<v:each_related how="is taller than" sort="Sandwich, Favorite Color"><v:name/></v:each_related>')
          assert_equal "#{@tim.name}#{@joe.name}",
            @parser.parse('<v:each_related how="is taller than" sort="-Sandwich, -Favorite Color"><v:name/></v:each_related>')
          
          assert_equal "#{@joe.name}#{@tim.name}",
            @parser.parse('<v:each_related how="is taller than" sort="#Number"><v:name/></v:each_related>')
          assert_equal "#{@tim.name}#{@joe.name}",
            @parser.parse('<v:each_related how="is taller than" sort="-#Number"><v:name/></v:each_related>')
        end
      end
    end
    
    describe "with an included PublicationTemplate" do
      setup do
        @other_template = FactoryGirl.create(:publication_template, :project => @project, :name => "Another template",
          :content => "Included content, with the doc name <v:name/>")
      end
      
      it "should include the content from the other PublicationTemplate with appropriate context" do
        assert_equal "My content\nIncluded content, with the doc name Bob\nMore content Bob",
          @parser.parse("My content\n<v:include template=\"Another template\"/>\nMore content <v:name/>")
      end
      
      it "should enforce doc template restrictions" do
        assert @tree = @project.doc_templates.create(:name => "Tree")
        @other_template.doc_template = @tree
        assert @other_template.save
        
        exc = assert_raise VPubContext::VPubRuntimeError do
          @parser.parse("My content\n<v:include template=\"Another template\"/>\nMore content <v:name/>")
        end
        
        assert_equal "Included template \"Another template\" requires a Tree but the current doc is a Person", exc.message
      end
    end
    
    describe "with a layout" do
      setup do
        @layout = FactoryGirl.create(:publication_template, project: @project, name: "Layout", 
          content: "<section><v:yield/></section>")
        @publication_template = FactoryGirl.create(:publication_template, layout: @layout, content: "<h1>Doc content</h1>")
        @context = VPubContext.new(:project => @project, :doc => @bob, publication_template: @publication_template)
      end
      
      it "should render in the layout" do
        assert_equal "<section><h1>Doc content</h1></section>", @publication_template.execute({})
      end
      
      describe "in a nested layout" do
        setup do
          @outer_layout = FactoryGirl.create(:publication_template, project: @project, name: "Outer Layout",
            content: "<html><body><v:yield/></body></html>")
          @layout.update_attributes(layout: @outer_layout)
        end
        
        it "should render in both layouts" do
          assert_equal "<html><body><section><h1>Doc content</h1></section></body></html>", @publication_template.execute({})
        end
      end
    end
  end
end