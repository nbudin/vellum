class MappedStructureTemplate < ActiveRecord::Base
  belongs_to :map
  belongs_to :structure_template
  
  def color
    read_attribute(:color).sub(/^([0-9a-f]+)$/i, "\#\\1")
  end
end
