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

Factory.define :character, :class => "StructureTemplate" do |tmpl|
  tmpl.name "Character"
  tmpl.after_build do |t|
    hp = t.attrs.new :name => "HP"
    hp.attr_configuration = NumberField.new
    t.attrs << hp
  end
end

Factory.define :organization, :class => "StructureTemplate" do |tmpl|
  tmpl.name "Organization"
end

Factory.define :louisiana_purchase, :class => "Project" do |project|
  project.name "Louisiana Purchase"
  project.after_build do |p|
    char = Factory.build(:character)
    org = Factory.build(:organization)
    [char, org].each do |tmpl|
      tmpl.project = p
      p.structure_templates << tmpl
    end
    p.structure_templates += [char, org]
    
    includes = RelationshipType.new(
      :left_template => org,
      :right_template => char,
      :left_description => "includes",
      :right_description => "is part of",
      :project => p
    )
    p.relationship_types << includes

    louis = Structure.new(:structure_template => char, :name => "King Louis", :project => p)
    avm = louis.attr_value_metadatas.new(:attr => char.attr("HP"))
    avm.value = NumberValue.new(:value => 10)
    louis.attr_value_metadatas << avm
    p.structures << louis

    france = Structure.new(:structure_template => org, :name => "France", :project => p)
    p.structures << france

    rel = Relationship.new(:relationship_type => includes, :left => france, :right => louis, :project => p)
    p.relationships << rel
  end

  project.after_create do |p|
    p.structure_templates.each do |t|
      t.attrs.each do |a|
        a.save!
        a.attr_configuration.save! if a.attr_configuration
      end
      t.save!
    end
    
    p.relationship_types.each do |rt|
      rt.save!
    end

    p.structures.each do |s|
      s.attr_value_metadatas.each do |avm|
        avm.save!
        avm.value.save! if avm.value
      end
      s.save!
    end

    p.relationships.each do |r|
      r.save!
    end
  end
end