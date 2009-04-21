# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_link_to(label, destination)
    link_to label, destination, {:class => request.path =~ /^#{destination}/ ? "selected" : "" }
  end
  
  def page_title
    ret = if controller.action_name == 'index'
      "List"
    else
      controller.action_name.capitalize
    end
    ret += " "
    if controller.action_name != 'index'
      ret += controller.controller_name.humanize.singularize.downcase
    else
      ret += controller.controller_name.humanize.downcase
    end
    return ret
  end

  def show_class_template_name(klass)
    "field_types/#{klass.name.tableize.singularize}"
  end
  
  def edit_class_template_name(klass)
    "field_types/edit_#{klass.name.tableize.singularize}"
  end

  def show_attr_template_name(attr)
    show_attr_template_name(attr.attr_configuration.class)
  end

  def edit_attr_template_name(attr)
    edit_class_template_name(attr.attr_configuration.class)
  end

  def show_attr_value_template_name(value)
    show_class_template_name(value.class)
  end

  def edit_attr_value_template_name(value)
    edit_class_template_name(value.class)
  end

  def render_attr(attr)
    render :partial => show_attr_value_template_name(attr), :locals => { :field => attr.attr_configuration }
  end

  def render_attr_editor(attr)
    render :partial => edit_attr_template_name(attr), :locals => { :field => attr.attr_configuration }
  end

  def render_attr_value(value)
    render :partial => show_attr_value_template_name(value), :locals => { :value => value }
  end

  def render_attr_value_editor(value)
    render :partial => edit_attr_value_template_name(value), :locals => { :value => value }
  end
end
