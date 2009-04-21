class Doc < ActiveRecord::Base
  acts_as_versioned

  has_many :doc_values
  belongs_to :author, :class_name => "Person"
  non_versioned_columns << "project_id"
end
