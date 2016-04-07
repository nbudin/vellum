require 'format_conversions'

class VPubContext < Radius::Context
  class VPubRuntimeError < Exception
    attr_reader :publication_template, :line, :doc
    
    def initialize(msg, publication_template, doc)
      super(msg)
      @template = publication_template
      @line = line
      @doc = doc
    end
  end
    
  attr_reader :format, :publication_template
  
  def initialize(init_options = {})
    super()
    @publication_template = init_options[:publication_template]
    globals.doc = init_options[:doc]
    globals.project = init_options[:project] || (globals.doc && globals.doc.project)
    self.format = init_options[:format] || 'html'
    
    @pub_template_cache = {}
    @layout_stack = (init_options[:layout_stack] || [@publication_template])
    @layout_stack_index = 0
    
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
      
      eval_conditional_tag(tag, tag.locals.attr.value || "")
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
        doc_template = tag.locals.project.doc_templates.find_by(name: tag.attr['template'])
        raise "Couldn't find any template called #{tag.attr['template']}" unless doc_template
        
        conds[:doc_template_id] = doc_template.id
      end
      
      prev_doc = tag.locals.doc
      docs = tag.locals.project.docs.where(conds).to_a
      content = sort_docs(tag, docs).collect do |d|
        tag.locals.doc = d
        tag.expand
      end.join
      tag.locals.doc = prev_doc
      
      content
    end
    
    define_tag 'name' do |tag|
      tag.locals.doc.try(:name)
    end
    
    define_tag 'content' do |tag|
      FormatConversions.convert(tag.locals.doc.content, format_for_tag(tag))
    end
    
    define_tag 'include' do |tag|
      tmpl = get_pub_template(tag)
      
      if tmpl.doc_template 
        if tag.locals.doc
          if tmpl.doc_template != tag.locals.doc.doc_template
            raise VPubRuntimeError.new(
            "Included template \"#{tmpl.name}\" requires a #{tmpl.doc_template.name} but the current doc is a #{tag.locals.doc.doc_template.name}",
            @publication_template, tag.locals.doc)
          end
        else
          raise VPubRuntimeError.new(
          "Included template \"#{tmpl.name}\" requires a #{tmpl.doc_template.name} but there is no current doc",
          @publication_template, tag.locals.doc)
        end
      end

      tmpl.execute(:doc => tag.locals.doc, :project => tag.locals.project)
    end
    
    define_tag 'yield' do |tag|
      @layout_stack_index += 1
      begin
        tmpl = @layout_stack[@layout_stack_index]
      
        raise VPubRuntimeError.new("<v:yield/> called, but no template to yield to", @publication_template, tag.locals.doc) unless tmpl
        Radius::Parser.new(self, :tag_prefix => 'v').parse(tmpl.content)
      ensure
        @layout_stack_index -= 1
      end
    end

    define_tag 'repeat' do |tag|
      times_spec = tag.attr['times'].try(:strip)
      raise VPubRuntimeError.new("v:repeat tags have to specify a 'times' attribute", @publication_template, tag.locals.doc) unless times_spec.present?

      times = if times_spec =~ /^@(.*)/
        tag.locals.doc.attrs[$1].value.to_i
      else
        times_spec.to_i
      end

      content = ""
      single_content = tag.expand
      times.times { content << single_content }
      content
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
    sort_attr = tag.attr['sort'] || '@id'
    fields = sort_attr.split(/\s*,\s*/)

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
          when "id"
            av = a.id
            bv = b.id
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
    tmpl = (@pub_template_cache[template_name] ||= tag.locals.project.publication_templates.find_by(name: template_name))

    if tmpl
      return tmpl
    else
      raise VPubRuntimeError.new("Couldn't find publication template called '#{template_name}'", @publication_template, tag.locals.doc)
    end
  end
end