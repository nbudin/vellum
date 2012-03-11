class MappedDocTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :map
  belongs_to :doc_template
  
  field :color, type: String

  def color
    read_attribute(:color).sub(/^([0-9a-f]+)$/i, "\#\\1")
  end
end
