class StructureContext < Radius::Context
  attr_reader :doc, :format
  
  def initialize(doc)
    super()
    @doc = doc
    globals.doc = @doc
    self.format = 'html'
    
    define_tag 'attr' do |tag|
      get_attr tag
      tag.expand
    end
    
    define_tag 'attr:value' do |tag|
      get_attr tag
      
      tag.locals.attr.value(tag.attr['format'] || @format)
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
    
    define_tag 'name' do |tag|
      tag.locals.doc.name
    end
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