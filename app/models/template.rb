class Template < ActiveRecord::Base
  acts_as_tree
  has_many :attrs, :order => "position", :dependent => :destroy
  has_many :attr_configurations, :through => :attrs
  belongs_to :project
  belongs_to :template_schema
  has_many :outward_relationship_types, :foreign_key => :left_template_id, :class_name => "RelationshipType"
  has_many :inward_relationship_types, :foreign_key => :right_template_id, :class_name => "RelationshipType"

  def relationship_types
    outward_relationship_types + inward_relationship_types
  end

  def attr(name)
    if name.kind_of? Attr
      name
    else
      a = attrs.find_by_name(name)
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
