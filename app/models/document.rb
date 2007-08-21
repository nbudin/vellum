class Document < ActiveRecord::Base
  acts_as_versioned
  belongs_to :project
end
