module DocsHelper
  def render_attr_value_editor(attr, f)
    case attr.ui_type.try(:to_sym)
    when :textarea
      f.text_area attr.name_for_id, :class => "mceEditor"
    when :radio
      content_tag(:ul, :style => "list-style-type: none;") do
        attr.choices.collect do |choice|
          f.radio_button(attr.name_for_id, choice) +
          f.label(attr.name_for_id, choice, :value => choice)
        end.join("\n")
      end
    when :dropdown
      f.select attr.name_for_id, attr.choices
    when :multiple
      f.fields_for attr.name_for_id do |attr_fields|
        content_tag(:ul, :style => "list-style-type: none;") do
          attr.choices.collect do |choice|
            attr_fields.check_box(choice) +
            attr_fields.label(choice, choice)
          end
        end
      end
    else
      f.text_field attr.name_for_id
    end
  end

  def edit_attr_row(doc, name, f)
    a = doc.attrs[name]

    content_tag(:dt, a.name) +
    content_tag(:dd, render_attr_value_editor(a, f))
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
