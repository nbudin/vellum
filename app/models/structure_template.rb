class StructureTemplate < ActiveRecord::Base
  acts_as_tree
  has_many :attrs, :order => "position", :dependent => :destroy
  has_many :required_attrs, :class_name => "Attr", :conditions => "required = 1"
  has_many :attr_configurations, :through => :attrs
  belongs_to :template_schema
  has_many :projects, :through => :template_schema
  has_many :outward_relationship_types, :foreign_key => :left_template_id, :class_name => "RelationshipType", :dependent => :destroy
  has_many :inward_relationship_types, :foreign_key => :right_template_id, :class_name => "RelationshipType", :dependent => :destroy
  has_many :structures, :dependent => :destroy

  def plural_name
    # later we may want to add the possibility to override this
    name.pluralize
  end

  def relationship_types
    outward_relationship_types + inward_relationship_types
  end

  def attr(name)
    if name.kind_of? Attr
      name
    else
      a = attrs.select {|attr| attr.name == name }[0]
      if a
        return a
      elsif not parent.nil?
        return parent.attr(name)
      end
    end
  end

  def inherited_attrs
    if parent
      parent.attrs + parent.inherited_attrs
    else
      []
    end
  end
end
