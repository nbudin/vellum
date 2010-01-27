class StructureContext < Radius::Context
  attr_reader :structure, :format
  
  def initialize(structure)
    super()
    @structure = structure
    globals.structure = @structure
    self.format = 'html'
    
    define_tag 'attr' do |tag|
      get_attr_value tag
      tag.expand
    end
    
    define_tag 'attr:value' do |tag|
      get_attr_value tag
      
      if tag.locals.attr.nil?
        "[ERROR: Not in an attr while evaluating attr:value]"
      elsif !tag.locals.attr.respond_to?(:value)
        "[ERROR: Attr #{tag.locals.attr.id} doesn't have a value method]"
      else
        tag.locals.attr.value
      end
    end
    
    define_tag 'attr:if_value' do |tag|
      get_attr_value tag
      
      eval_conditional_tag(tag, tag.locals.attr.value)
    end
    
    define_tag 'attr:doc' do |tag|
      get_attr_doc tag
      tag.expand
    end
    
    define_tag 'attr:doc:content' do |tag|
      get_attr_doc tag
      
      tag.locals.doc.content(tag.attr['format'] || @format)
    end
    
    define_tag 'each_related' do |tag|
      how = tag.attr['how']
      
      tag.locals.do_not_recurse ||= [tag.locals.structure]
      related = []
      project = tag.locals.structure.project
      project.relationship_types.find_all_by_left_description(how).each do |typ|
        related += tag.locals.structure.related_structures(typ, :outward)
      end
      project.relationship_types.find_all_by_right_description(how).each do |typ|
        related += tag.locals.structure.related_structures(typ, :inward)
      end
      
      related.reject! { |s| tag.locals.do_not_recurse.include?(s) } 
      tag.locals.do_not_recurse += related
      
      related.collect do |s|
        tag.locals.structure = s
        tag.expand
      end.join("")
    end
    
    define_tag 'name' do |tag|
      tag.locals.structure.name
    end
  end
  
  def format=(format)
    @format = format
  end
  
  def get_attr_value(tag)
    if tag.attr['name']
      tag.locals.attr = tag.locals.structure.attr_value(tag.attr['name'])
    end
  end
  
  def get_attr_doc(tag)
    get_attr_value tag
    tag.locals.doc = tag.locals.attr && tag.locals.attr.doc
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