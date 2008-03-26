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
end
