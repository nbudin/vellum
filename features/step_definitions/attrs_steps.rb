Given /^a text field named "(.*)" on (.*)$/ do |name, template_name|
  assert tmpl = StructureTemplate.find_by_name(template_name)
  assert attr = tmpl.attrs.create(:name => name)
  assert field = TextField.create()
  attr.attr_configuration = field
  attr.save!
end