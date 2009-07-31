module StructuresHelper
  def edit_attr_row(structure, a, param_prefix_components=[])
    content_tag(:tr, :class => "attribute") do
      html = ""
      
      name_class = "attribute_name"
      if a.required
        name_class << " required"
      end
      html << content_tag(:td, h(a.name), :class => name_class)

      av = if structure.new_record?
        # construct shim value
        avm = structure.attr_value_metadatas.new(:attr => a, :structure => structure)
        av = a.attr_configuration.class.value_class.new(:attr_value_metadata => avm)
        av
      else
        structure.obtain_attr_value(a)
      end
      
      html << content_tag(:td, render_attr_value_editor(av, param_prefix_components))
    end
  end
  
  def attr_row(structure, attr)
    av = structure.obtain_attr_value(attr)
    if av
      content_tag(:tr) do
        html = ""
        html << content_tag(:td, :style => "vertical-align: top; font-weight: bold;") do
          h(attr.name)            
        end
        html << content_tag(:td, render_attr_value(av))
      end
    end
  end
end
