module StructuresHelper
  def edit_attr_row(structure, a)
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
        av.id = a.id
        av
      else
        structure.obtain_attr_value(a.name)
      end
      
      html << content_tag(:td, render_attr_value_editor(av))
    end
  end
end
