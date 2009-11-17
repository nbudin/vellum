class Doc < ActiveRecord::Base
  acts_as_versioned

  has_one :doc_value
  validates_presence_of :doc_value
  belongs_to :author, :class_name => "Person"
  
  belongs_to :project
  before_validation :set_project
  validates_presence_of :project
  non_versioned_columns << "project_id"
  
  private
  def set_project
    if doc_value and doc_value.structure.project != project
      self.project = doc_value.structure.project
    end
  end
end
