require 'rexml/parsers/sax2parser'

class Doc < ActiveRecord::Base
  version_fu :foreign_key => "doc_id" do
    belongs_to :author, :class_name => "::Person"
    has_many :attrs, :class_name => "::Attr",
      :foreign_key => "doc_version_id", :autosave => true
  end

  self.versioned_columns -= %w{ author_id }

  class AttrSet
    def initialize(doc_version = nil)
      @attrs = {}
      @deleted_attrs = []

      unless doc_version.nil?
        doc_version.attrs.each do |attr|
          working_attr = attr.clone
          working_attr.doc_version_id = nil
          working_attr.doc_version = nil
          @attrs[attr.name] = working_attr
        end
      end
    end

    def [](name)
      @attrs[name] ||= Attr.new(:name => name)
    end

    def delete(name)
      deleted_attr = @attrs.delete(name)
      @deleted_attrs << deleted_attr
      return deleted_attr
    end

    def save_to_doc_version(doc_version)
      doc_version.attrs = @attrs.values

      doc_version.attrs.each do |attr|
        attr.doc_version = doc_version
      end
    end

    def changed?
      @deleted_attrs.size > 0 or @attrs.values.any? do |attr|
        attr_changes = attr.changes.keys
        attr_changes -= ["doc_version_id"]
        attr_changes.size > 0
      end
    end

    def values
      @attrs.inject({}) do |memo, (name, attr)|
        memo[attr.name] = attr.value
        memo
      end
    end

    def values=(new_values = {})
      new_values.each do |name, value|
        @attrs[name].value = value
      end
      
      values
    end
  end

  belongs_to :project
  belongs_to :doc_template
  belongs_to :creator, :class_name => "Person"
  belongs_to :assignee, :class_name => "Person"

  has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship", :dependent => :destroy
  has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship", :dependent => :destroy

  def attrs
    @attrs || reload_working_attrs
  end

  def reload_working_attrs
    @attrs = AttrSet.new(versions.latest)
  end

  def create_new_version?
    super || attrs.changed?
  end

  def instatiate_revision
    super

    new_version = versions.select { |v| v.new_record? }.last
    attrs.save_to_doc_version(new_version)
    reload_working_attrs
  end

  def to_param
    if name
      "#{id}-#{name.parameterize}"
    else
      id.to_s
    end
  end

  def attr_values
    attrs.values
  end

  def attr_values=(values)
    attrs.values = values
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
      
      return project.relationship_types.all(:conditions => conds).collect do |rt|
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
end
