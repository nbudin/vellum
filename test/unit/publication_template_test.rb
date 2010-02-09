require 'test_helper'

class PublicationTemplateTest < ActiveSupport::TestCase
  context "A publication template" do
    setup do
      @person = Factory.create(:doc_template, :name => "Person")
        
      @project = @person.project
      @tmpl = Factory.build(:publication_template, :project => @project)
      @bob = Factory.build(:doc, :doc_template => @person,
        :project => @project, :name => "Bob")
    end
    
    should "return a parsed template" do
      @tmpl.content = "Hello, my name is <v:name/>"
      assert_equal "Hello, my name is #{@bob.name}", @tmpl.execute(@bob)
    end
  end
end
