class Template < ActiveRecord::Base
  acts_as_tree
  has_many :attributes, :order => "position", :dependent => :destroy
  has_many :attribute_configurations, :through => :attributes
  belongs_to :project
  belongs_to :template_schema
  has_many :outward_relationships, :as => :left, :class_name => "Relationship"
  has_many :inward_relationships, :as => :right, :class_name => "Relationship"
  
  def relationships
    outward_relationships + inward_relationships
  end
end
