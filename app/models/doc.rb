require 'rexml/parsers/sax2parser'

class AttrSetEditException < Exception
  attr_reader :errors
  
  def initialize(errors)
    @errors = errors
  end
end

class Doc < ActiveRecord::Base
  version_fu :foreign_key => "doc_id" do
    belongs_to :author, :class_name => "::Person"
    has_many :attrs, :class_name => "::Attr",
      :foreign_key => "doc_version_id", :autosave => true
  end
  
  validate :check_attrs_error
  
  before_save do |doc|
    unless doc.content.blank?
      doc.content = Sanitize.clean(doc.content, Sanitize::Config::VELLUM)
    end
  end

  if self.versioned_columns
    self.versioned_columns -= %w{ author_id }
  end

  class AttrSet < Array
    def initialize(doc, doc_version = nil)
      @deleted_attrs = []
      @doc = doc
      @attrs_by_slug = {}
      
      unless doc_version.nil?
        doc_version.attrs.each do |attr|
          # We create a clone of the attr with the version ref removed
          # but the @doc variable remaining set

          self.push(attr.shim_for_attr_set(@doc), true)
        end
      end
      update_slug_hash!

      # ensure we have all template attributes
      unless @doc.doc_template.nil?
        @doc.doc_template.doc_template_attrs.each do |dta|
          slug = Attr::WithSlug.slug_for(dta.name)
          unless @attrs_by_slug.has_key?(slug)
            new_attr = Attr.new(:name => dta.name, :doc => @doc)
            self.push(new_attr, true)
          end
        end
      end
      
      after_change
    end

    def [](index_or_slug)
      case index_or_slug
      when Fixnum
        super(index_or_slug)
      else
        existing = find_by_index_or_slug(index_or_slug)

        if existing.nil?
          new_attr = Attr.new(:name => index_or_slug, :doc => @doc)
          self << new_attr
          return new_attr
        else
          return existing
        end
      end
    end

    def <<(attr)
      super(attr)
      after_change
    end

    def push(attr, skip_update = false)
      super(attr)
      after_change unless skip_update
    end

    def insert(index, attr)
      super(index, attr)
      after_change
    end

    def after_change
      update_slug_hash!
      resort!
    end

    def update_slug_hash!
      @attrs_by_slug = self.inject({}) do |memo, attr|
        memo[attr.slug] = attr
        memo
      end      
    end

    def resort!
      self.sort! do |a, b|
        if a.from_template? && !b.from_template?
          -1
        elsif !a.from_template? && b.from_template?
          1
        elsif a.position && b.position
          a.position <=> b.position
        elsif a.position
          -1
        elsif b.position
          1
        else
          a.name <=> b.name
        end
      end
    end

    def find_by_index_or_slug(index_or_slug)
      case index_or_slug
      when Fixnum
        self[index_or_slug]
      else
        slug = Attr::WithSlug.slug_for(index_or_slug)
        @attrs_by_slug[slug] #||= self.select { |attr| attr.slug == slug }.first
      end
    end

    def delete(index_or_slug)
      attr = find_by_index_or_slug(index_or_slug)
      return unless attr

      super(attr)
      @attrs_by_slug.delete(attr.slug)
      @deleted_attrs << attr
      resort!
      return attr
    end

    def save_to_doc_version(doc_version)
      doc_version.attrs = self.collect { |attr| attr.clone }

      doc_version.attrs.each do |attr|
        attr.doc_version = doc_version
      end
    end

    def changed?
      @deleted_attrs.size > 0 or self.any? do |attr|
        attr_changes = attr.changes.keys
        attr_changes -= ["doc_version_id"]
        attr_changes.size > 0
      end
    end

    def nested_attributes
      self.inject([]) do |memo, attr|
        memo << { 'name' => attr.name, 'value' => attr.value }
        memo
      end
    end

    def nested_attributes=(nested_attributes = [])
      errors = []
      
      nested_attributes_array = case nested_attributes
      when Array
        nested_attributes
      when Hash
        nested_attributes.keys.sort.inject([]) do |memo, key|
          memo << nested_attributes[key]
        end
      else
        raise "Nested attributes must be an array or hash"
      end
      
      nested_attributes_array.reject! { |item| item['name'].blank? && item['value'].blank? }
      
      #first pass: eliminate dupes
      seen = Set.new
      dupes = Set.new
      nested_attributes_array.each do |item|
        name = item['name']
        next unless name
        
        if seen.include?(name)
          errors << "Duplicate attribute name '#{name}'"
        else
          seen << name
        end
      end
      
      #second pass: do the edit
      nested_attributes_array.each do |item|
        name = item['name']
        if name.nil?
          errors << "Item #{item.inspect} has no specified name"
          next
        end
        
        next if dupes.include?(name)
        
        if ActiveRecord::ConnectionAdapters::Column.value_to_boolean(item['_destroy']) ||
            ActiveRecord::ConnectionAdapters::Column.value_to_boolean(item['_delete'])
          self.delete(name)
        else
          self[name].value = item['value']
        end
      end
      
      if errors.size > 0
        raise AttrSetEditException.new(errors)
      end
      
      self.nested_attributes
    end
  end

  belongs_to :project
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
    version ||= versions.latest
    @attrs = AttrSet.new(self, version)
  end

  def create_new_version?
    super || attrs.changed?
  end

  def instatiate_revision
    super

    new_version = versions.select { |v| v.new_record? }.last
    attrs.save_to_doc_version(new_version)
    reload_working_attrs(new_version)
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
    rescue AttrSetEditException => e
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
end
