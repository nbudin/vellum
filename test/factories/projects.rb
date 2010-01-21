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
end

Factory.define(:publication_template) do |pt|
  pt.association :project, :factory => :project
end

Factory.define :map do |map|
  
end