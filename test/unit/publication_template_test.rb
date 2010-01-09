require 'test_helper'

class PublicationTemplateTest < ActiveSupport::TestCase
  context "A publication template" do
    setup do
      @person = Factory.create(:structure_template, :name => "Person")
      @tmpl = Factory.build(:publication_template, :template_schema => @person.template_schema)
        
      @project = Factory.create(:project, :template_schema => @person.template_schema)
      @bob = Factory.build(:structure, :structure_template => @person, 
        :project => @project, :name => "Bob")
    end
    
    should "return a parsed template" do
      @tmpl.content = "Hello, my name is <v:name/>"
      assert_equal "Hello, my name is #{@bob.name}", @tmpl.execute(@bob)
    end
  end
end
