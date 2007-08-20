class Template < ActiveRecord::Base
  has_many :attributes
  has_many :attribute_configurations, :through => :attributes
  has_and_belongs_to_many :relationship_types
end
