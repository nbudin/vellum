class RelationshipType < ActiveRecord::Base
  belongs_to :template_schema
  has_many :relationships, :dependent => destroy
end
