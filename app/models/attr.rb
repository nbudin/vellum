class Attr < ActiveRecord::Base
  module Base
    def self.included(klass)
      klass.class_eval do
        validates_format_of :name, :with => /^[A-Za-z0-9 \-]*$/,
          :message => "can only contain letters, numbers, spaces, and hypens"

        validates_presence_of :name
      end
    end    
  end

  module WithSlug
    def self.included(klass)
      klass.class_eval do
        validates_format_of :slug, :with => /^[a-z0-9\-\_]*$/,
          :message => "can only contain lowercase letters, numbers, underscores, and hyphens"

        validates_presence_of :slug
      end
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
  
  def shim_for_attr_set(doc)
    shim = Attr.new(:doc => doc)
    %w{name slug value position format}.each do |field|
      shim.write_attribute(field, self.read_attribute(field))
    end
    
    shim
  end

  def value(format='html')
    raw_content = read_attribute(:value)
    raw_format = self.format && self.format.to_sym

    case (format && format.to_sym)
    when :fo
      case raw_format
      when :html
        FormatConversions.html_to_fo(raw_content)
      else
        raw_content
      end
    else
      raw_content
    end
  end

  def value=(value)
    write_attribute(:value, case value
    when Hash
      selected_choices = value.values.select { |choice| 
        ActiveRecord::ConnectionAdapters::Column.value_to_boolean(choice['selected'])
      }
      selected_choices.collect { |choice| choice['choice'] }.join(", ")
    else
      Sanitize.clean(value.to_s, Sanitize::Config::VELLUM)
    end)
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

  def position
    template_attr.try(:position) || read_attribute(:position)
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