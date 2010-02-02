def selected_option_label(field)
  field_labeled(field).element.xpath(".//option[@selected = 'selected']").first.inner_html
end

Then /^the "([^\"]*)" field should have "([^\"]*)" selected$/ do |field, value|
  label = selected_option_label(field)
  if defined?(Spec::Rails::Matchers)
    label.should =~ /#{value}/
  else
    assert_match(/#{value}/, label)
  end
end

Then /^the "([^\"]*)" field should not have "([^\"]*)" selected$/ do |field, value|
  label = selected_option_label(field)
  if defined?(Spec::Rails::Matchers)
    label.value.should_not =~ /#{value}/
  else
    assert_no_match(/#{value}/, label)
  end
end

When /^(?:|I )press "([^\"]*)" within "([^\"]*)"$/ do |button, selector|
  within selector do
    click_button(button)
  end
end

Then /^(?:|I )should(?:n\'t| not) be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).select(:path, :query).compact.join('?')
  if defined?(Spec::Rails::Matchers)
    current_path.should_not == path_to(page_name)
  else
    assert path_to(page_name) != current_path
  end
end