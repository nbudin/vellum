class Structure < ActiveRecord::Base
  belongs_to :template
  has_many :attribute_value_metadatas
  has_many :attributes, :through => :attribute_value_metadatas
  
  def attribute_values
    attribute_value_metadatas.collect { |m| m.value }
  end
  
  def attribute_value(attribute)
    attribute_value_metadatas.find_by_attribute_id(attribute.id).value
  end
end
