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

  def value(format='html')
    raw_content = read_attribute(:value)
    raw_format = self.format && self.format.to_sym

    case (format && format.to_sym)
    when :fo
      case raw_format
      when :html
        html_to_fo(raw_content)
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
      value
    end)
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

  private
  def html_to_fo(html)
    xml = ""
    parser = REXML::Parsers::SAX2Parser.new(html)
    parser.listen(:characters) {|text| xml << text }

    parser.listen(:start_element, %w{ p }) do
      xml << "<block space-after.optimum=\"8pt\" widows=\"4\" orphans=\"4\">"
    end
    parser.listen(:end_element, %w{ p }) do
      xml << "</block>"
    end

    parser.listen(:start_element, %w{ ul }) do
      xml << "<list-block start-indent=\"from-parent(start-indent) + 0.5em\" "
      xml << "provisional-distance-between-starts=\"1em\" "
      xml << "provisional-label-separation=\"0.5em\" space-after.optimum=\"1em\">"
    end
    parser.listen(:end_element, %w{ ul }) do
      xml << "</list-block>"
    end

    parser.listen(:start_element, %w{ li }) do
      xml << "<list-item>"
      xml << "  <list-item-label end-indent=\"label-end()\">"
      xml << "    <block>&#x2022;</block>"
      xml << "  </list-item-label>"
      xml << "  <list-item-body start-indent=\"body-start()\">"
      xml << "    <block>"
    end
    parser.listen(:end_element, %w{ li }) do
      xml << "    </block>"
      xml << "  </list-item-body>"
      xml << "</list-item>"
    end

    parser.parse

    return xml
  end
end