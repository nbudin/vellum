class Structure < ActiveRecord::Base
  belongs_to :structure_template
  belongs_to :project
  has_many :attr_value_metadatas, :dependent => :destroy, :include => [:value]
  has_many :template_attrs, :through => :structure_template, :source => :attrs
  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship", :dependent => :destroy
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship", :dependent => :destroy
  belongs_to :assignee, :class_name => "Person"
  acts_as_list
  
  def scope_condition
    "project_id = #{project.id} and structure_template_id = #{structure_template.id}"
  end

  validates_associated :attr_value_metadatas
  validate :check_required_attrs
  
  after_save :save_avms_and_attr_values
  
  def to_param
    if name
      "#{id}-#{name.parameterize}"
    else
      id.to_s
    end
  end

  def generated_name
    name_attr = attr("Name")
    n = nil
    if name_attr
      begin
        n = attr_value(name_attr).string_rep
      rescue
      end
    end
    if n.blank?
      return "#{structure_template.name} #{id}"
    else
      return n
    end
  end
  
  def attr_values=(values)
    values.each do |attr_id, value|
      if not value.blank?       
        a = obtain_attr(attr_id.to_i)
        unless a
          errors.add_to_base("Attribute #{attr_id} doesn't exist for #{structure_template.plural_name}")
        end
        av = obtain_attr_value(a)
        av.attributes = value
      end
    end
  end

  def attr_values
    attr_value_metadatas.collect { |m| m.value }
  end

  def avm_for_attr(a)
    a = self.attr(a)
    attr_value_metadatas.select { |avm| avm.attr == a }.first
  end

  def obtain_avm_for_attr(a)
    a = self.obtain_attr(a)
    attr_value_metadatas.select { |avm| avm.attr == a }.first || attr_value_metadatas.build(:attr => a, :structure => self)
  end

  def attr_value(a)
    avm = avm_for_attr(a)
    avm && avm.value
  end

  def obtain_attr_value(a)
    obtain_avm_for_attr(a).obtain_value
  end

  def relationships
    outward_relationships + inward_relationships
  end
  
  def related_structures(relationship_type, direction)
    relationships = case direction.to_sym
    when :inward
      inward_relationships
    when :outward
      outward_relationships
    end
    
    relationships.reject! { |r| r.relationship_type != relationship_type }
    case direction.to_sym
    when :inward
      relationships.collect { |r| r.left }
    when :outward
      relationships.collect { |r| r.right }
    end
  end
  
  def attrs
    attr_value_metadatas.collect { |avm| avm.attr }.flatten.compact
  end

  def attr(name)
    if name.kind_of? Attr
      if name.structure_template == self.structure_template
        name
      else
        attrs.select {|a| a.id == name.id }.first
      end
    elsif name.kind_of? Fixnum
      attrs.select {|a| a.id == name }.first
    else
      attrs.select {|a| a.name == name }.first
    end
  end    

  # Get the attribute (not the attribute value!) associated with this structure, by name.
  # If this attribute's value is uninitialized, build a new (unsaved) AVM.
  def obtain_attr(name)
    a = attr(name)
    if a.nil? and (ta = structure_template.attr(name))
      avm = attr_value_metadatas.select { |avm| avm.attr == ta }.first || attr_value_metadatas.build(:structure => self, :attr => ta)
      avm.obtain_value
      return ta
    else
      return a
    end
  end
  
  def obtain_workflow_status
    if workflow_status.nil?
      create_workflow_status :workflow_step => structure_template.workflow.start_step
    end
    workflow_status
  end

  private
  def check_required_attrs
    structure_template.required_attrs.each do |ta|
      if not attrs.include?(ta)
        errors.add_to_base("Required attribute #{ta.name} is not populated.")
      end
    end
  end
  
  def save_avms_and_attr_values
    attr_value_metadatas.each do |avm|
      avm.save(false)
      unless avm.value.nil?
        avm.value.save(false)
      end
    end
  end
end
