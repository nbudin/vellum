class VPubContext < Radius::Context
  attr_reader :project, :doc, :format
  
  def initialize(init_options = {})
    super()
    @doc = init_options[:doc]
    @project = init_options[:project] || @doc.project
    globals.project = @project
    globals.doc = @doc
    self.format = init_options[:format] || 'html'
    
    @pub_template_cache = {}
    
    define_tag 'attr' do |tag|
      get_attr tag
      tag.expand
    end
    
    define_tag 'attr:value' do |tag|
      get_attr tag
      
      tag.locals.attr.value(format_for_tag(tag))
    end
    
    define_tag 'attr:if_value' do |tag|
      get_attr tag
      
      eval_conditional_tag(tag, tag.locals.attr.value)
    end
    
    define_tag 'each_related' do |tag|
      how = tag.attr['how']
      
      tag.locals.do_not_recurse ||= [tag.locals.doc]

      related = tag.locals.doc.related_docs(how).reject do |d|
        tag.locals.do_not_recurse.include?(d)
      end
      tag.locals.do_not_recurse += related

      sort_docs(tag, related).collect do |d|
        tag.locals.doc = d
        tag.expand
      end.join("")
    end
    
    define_tag 'each_doc' do |tag|
      conds = {}
      if tag.attr['template']
        conds[:doc_template_id] = project.doc_templates.find_by_name(tag.attr['template']).id
      end
      
      prev_doc = tag.locals.doc
      docs = project.docs.all(:conditions => conds)
      content = sort_docs(tag, docs).collect do |d|
        tag.locals.doc = d
        tag.expand
      end.join
      tag.locals.doc = prev_doc
      
      content
    end
    
    define_tag 'name' do |tag|
      tag.locals.doc.name
    end
    
    define_tag 'content' do |tag|
      content = tag.locals.doc.content
      
      if format_for_tag(tag) == "fo"
        FormatConversions.html_to_fo(content)
      else
        content
      end
    end
    
    define_tag 'include' do |tag|
      tmpl = get_pub_template(tag)
      
      if tmpl.doc_template && tmpl.doc_template != @doc.doc_template
        raise "Included template \"#{tmpl.name}\" requires a #{tmpl.doc_template.name} but the current doc is a #{doc.doc_template.name}"
      end

      tmpl.execute(:doc => @doc, :project => @project)
    end
  end
  
  def format_for_tag(tag)
    tag.attr['format'] || @format
  end
  
  def format=(format)
    @format = format
  end
  
  def get_attr(tag)
    if tag.attr['name']
      tag.locals.attr = tag.locals.doc.attrs[tag.attr['name']]
    end
  end
  
  def sort_docs(tag, docs)
    return docs unless tag.attr['sort']
    
    fields = tag.attr['sort'].split(/\s*,\s*/)
    docs.sort do |a, b|
      fields_to_try = fields.dup
      result = 0
      
      while fields_to_try.size > 0 && result == 0
        field = fields_to_try.shift

        desc = 1
        numeric = false
        special = false

        if field =~ /([^A-Za-z0-9]+)(.*)$/
          options = $1
          field = $2
          
          numeric = true if options.include? '#'
          desc = -1 if options.include? '-'
          special = true if options.include? '@'
        end
        
        if special
          case field
          when "name"
            av = a.name
            bv = b.name
          else
            av = nil
            bv = nil
          end
        else
          av = a.attrs[field].value
          bv = b.attrs[field].value
        end
        
        if numeric
          av = av.try(:to_f)
          bv = bv.try(:to_f)
        end
        
        result = if av.nil? && bv.nil?
          0
        elsif av.nil?
          -1
        elsif bv.nil?
          1
        else
          av <=> bv
        end
        
        result *= desc
      end
      
      result
    end
  end
  
  def eval_conditional_tag(tag, value)
    cond = false
    if tag.attr['eq']
      cond ||= (value == tag.attr['eq'])
    end
    if tag.attr['ne']
      cond ||= (value != tag.attr['ne'])
    end
    if tag.attr['match']
      cond ||= (value =~ /#{tag.attr['match']}/)
    end
    
    if cond
      tag.expand
    end
  end
  
  def get_pub_template(tag)
    template_name = tag.attr['template']
    tmpl = (@pub_template_cache[template_name] ||= @project.publication_templates.find_by_name(template_name))
    
    if tmpl
      return tmpl
    else
      raise "Couldn't find publication template called '#{template_name}'"
    end
  end
end