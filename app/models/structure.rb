class Structure < ActiveRecord::Base
  belongs_to :structure_template, :include => [:attrs]
  belongs_to :project
  has_many :attr_value_metadatas, :dependent => :destroy, :include => [:value]
  has_many :template_attrs, :through => :structure_template, :source => :attrs
  has_many :attrs, :through => :attr_value_metadatas
  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship", :dependent => :destroy, :include => [:relationship_type, :right]
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship", :dependent => :destroy, :include => [:relationship_type, :left]

  validates_associated :attr_value_metadatas
  validate :check_required_attrs

  def name
    name_attr = attr("Name")
    name = nil
    if name_attr
      begin
        name = attr_value(name_attr).string_rep
      rescue
      end
    end
    if name.blank?
      return "#{structure_template.name} #{id}"
    else
      return name
    end
  end

  def attr_values
    attr_value_metadatas.collect { |m| m.value }
  end

  def avm_for_attr(a)
    a = self.attr(a)
    attr_value_metadatas.select { |avm| avm.attr == a }[0]
  end

  def obtain_avm_for_attr(a)
    a = self.obtain_attr(a)
    attr_value_metadatas.select { |avm| avm.attr == a }[0]
  end

  def attr_value(a)
    avm_for_attr(a).value
  end

  def obtain_attr_value(a)
    obtain_avm_for_attr(a).obtain_value
  end

  def relationships
    outward_relationships + inward_relationships
  end

  def attr(name)
    if name.kind_of? Attr
      attrs.select {|a| a.id == name.id }[0]
    else
      attrs.select {|a| a.name == name }[0]
    end
  end    

  # Get the attribute (not the attribute value!) associated with this structure, by name.
  # If this attribute's value is uninitialized, create an AVM implicitly.
  def obtain_attr(name)
    a = attr(name)
    if a.nil? and (ta = structure_template.attr(name))
      logger.info "Template attr #{ta.name} does not exist for structure #{self.id}; autocreating"
      avm = attr_value_metadatas.create :structure => self, :attr => ta
      avm.obtain_value
      return ta
    else
      return a
    end
  end

  private
  def check_required_attrs
    structure_template.required_attrs.each do |ta|
      if not attrs.include?(ta)
        errors.add_to_base("Required attribute #{ta.name} is not populated.")
      end
    end
  end
end
