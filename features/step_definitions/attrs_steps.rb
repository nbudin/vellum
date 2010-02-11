Given /^a text field named "(.*)" on (.*)$/ do |name, template_name|
  assert tmpl = DocTemplate.find_by_name(template_name)
  assert attr = tmpl.doc_template_attrs.create(:name => name, :ui_type => "text")
end