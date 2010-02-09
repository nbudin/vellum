Factory.define :project do |p|
end

Factory.define(:doc_template) do |t|
  t.association :project, :factory => :project
  t.name "A doc template"
end

Factory.define(:relationship_type) do |rt|
  rt.association :project, :factory => :project
  rt.after_build do |t|
    %w{left_template right_template}.each do |m|
      tmpl = Factory.build(:doc_template, :project => t.project)
      t.send("#{m}=", tmpl)
    end
  end
end

Factory.define :doc do |d|
  d.association :project, :factory => :project
  d.after_build do |doc|
    doc.doc_template ||= Factory.build(:doc_template, :project => doc.project)
  end
end

Factory.define :relationship do |r|
  r.association :project, :factory => :project
  r.after_build do |rel|
    rel.relationship_type ||= Factory.build(:relationship_type, :project => rel.project)
    rel.left ||= Factory.build(:doc, :project => rel.project,
      :doc_template => rel.relationship_type.left_template)
    rel.right ||= Factory.build(:doc, :project => rel.project,
      :doc_template => rel.relationship_type.right_template)
  end
end

Factory.define(:publication_template) do |pt|
  pt.association :project, :factory => :project
end

Factory.define :map do |map|
  
end

Factory.define :character, :class => "DocTemplate" do |tmpl|
  tmpl.name "Character"
  tmpl.after_build do |t|
    hp = t.doc_template_attrs.new(:name => "HP")
    hp.ui_type = "text"
    t.doc_template_attrs << hp
  end
end

Factory.define :organization, :class => "DocTemplate" do |tmpl|
  tmpl.name "Organization"
end

Factory.define :louisiana_purchase, :class => "Project" do |project|
  project.name "Louisiana Purchase"
  project.after_build do |p|
    char = Factory.build(:character)
    org = Factory.build(:organization)
    [char, org].each do |tmpl|
      tmpl.project = p
      p.doc_templates << tmpl
    end
    
    includes = RelationshipType.new(
      :left_template => org,
      :right_template => char,
      :left_description => "includes",
      :right_description => "is part of",
      :project => p
    )
    p.relationship_types << includes

    louis = Doc.new(:doc_template => char, :name => "King Louis", :project => p)
    louis.attrs["HP"].value = 10
    p.docs << louis

    france = Doc.new(:doc_template => org, :name => "France", :project => p)
    p.docs << france

    rel = Relationship.new(:relationship_type => includes, :left => france, :right => louis, :project => p)
    p.relationships << rel
  end

  project.after_create do |p|
    p.doc_templates.each do |t|
      t.doc_template_attrs.each do |a|
        a.save!
      end
      t.save!
    end
    
    p.relationship_types.each do |rt|
      rt.save!
    end

    p.docs.each do |d|
      d.save!
    end

    p.relationships.each do |r|
      r.save!
    end
  end
end