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
end
