class Doc < ActiveRecord::Base
  acts_as_versioned

  has_one :doc_value
  validates_presence_of :doc_value
  belongs_to :author, :class_name => "Person"
  
  def project
    doc_value.project
  end
  
  def to_param
    if doc_value && doc_value.field && doc_value.field.attr
      "#{id}-#{doc_value.field.attr.name.parameterize}"
    else
      id.to_s
    end
  end
end
