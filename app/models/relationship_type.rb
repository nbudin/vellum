class RelationshipType < ActiveRecord::Base
  belongs_to :template_schema
  has_many :relationships, :dependent => destroy
  has_one :left_template, :class_name => "Template"
  has_one :right_template, :class_name => "Template"
end
