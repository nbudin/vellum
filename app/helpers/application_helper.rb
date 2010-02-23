# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def jipe_editor_if_permitted(object, attr, options={})
    options[:editing] = logged_in? && logged_in_person.permitted?(object, "edit")
    jipe_editor(object, attr, options)
  end
  
  def nav_link_to(label, destination, image_path=nil, selected=nil)
    if selected.nil?
      selected = request.path =~ /^#{destination}/
    end
    
    label_html = if image_path
                   "#{image_tag(image_path, :alt => label)} #{h label}"
                 else
                   h(label)
                 end
    link_to(label_html, destination, {:class => selected ? "selected" : "" })
  end
  
  def page_title
    noun = nil
    if params[:id]
      obj = nil
      var_name = "@#{controller.controller_name.tableize.singularize}"
      if instance_variable_defined?(var_name)
        obj = instance_variable_get var_name
      else
        begin
          klass = eval(controller.controller_name.classify.singularize)
        rescue
        end
        
        if klass.kind_of? Class and klass.respond_to? 'find'
          obj = klass.find(params[:id])
        end
      end
      if obj and obj.respond_to? 'name'
        noun = obj.name
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
      proj = if instance_variable_defined?(:@project)
               @project
             else
               Project.find(params[:project_id])
             end
      return "#{verbnoun} - #{proj.name}"
    elsif params[:template_schema_id]
      ts = if instance_variable_defined?(:@template_schema)
             @template_schema
           else
             TemplateSchema.find(params[:template_schema_id])
           end
      return "#{verbnoun} - #{ts.name}"
    else
      return verbnoun
    end
  end

  def render_attr(attr)
    render :partial => show_attr_value_template_name(attr), :locals => { :field => attr.attr_configuration }
  end

  def render_attr_value(attr)
    case (attr.ui_type.try(:to_sym))
    when :textarea
      content_tag(:div, sanitize(attr.value), :class => "document_content")
    else
      attr.value
    end
  end

  def item_actions(item, options={})
    html = ""
    if options[:delete_path]
      if (not item.respond_to? "permitted?") or (logged_in? and logged_in_person.permitted?(item, "destroy"))
        html << link_to("Delete", options[:delete_path] + "/#{item.id}", :confirm => "Are you sure?",
                        :method => :delete, :class => "button delete")
      end
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

  def sortlist_items(items, list_id, options={}, &block)
    full_html = items.collect do |item|
      content_tag(:li, :id => "#{list_id.singularize}_#{item.id}") do
        inner_html = image_tag("sort_handle.png", :class => "sort_handle")
        if block_given?
          inner_html << block.call(item)
        end
        inner_html
      end
    end.join("\n")
    
    if block_given?
      concat full_html
    else
      full_html
    end
  end

  def sortlist_sortable(list_id, url)
    sortable_element(list_id, :handle => "sort_handle", :url => url)
  end

  def sortlist(items, list_id, options={}, &block)
    url = options.delete(:url)
    html = content_tag(:ul, {:class => "sortlist", :id => list_id}.update(options)) do
      sortlist_items(items, list_id, options, &block)
    end
    html << sortlist_sortable(list_id, url)
    if block_given?
      concat html
    else
      html
    end
  end

  def complex_item(options={}, &block)
    item_id = options.delete(:id) || "complex_item"
    delete_path = options.delete(:delete_path)
    md_type = options.delete(:type)
    md_name = options.delete(:name)
    html = content_tag(:div, {:class => "complex_item", :id => item_id}.update(options)) do
      item_html = content_tag(:div, {:class => "metadata"}) do
        metadata_html = ""
        if md_type
          metadata_html << content_tag(:div, md_type, :class => "type")
        end
        if md_name
          metadata_html << content_tag(:div, md_name, :class => "name")
        end
        metadata_html << content_tag(:div, :class => "showhide") do
          (link_to_function("Show details", update_page do |p|
                              p["#{item_id}_details"].show
                              p["hide_#{item_id}_details"].show
                              p["show_#{item_id}_details"].hide
                            end,
                            :id => "show_#{item_id}_details") +
           link_to_function("Hide details", update_page do |p|
                              p["#{item_id}_details"].hide
                              p["show_#{item_id}_details"].hide
                              p["hide_#{item_id}_details"].show
                            end,
                            :id => "hide_#{item_id}_details", :style => "display: none;"))
        end
      end
      item_html << content_tag(:div, "", {:class => "clear"})
      item_html << content_tag(:div, { :id => "#{item_id}_details", :style => "display: none;" }) do
        details_html = ""
        if block_given?
          details_html << block.call
        end
        if delete_path
          details_html << content_tag(:ul, :class => "actions") do
            actions_html = ""
            if delete_path
              actions_html << content_tag(:li) do
                link_to("Delete", delete_path, :confirm => "Are you sure?", :method => :delete, :class => "button delete")
              end
            end
          end
        end
      end
    end
    if block_given?
      concat html
    else
      html
    end
  end
  
  def color_picker(f, field_name, options={})
    html = f.hidden_field "color"
    html << content_tag("button", "", :class => "color_swatch", :type => "button",
                        :id => "#{f.object_name}_color_swatch")
    html << javascript_tag(<<EOJS
      new Control.ColorPicker("#{f.object_name}_color",
                                      {
                                        "swatch": "#{f.object_name}_color_swatch",
                                        "IMAGE_BASE": "#{ url_for "/images/colorPicker/" }"
                                      });
EOJS
)
  end
end
