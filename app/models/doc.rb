require 'rexml/parsers/sax2parser'

class Doc < ActiveRecord::Base
  has_many :versions, class_name: "Doc::Version"

  before_save :check_for_new_version
  def check_for_new_version
    instantiate_revision if create_new_version?
    true # Never halt save
  end

  def versioned_columns
    @versioned_columns ||= begin
      version = versions.new
      version.attributes.keys - [version.class.primary_key, 'doc_id', 'author_id', 'version', 'created_at', 'updated_at']
    end
  end
  
  def latest_version
    versions.order(version: :desc).first
  end
  
  validate :check_attrs_error
  
  before_save :sanitize_content
  after_save :email_new_assignee, if: :assignee_id_changed?

  belongs_to :project, touch: true
  belongs_to :doc_template
  belongs_to :creator, :class_name => "Person"
  belongs_to :assignee, :class_name => "Person"

  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship", :dependent => :destroy
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship", :dependent => :destroy
  acts_as_list :scope => :doc_template_id

  before_create :set_version_creators
  after_save :save_versions

  def attrs
    @attrs || reload_working_attrs
  end

  def reload_working_attrs(version=nil)
    version ||= latest_version
    @attrs = Doc::AttrSet.new(self, version)
  end

  def create_new_version?
    versioned_columns.detect {|a| __send__ "#{a}_changed?"} || attrs.changed?
  end

  def instantiate_revision
    new_version = versions.build(attributes.slice(*versioned_columns))
    version_number = new_record? ? 1 : version + 1
    new_version.version = version_number
    self.version = version_number

    attrs.save_to_doc_version(new_version)
    reload_working_attrs(new_version)
  end
  
  def find_version(num)
    versions.find_by(version: num)
  end

  def to_param
    if name
      "#{id}-#{name.parameterize}"
    else
      id.to_s
    end
  end

  def attrs_attributes
    attrs.nested_attributes
  end

  def attrs_attributes=(nested_attributes)
    begin
      attrs.nested_attributes = nested_attributes
    rescue Doc::AttrSet::EditException => e
      @attrs_error = e
    end
  end

  def relationships
    outward_relationships + inward_relationships
  end

  def related_docs(relationship_type, direction = :both)
    if relationship_type.is_a? String
      conds = case direction.to_sym
      when :inward
        ["right_description = ?", relationship_type]
      when :outward
        ["left_description = ?", relationship_type]
      else
        return (related_docs(relationship_type, :outward) + related_docs(relationship_type, :inward)).uniq
      end
      
      return project.relationship_types.where(conds).collect do |rt|
        related_docs(rt, direction)
      end.flatten
    end

    relationships = case direction.to_sym
    when :inward
      inward_relationships
    when :outward
      outward_relationships
    end.select { |r| r.relationship_type == relationship_type }

    case direction.to_sym
    when :inward
      relationships.collect { |r| r.left }
    when :outward
      relationships.collect { |r| r.right }
    end
  end

  private
  def set_version_creators
    versions.each do |v|
      v.author = self.creator
    end
  end

  def save_versions
    versions.each do |v|
      v.save(:validate => false)
    end
  end
  
  def check_attrs_error
    if @attrs_error
      @attrs_error.errors.each do |attr_error|
        errors.add(:base, attr_error)
      end
    end
  end
  
  def sanitize_content
    return if content.blank?
    self.content = Sanitize.clean(content, Sanitize::Config::VELLUM)
  end
  
  def email_new_assignee
    return unless assignee
    AssignmentMailer.assigned_to_you(self, assignee).deliver_later
  end
end
