class DocTemplateAttr < ActiveRecord::Base
  belongs_to :doc_template

  acts_as_list :scope => :doc_template
  validates_uniqueness_of :name, :scope => :doc_template_id

  include ChoiceContainer
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
