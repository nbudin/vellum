# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PageTitleHelper
  
  def in_place_editor(object, attr, options = {})
    tag = options.delete(:tag) || "p"
    rows = options.delete(:rows)
    url = options.delete(:url) || polymorphic_url(object, :format => 'json')
    
    editor_attrs = {
      'data-in-place-edit-url' => url,
      'data-in-place-edit-object' => object.class.name.underscore,
      'data-in-place-edit-field' => attr,
      'class' => 'vellumInPlaceEdit'
    }
    editor_attrs['data-in-place-edit-rows'] = rows unless rows.nil?
    
    content_tag(tag, options) do
      content_tag(:span, editor_attrs) do
        object.send(attr).try(:html_safe)
      end + " " + image_tag('edit-field.png')
    end
  end
  
  def wysihtml5_editor(f, field, text_area_options={})
    render :partial => "shared/wysihtml5_editor", :locals => { :f => f, :field => field, :text_area_options => text_area_options }
  end
  
  def indefinite_article_for(string)
    if string =~ /^\s*[aeiou]/i
      "an"
    else
      "a"
    end
  end
  
  def a_template_name(template)
    "#{indefinite_article_for(template.name)} #{template.name}"
  end
  
  def nav_link_to(label, destination, image_path=nil, selected=nil)
    if selected.nil?
      selected = request.path =~ /^#{destination}/
    end

    content_tag(:li, {:class => selected ? 'active' : ''}) do
      link_to(destination) do
        output_buffer << image_tag(image_path, :alt => label) if image_path
        output_buffer << label
      end
    end
  end

  def render_attr(attr)
    render :partial => show_attr_value_template_name(attr), :locals => { :field => attr.attr_configuration }
  end

  def item_actions(item, options={})
    if options[:delete_path] && can?(:destroy, item)
      button_to("Delete", options[:delete_path] + "/#{item.id}", "data-confirm" => "Are you sure?",:style => "margin: 0;", :method => :delete, :class => "btn btn-danger btn-xs")
    end
  end

  def itemlist_items(items, options={}, &block)
    with_output_buffer do
      items.each do |item|
        if options[:partial]
          output_buffer << render(:partial => options[:partial], :locals => { :item => item })
        end
        if block_given?
          block.call(item)
        end
      end
      output_buffer << "\n"
    end
  end

  def itemlist(items, options={}, &block)
    content_tag(:ul, {:class => "itemlist"}.update(options)) do
      itemlist_items(items, options, &block)
    end
  end

  def sortlist_items(items, list_id, options={}, &block)
    with_output_buffer do
      items.each do |item|
        output_buffer << content_tag(:li, :class => "list-group-item", :id => "#{list_id.singularize}_#{item.id}") do
          output_buffer << content_tag(:span, "", :class => "glyphicon glyphicon-sort sort_handle")
          block.call(item) if block_given?
        end
        output_buffer << "\n"
      end
    end
  end

  def sortlist(items, list_id, options={}, &block)
    ul_attrs = {
      :class => "sortlist list-group",
      :id => list_id,
      :"data-url" => options.delete(:url)
    }.merge(options)
    
    content_tag(:ul, ul_attrs) do
      sortlist_items(items, list_id, options, &block)
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
                link_to("Delete", delete_path, "data-confirm" => "Are you sure?", :method => :delete, :class => "button delete")
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
    html = f.hidden_field(field_name)
    placeholder_id = "#{f.object_name}_#{field_name}_swatch"
    html << content_tag("div", :class => "vellumColorPicker",
                        "data-colorpicker-field" => "#{f.object_name}[#{field_name}]") do
      content_tag("div", "", :class => "vellumColorPickerPlaceholder")
    end
  end
  
  def error_messages_for(target)
    if target.errors.any?
      content_tag(:div, :class => "error_messages") do
        content_tag(:ul) do
          with_output_buffer do
            target.errors.full_messages.each do |msg|
              output_buffer << content_tag(:li, msg)
            end
          end
        end
      end
    end
  end
end
