require 'format_conversions'

class Attr < ActiveRecord::Base
  module Base
    extend ActiveSupport::Concern
    
    included do
      validates_format_of :name, :with => /\A[A-Za-z0-9 \-]*\z/,
        :message => "can only contain letters, numbers, spaces, and hyphens"

      validates_presence_of :name
    end    
  end

  module WithSlug
    extend ActiveSupport::Concern
    
    included do
      validates_format_of :slug, :with => /\A[a-z0-9\-\_]*\z/,
        :message => "can only contain lowercase letters, numbers, underscores, and hyphens"

      validates_presence_of :slug
    end
    
    def self.slug_for(name)
      name && name.downcase.gsub(/ /, "_")
    end
    
    def name=(new_name)
      write_attribute(:name, new_name)
      write_attribute(:slug, Attr::WithSlug.slug_for(new_name))
    end

    def slug=(new_slug)
      raise "You cannot directly set the slug of this object.  Set the name instead."
    end
  end

  belongs_to :doc_version, :class_name => "Doc::Version"
  acts_as_list :scope => :doc_version

  validates_uniqueness_of :slug, :scope => :doc_version_id, :case_sensitive => false

  include ChoiceContainer
  include Attr::Base
  include Attr::WithSlug
  attr_accessor :doc
  
  after_initialize do |attr|
    attr[:position] ||= attr.template_attr.try(:position)
  end
  
  def shim_for_attr_set(doc)
    shim = Attr.new(:doc => doc)
    %w{name position}.each do |field|
      shim.send("#{field}=", self.read_attribute(field))
    end
    shim.value_unsafe = value
    
    shim
  end

  def value(format=:html)
    FormatConversions.convert(read_attribute(:value), format)
  end
  
  def multiple_value
    value
  end
  
  def multiple_value=(value)
    keys = value.keys.sort
    selected_keys = keys.select { |key| 
      ActiveRecord::Type::Boolean.new.type_cast_from_database(value[key]['selected'])
    }
    
    write_attribute(:value, selected_keys.collect { |key| value[key]['choice'] }.join(", "))
  end

  def value=(value)
    write_attribute(:value, Sanitize.clean(value.to_s, Sanitize::Config::VELLUM))
  end
  
  def raw_value
    read_attribute(:value)
  end
  
  def value_unsafe=(value)
    write_attribute(:value, value)
  end

  def template_attr
    if doc && doc.doc_template
      doc.doc_template.doc_template_attrs.select { |dta| dta.name == self.name }.first
    end
  end

  def from_template?
    template_attr
  end

  def ui_type
    template_attr.try(:ui_type) || "text"
  end

  def choices
    template_attr.try(:choices) || []
  end

  def reload_doc
    @doc = doc_version.try(:doc)
  end
end