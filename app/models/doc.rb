class Doc < ActiveRecord::Base
  acts_as_versioned

  belongs_to :project
  belongs_to :author, :class_name => "Person"
  non_versioned_columns << "project_id"
end
