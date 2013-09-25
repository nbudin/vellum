require 'test_helper'

class AnonymousBrowseIntegrationTest < ActionController::IntegrationTest
  test 'projects page' do
    visit projects_url
    
    assert has_content?("Projects")
    assert has_content?("Log in")
    assert has_no_content?("Create")
  end
end