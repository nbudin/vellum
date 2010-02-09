require 'test_helper'

class AssignmentMailerTest < ActionMailer::TestCase
  context "just assigned a character" do
    setup do
      @tmpl = Factory.create(:doc_template, :name => "Character")
      @project = @tmpl.project
      @project.name = "Intrigue Under the Big Tent"
      assert @project.save
      @structure = @project.docs.new(:doc_template => @tmpl, :name => "Joey")

      @person = Person.create(:firstname => "Bob", :lastname => "Writerson")

      @site_settings = SiteSettings.instance
      @site_settings.site_email = "vellumtest@example.com"
      assert @site_settings.save
      
      @structure.assignee = @person
      assert @structure.save
    end

    should "send the assignee an email" do
      @expected.subject = "[#{@project.name}] #{@structure.name} has been assigned to you"
      @expected.from = @site_settings.site_email
      @expected.body = "The #{@tmpl.name} \"#{@structure.name}\" in the project \"#{@project.name}\" has just been assigned to you."
      @expected.date = Time.now

      assert_equal @expected.encoded, AssignmentMailer.create_assigned_to_you(@structure, nil, @expected.date).encoded
      assert_equal @expected.encoded, AssignmentMailer.create_assigned_to_you(@structure, @person, @expected.date).encoded
    end
  end
end
