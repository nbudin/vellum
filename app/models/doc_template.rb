class DocTemplate < ActiveRecord::Base
  belongs_to :project

  has_many :doc_template_attrs, :order => "position", :dependent => :destroy, :autosave => true
  has_many :outward_relationship_types, :foreign_key => :left_template_id, :class_name => "RelationshipType", :dependent => :destroy
  has_many :inward_relationship_types, :foreign_key => :right_template_id, :class_name => "RelationshipType", :dependent => :destroy
  has_many :docs, :dependent => :destroy, :order => "name"
  has_many :mapped_doc_templates, dependent: :destroy

  accepts_nested_attributes_for :doc_template_attrs, :allow_destroy => true
  validates_presence_of :name

  def plural_name
    # later we may want to add the possibility to override this
    name.pluralize
  end

  def relationship_types
    outward_relationship_types + inward_relationship_types
  end
end
