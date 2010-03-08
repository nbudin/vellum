module DocsHelper
  def render_attr_value_editor(attr_fields)
    attr = attr_fields.object

    case attr.ui_type.try(:to_sym)
    when :textarea
      attr_fields.text_area :value, :class => "mceEditor"
    when :radio
      content_tag(:ul, :style => "list-style-type: none;") do
        attr.choices.collect do |choice|
          attr_fields.radio_button(:value, choice) +
          attr_fields.label(:value, choice, :value => choice)
        end.join("\n")
      end
    when :dropdown
      attr_fields.select :value, attr.choices
    when :multiple
      attr_fields.fields_for :value do |value_fields|
        content_tag(:ul, :style => "list-style-type: none;") do
          i = -1
          attr.choices.collect do |choice|
            i += 1
            value_fields.fields_for i.to_s do |choice_fields|
              choice_fields.hidden_field(:choice, :value => choice) +
              choice_fields.check_box(:selected, :checked => attr_fields.object.value.try(:include?, choice)) +
              choice_fields.label(:selected, choice)
            end
          end
        end
      end
    else
      attr_fields.text_field :value
    end
  end

  def edit_attr_row(attr_fields)
    attr = attr_fields.object
    
    attr_fields.hidden_field(:name) +
    content_tag(:dt, attr_fields.label(:value, attr.name)) +
    content_tag(:dd, render_attr_value_editor(attr_fields))
  end

  def render_attr_value(attr)
    case (attr.ui_type.try(:to_sym))
    when :textarea
      content_tag(:div, sanitize(attr.value), :class => "document_content")
    else
      attr.value
    end
  end
  
  def attr_row(attr)
    content_tag(:dt, attr.name) +
    content_tag(:dd, render_attr_value(attr))
  end
end
