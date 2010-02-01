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