module DocsHelper
  def render_attr_value_editor(attr_fields)
    attr = attr_fields.object

    html = ""
    unless attr.from_template?
      html << content_tag(:span, :style => "float: right; color: red; font-weight: bold; margin-right: 10px;") do
        attr_fields.label(:_destroy, "Remove") +
        attr_fields.check_box(:_destroy, :class => "delete")
      end
    end

    html << content_tag(:span, :class => "vellumEditExpander",
      :"data-edit-expander-preview" => truncate(strip_tags(attr.value), :length => 100)) do
      case attr.ui_type.try(:to_sym)
      when :textarea
        attr_fields.text_area :value, :class => "wymeditor"
      when :radio
        content_tag(:ul, :style => "list-style-type: none;") do
          attr.choices.collect do |choice|
            attr_fields.radio_button(:value, choice) +
            attr_fields.label(:value, choice, :value => choice)
          end.join("\n")
        end
      when :dropdown
        attr_fields.select :value, attr.choices
      when :multiple
        attr_fields.fields_for :value do |value_fields|
          content_tag(:ul, :style => "list-style-type: none;") do
            i = -1
            attr.choices.collect do |choice|
              i += 1
              value_fields.fields_for i.to_s do |choice_fields|
                choice_fields.hidden_field(:choice, :value => choice) +
                choice_fields.check_box(:selected, :checked => attr_fields.object.value.try(:include?, choice)) +
                choice_fields.label(:selected, choice)
              end
            end
          end
        end
      else
        attr_fields.text_field :value
      end
    end
    
    return html
  end

  def attr_class(attr)
    if attr.from_template?
      "fromTemplate"
    else
      latest_version = attr.try(:doc).try(:versions).try(:last)
      if latest_version
        if latest_version.attrs.none? { |saved_attr| saved_attr.name == attr.name }
          "willAdd"
        end
      end
    end
  end

  def edit_attr_row(attr_fields)
    attr = attr_fields.object
    
    content_tag(:tr, :class => attr_class(attr)) do
      content_tag(:td, :class => "name") do
        td_html = ""
            
        if attr.from_template?
          td_html << attr_fields.label(:value, attr.name) 
          td_html << attr_fields.hidden_field(:name)
        else
          td_html << attr_fields.text_field("position", :style => "width: 1.5em;", 
              :"data-sort-handle-img" => image_path("sort_handle.png"), :class => "position") + " "
          td_html << attr_fields.text_field(:name)
        end
        
        td_html
      end +
      content_tag(:td, render_attr_value_editor(attr_fields), :class => "value")
    end
  end

  def render_attr_value(attr)
    case (attr.ui_type.try(:to_sym))
    when :textarea
      content_tag(:div, attr.value, :class => "document_content")
    else
      attr.value
    end
  end
  
  def attr_row(attr)
    content_tag(:tr) do
      content_tag(:td, attr.name, :class => "name") +
      content_tag(:td, render_attr_value(attr), :class => attr_class(attr), :class => "value")
    end
  end
end
