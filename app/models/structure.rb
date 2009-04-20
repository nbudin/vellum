class Structure < ActiveRecord::Base
  belongs_to :structure_template
  belongs_to :project
  has_many :attr_value_metadatas
  has_many :template_attrs, :through => :structure_template, :source => :attrs
  has_many :attrs, :through => :attr_value_metadatas
  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship"
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship"

  validates_associated :attr_value_metadatas
  validate { |s|
    s.structure_template.required_attrs.each do |ta|
      if not s.attrs.include?(ta)
        s.errors.add_to_base("Required attribute #{ta.name} is not populated.")
      end
    end
  }
  
  def name
    name_attr = attr("Name")
    if name_attr.nil?
      return "#{structure_template.name} #{id}"
    else
      return attr_value(name_attr).string_rep
    end
  end

  def attr_values
    attr_value_metadatas.collect { |m| m.value }
  end

  def attr_value(a)
    a = self.attr(a)
    logger.debug "#{a.name} has id #{a.id}"
    attr_value_metadatas.find_by_attr_id(a.id).value
  end

  def relationships
    outward_relationships + inward_relationships
  end

  # Get the attribute (not the attribute value!) associated with this structure, by name.
  # If this attribute's value is uninitialized, create an AVM implicitly.
  def attr(name)
    if name.kind_of? Attr
      a = attrs.find_by_id(name.id)
    else
      a = attrs.find_by_name(name)
    end
    
    if a.nil? and (ta = structure_template.attr(name))
      logger.info "Template attr #{ta.name} does not exist for structure #{self.id}; autocreating"
      avm = attr_value_metadatas.create :structure => self, :attr => ta
      return ta
    else
      return a
    end
  end
end
