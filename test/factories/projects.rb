Factory.define :project do |p|
end

Factory.define(:structure_template) do |t|
  t.association :project, :factory => :project
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
  rt.association :project, :factory => :project
  rt.after_build do |t|
    %w{left_template right_template}.each do |m|
      tmpl = Factory.build(:structure_template, :project => t.project)
      t.send("#{m}=", tmpl)
    end
  end
end

Factory.define :structure do |s|
  s.association :project, :factory => :project
  s.after_build do |struct|
    struct.structure_template ||= struct.project.structure_templates.new
  end
end

Factory.define :attr_value_metadata do |avm|
end

Factory.define :doc_value do |doc_value|
end

Factory.define :doc do |doc|
end

Factory.define :relationship do |r|
  r.association :project, :factory => :project
  r.after_build do |rel|
    rel.relationship_type ||= Factory.build(:relationship_type, :project => rel.project)
    rel.left ||= Factory.build(:structure, :project => rel.project,
      :structure_template => rel.relationship_type.left_template)
    rel.right ||= Factory.build(:structure, :project => rel.project,
      :structure_template => rel.relationship_type.right_template)
  end
end

Factory.define(:publication_template) do |pt|
  pt.association :project, :factory => :project
end

Factory.define :map do |map|
  
end