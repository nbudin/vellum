Factory.define(:template_schema) do |schema|
  schema.name "My awesome templates"
end

Factory.define(:workflow) do |workflow|
end

Factory.define(:workflow_step) do |step|
  step.association :workflow, :factory => :workflow
end

Factory.define(:workflow_transition) do |trans|
  trans.association :from, :factory => :workflow_step
  trans.association :to, :factory => :workflow_step
end

Factory.define(:structure_template) do |t|
  t.association :template_schema, :factory => :template_schema
  t.association :workflow, :factory => :workflow
  t.name "A structure template"
end

Factory.define(:attr) do |a|
  a.association :structure_template, :factory => :structure_template
  a.name "An attr"
end

Factory.define :text_field do

end

Factory.define :number_field do

end

Factory.define :choice_field do |f|
  
end

Factory.define :doc_field do
  
end

Factory.define :choice do
end

Factory.define :radio_choice_field do |f|
  f.attr { |cf| cf.association(:attr, :name => "Filing status") }
  
end

Factory.define(:relationship_type) do |rt|
  rt.association :left, :factory => :structure_template
  rt.association :right, :factory => :structure_template
end

Factory.define(:publication_template) do |pt|
  pt.association :template_schema, :factory => :template_schema
end
