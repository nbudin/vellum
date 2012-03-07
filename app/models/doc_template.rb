class DocTemplate
  include Mongoid::Document
  
  field :name, type: String
  belongs_to :project
  index :project

  embeds_many :doc_template_attrs, :order => "position", :dependent => :destroy, :autosave => true  
  has_many :outward_relationship_types, :inverse_of => :left_template, :class_name => "RelationshipType", :dependent => :destroy
  has_many :inward_relationship_types, :inverse_of => :right_template, :class_name => "RelationshipType", :dependent => :destroy
  has_many :docs, :dependent => :destroy, :order => "name"

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
