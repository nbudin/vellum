class Doc < ActiveRecord::Base
  acts_as_versioned

  belongs_to :project
  non_versioned_columns << "project_id"
end
