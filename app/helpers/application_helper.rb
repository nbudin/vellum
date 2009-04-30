# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_link_to(label, destination)
    link_to label, destination, {:class => request.path =~ /^#{destination}/ ? "selected" : "" }
  end
  
  def page_title
    noun = nil
    if params[:id]
      klass = eval(controller.controller_name.classify.singularize)
      if klass.kind_of? Class and klass.respond_to? 'find'
        obj = klass.find(params[:id])
        if obj.respond_to? 'name'
          noun = obj.name
        end
      end
    end
    
    if noun.nil?
      # fallback - we couldn't get the current object's name
      noun = controller.controller_name.humanize
      unless controller.action_name == 'index'
        noun = noun.singularize
      end
    end

    if controller.action_name == 'edit'
      verbnoun = "Editing #{noun}"
    elsif controller.action_name == 'new'
      verbnoun = "New #{noun}"
    else
      verbnoun = noun
    end

    if params[:project_id]
      proj = Project.find(params[:project_id])
      return "#{verbnoun} - #{proj.name}"
    elsif params[:template_schema_id]
      ts = TemplateSchema.find(params[:template_schema_id])
      return "#{verbnoun} - #{ts.name}"
    else
      return verbnoun
    end
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

  def item_actions(item, options={})
    html = ""
    if options[:delete_path]
      html << button_to("Delete", options[:delete_path] + "/#{item.id}", :confirm => "Are you sure?",
                        :method => :delete, :class => "delete")
    end
    return html
  end

  def itemlist_items(items, options={}, &block)
    full_html = items.collect do |item|
      content_tag(:li, :class => cycle("odd", "even")) do
        html = ""
        html << content_tag(:div, :style => "float: right;") do
          item_actions(item, options)
        end
        if options[:partial]
          html << render(:partial => options[:partial], :locals => { :item => item })
        end
        if block_given?
          html << block.call(item)
        end
        html
      end
    end.join("\n")
    if block_given?
      concat(full_html)
    else
      full_html
    end
  end

  def itemlist(items, options={}, &block)
    html = content_tag(:ul, {:class => "itemlist"}.update(options)) do
      itemlist_items(items, options, &block)
    end
    if block_given?
      concat html
    else
      html
    end
  end
end
