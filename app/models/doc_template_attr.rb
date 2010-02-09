class DocTemplateAttr < ActiveRecord::Base
  belongs_to :doc_template

  acts_as_list :scope => :doc_template
  validates_uniqueness_of :name, :scope => :doc_template_id

  include ChoiceContainer
end
