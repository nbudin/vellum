class DocTemplateAttr
  include Mongoid::Document
  
  belongs_to :doc_template
  
  field :name, type: String
  field :position, type: Integer
  field :ui_type, type: Symbol
  field :choices, type: Array

  validates_uniqueness_of :name, :scope => :doc_template

  include Attr::Base

  def self.ui_types
    %w{text textarea radio dropdown multiple}
  end

  def self.ui_type_name(ui_type)
    case ui_type.to_sym
    when :text
      "Simple text input"
    when :textarea
      "Rich text input"
    when :radio
      "Radio buttons"
    when :dropdown
      "Drop-down list"
    when :multiple
      "Multiple selection list"
    end
  end

  def self.ui_types_for_select
    ui_types.collect { |t| [ui_type_name(t), t] }
  end

  def ui_type_name
    self.class.ui_type_name(ui_type)
  end

  def multiple_choice?
    case ui_type.to_sym
    when :radio, :dropdown, :multiple
      true
    else
      false
    end
  end
end
