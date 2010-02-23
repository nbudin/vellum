module DocsHelper
  def render_attr_value_editor(attr, f)
    case attr.ui_type.try(:to_sym)
    when :textarea
      f.text_area attr.name, :class => "mceEditor"
    when :radio
      content_tag(:ul, :style => "list-style-type: none;") do
        attr.choices.collect do |choice|
          f.radio_button(attr.name, choice) +
          f.label(attr.name, choice, :value => choice)
        end.join("\n")
      end
    when :dropdown
      f.select attr.name, attr.choices
    when :multiple
      f.select attr.name, attr.choices, :multiple => true
    else
      f.text_field attr.name
    end
  end

  def edit_attr_row(structure, name, f)
    content_tag(:tr, :class => "attribute") do
      html = ""

      a = structure.attrs[name]
      
      name_class = "attribute_name"
      html << content_tag(:td, f.label(a.name, a.name, :class => name_class))
      html << content_tag(:td, render_attr_value_editor(a, f))
    end
  end
  
  def attr_row(attr)
    content_tag(:tr) do
      html = ""
      html << content_tag(:td, :style => "vertical-align: top; font-weight: bold;") do
        h(attr.name)
      end
      html << content_tag(:td, render_attr_value(attr))
    end
  end
end
