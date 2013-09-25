require 'test_helper'

class AssignmentMailerTest < ActionMailer::TestCase
  def assert_mail_equal(mail1, mail2)
    dm1 = mail1.dup
    dm2 = mail2.dup
    
    dm1.message_id = "message_id"
    dm2.message_id = "message_id"
    
    assert_equal mail1.encoded, mail2.encoded
  end
  
  context "just assigned a character" do
    setup do
      @tmpl = FactoryGirl.create(:doc_template, :name => "Character")
      @project = @tmpl.project
      @project.name = "Intrigue Under the Big Tent"
      assert @project.save
      @structure = @project.docs.new(:doc_template => @tmpl, :name => "Joey")

      @person = FactoryGirl.create(:person, :firstname => "Bob", :lastname => "Writerson")

      @site_settings = SiteSettings.instance
      @site_settings.site_email = "vellumtest@example.com"
      assert @site_settings.save
      
      @structure.assignee = @person
      assert @structure.save
    end

    should "send the assignee an email" do
      @expected.subject = "[#{@project.name}] #{@structure.name} has been assigned to you"
      @expected.from = @site_settings.site_email
      @expected.to = @person.email
      @expected.body = "The #{@tmpl.name} \"#{@structure.name}\" in the project \"#{@project.name}\" has just been assigned to you."
      @expected.content_type = "text/html"
      @expected.date = Time.now

      assert_mail_equal @expected, AssignmentMailer.assigned_to_you(@structure, nil, @expected.date)
      assert_mail_equal @expected, AssignmentMailer.assigned_to_you(@structure, @person, @expected.date)
    end
  end
end
