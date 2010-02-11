module DocsHelper
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
