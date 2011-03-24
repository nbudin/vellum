#def selected_option_label(field)
#  field_labeled(field).element.xpath(".//option[@selected = 'selected']").first.inner_html
#end

#Then /^the "([^\"]*)" field should have "([^\"]*)" selected$/ do |field, value|
#  label = selected_option_label(field)
#  if defined?(Spec::Rails::Matchers)
#    label.should =~ /#{value}/
#  else
#    assert_match(/#{value}/, label)
#  end
#end

#Then /^the "([^\"]*)" field should not have "([^\"]*)" selected$/ do |field, value|
#  label = selected_option_label(field)
#  if defined?(Spec::Rails::Matchers)
#    label.value.should_not =~ /#{value}/
#  else
#    assert_no_match(/#{value}/, label)
#  end
#end

#When /^(?:|I )press "([^\"]*)" within "([^\"]*)"$/ do |button, selector|
#  within selector do
#    click_button(button)
#  end
#end

#When /^(?:|I )check "([^\"]*)" within "([^\"]*)"$/ do |field, selector|
#  within selector do
#    check(field)
#  end
#end

#When /^(?:|I )select "([^\"]*)" from "([^\"]*)" within "([^\"]*)"$/ do |choice, field, selector|
#  within selector do
#    When "I select \"#{choice}\" from \"#{field}\""
#  end
#end

#When /^(?:|I )fill in "([^\"]*)" with "([^\"]*)" within "([^\"]*)"$/ do |field, value, selector|
#  within selector do
#    When "I fill in \"#{field}\" with \"#{value}\""
#  end
#end

When /^(?:|I )select "([^\"]*)" and "([^\"]*)" from "([^\"]*)"$/ do |value1, value2, field|
  select([value1, value2], :from => field)
end

Then /^(?:|I )should(?:n\'t| not) be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).select(:path, :query).compact.join('?')
  if defined?(Spec::Rails::Matchers)
    current_path.should_not == path_to(page_name)
  else
    assert path_to(page_name) != current_path
  end
end