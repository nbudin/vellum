class Structure < ActiveRecord::Base
  belongs_to :template
  has_many :attribute_value_metadatas
  has_many :attributes, :through => :attribute_value_metadatas
  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship"
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship"

  def attribute_values
    attribute_value_metadatas.collect { |m| m.value }
  end

  def attribute_value(attribute)
    attribute_value_metadatas.find_by_attribute_id(attribute.id).value
  end

  def relationships
    outward_relationships + inward_relationships
  end
end
