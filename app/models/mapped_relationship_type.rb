class MappedRelationshipType < ActiveRecord::Base
  belongs_to :map
  belongs_to :relationship_type
  
  def color
    read_attribute(:color).sub(/^([0-9a-f]+)$/i, "\#\\1")
  end
end
