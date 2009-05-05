# Jipe

module Jipe
  def jipe_id_for(record, field, options = {})
    options = {
      :class => record.class.to_s,
      :id => nil }.update(options || {})
    rclass = options[:class]
    if options[:id]
      return options[:id]
    else
      return "#{rclass.downcase}_#{record.id}_#{field}"
    end
  end

  def jipe_editor_for(record, field, options = {})
    options = { :external_control => true,
      :class => record.class.to_s,
      :rows => 1 }.update(options || {})
    rclass = options[:class]
    outstr = <<-ENDDOC
      <script type="text/javascript">
        new Jipe.InPlaceEditor("#{jipe_id_for(record, field, options)}",
          #{rclass}, #{record.id}, #{field.to_json}, {
    ENDDOC
    if options[:external_control]
      outstr += "externalControl: 'edit_#{jipe_id_for(record, field, options)}', "
      options.delete(:external_control)
    end
    if options[:on_complete]
      outstr += "onComplete: #{options[:on_complete]}, "
      options.delete(:on_complete)
    end
    if protect_against_forgery?
      outstr += "authenticityToken: '#{form_authenticity_token}', "
    end
    outstr += "rows: #{options[:rows]},"
    options.delete(:rows)
    options.delete(:id)
    
    # everything else is ajax options
    outstr += "ajaxOptions: {"
    options.each_pair do |k, v|
      outstr += "'#{escape_javascript k.to_s}': '#{escape_javascript v.to_s}',"
    end
    
    outstr += "}});\n</script>"
    return outstr
  end

  def jipe_editor(record, field, options = {})
    options = { :external_control => true,
      :class => record.class.to_s,
      :rows => 1,
      :editing => true,
      :on_complete => nil }.update(options || {})
    rclass = options[:class]
    outstr = <<-ENDDOC
      <span id="#{jipe_id_for(record, field, options)}">
        #{record.send(field)}
      </span>
    ENDDOC
    if options[:editing]
      outstr += <<-ENDDOC
        #{ options[:external_control] ? image_tag("jipe/edit-field.png",
          { :id => "edit_#{jipe_id_for(record, field, options)}" }) : "" }
        #{ jipe_editor_for(record, field, options)}
      ENDDOC
    end
    return outstr
  end
  
  def jipe_image_toggle(record, field, true_image, false_image, options = {})
    options = {
      :class => record.class.to_s,
      :on_complete => nil,
    }.update(options || {})
    rclass = options[:class]
    value = record.send(field)
    idprefix = jipe_id_for(record, field, options)
    
    js_options = {}
    js_options['onComplete'] = options[:on_complete] if options[:on_complete]
    if protect_against_forgery?
      js_options["authenticityToken"] = form_authenticity_token
    end
    
    outstr = <<-ENDDOC
      #{image_tag true_image, :id => "#{idprefix}_true", 
          :style => (value ? "" : "display: none") }
      #{image_tag false_image, :id => "#{idprefix}_false", 
          :style => (value ? "display: none" : "") }
      <script type="text/javascript">
        new Jipe.ImageToggle("#{idprefix}_true", "#{idprefix}_false",
          #{rclass}, #{record.id}, #{field.to_json},
          #{options_for_javascript js_options});
      </script>
    ENDDOC
    return outstr
  end
end
