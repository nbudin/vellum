Factory.define :project do |p|
end

Factory.define :structure do |s|
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
    rel.relationship_type ||= Factory.build(:relationship_type, :template_schema => rel.project.template_schema)
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