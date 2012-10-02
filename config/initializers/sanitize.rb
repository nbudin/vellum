require 'sanitize'

remove_non_vellum_classes = lambda do |env|
  node = env[:node]
  cls = node.get_attribute("class")
  
  unless cls.blank?
    classes = cls.split.select { |c| c =~ /^vellum-/ }

    if classes.empty?
      node.remove_attribute("class")
    else
      node.set_attribute("class", classes.join(" "))
    end
  end
end

remove_unneeded_spans = lambda do |env|
  node = env[:node]
  
  if node.name == "span" && node.attributes.size > 0
    { :node_whitelist => [node] }
  end
end

convert_css_to_tags = lambda do |env|
  node = env[:node]
  
  style = node.get_attribute("style")
    
  if style
    newtags = []
    if style =~ /text-decoration:\s*underline/i
      newtags << "u"
    end
    if style =~ /font-weight:\s*bold/i
      newtags << "strong"
    end
    if style =~ /font-style:\s*italic/i
      newtags << "em"
    end
      
    newtags.each do |newtag|
      children = node.children
      newnode = node.add_child(Nokogiri::XML::Node.new(newtag, node.document))
      children.remove()
      newnode.add_child(children)
    end
  end
  
  node.remove_attribute("style")
end

convert_line_endings_to_unix = lambda do |env|
  node = env[:node]
  
  node.children.select(&:text?).each do |text|
    text.content = text.content.gsub(/\r\n/, "\n")
    text.content = text.content.gsub(/\r/, "\n")
  end
end

Sanitize::Config::VELLUM = {
  :output => :xhtml,
  :elements => %w{p h1 h2 h3 h4 h5 h6 ul ol li b i em strong br u table thead tbody tr td th},
  :attributes => {
    :all => %w{class}
  },
  :transformers => [ remove_non_vellum_classes, convert_css_to_tags, remove_unneeded_spans, convert_line_endings_to_unix ]
}