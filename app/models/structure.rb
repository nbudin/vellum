class Structure < ActiveRecord::Base
  belongs_to :template
  has_many :attr_value_metadatas
  has_many :attrs, :through => :attr_value_metadatas
  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship"
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship"

  def attr_values
    attr_value_metadatas.collect { |m| m.value }
  end

  def attr_value(a)
    attr_value_metadatas.find_by_attr_id(self.attr(a).id).value
  end

  def relationships
    outward_relationships + inward_relationships
  end

  # Get the attribute (not the attribute value!) associated with this structure, by name.
  # If this attribute's value is uninitialized, create an AVM implicitly.
  def attr(name)
    if name.kind_of? Attr
      return name
    else
      a = attrs.find_by_name(name)
      if a.nil? and (ta = template.attr(name))
        avm = attr_value_metadatas.create :attr => ta
        return ta
      else
        return a
      end
    end
  end
end
