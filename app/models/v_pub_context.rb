class VPubContext < Radius::Context
  attr_reader :project, :doc, :format
  
  def initialize(init_options = {})
    super()
    @doc = init_options[:doc]
    @project = init_options[:project] || @doc.project
    globals.project = @project
    globals.doc = @doc
    self.format = init_options[:format] || 'html'
    
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

      related.collect do |d|
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
      content = project.docs.all(:conditions => conds).collect do |d|
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
end