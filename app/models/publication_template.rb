class PublicationTemplate < ActiveRecord::Base
  belongs_to :project
  belongs_to :doc_template
  belongs_to :layout, class_name: "PublicationTemplate"
  
  TEMPLATE_TYPES = %w(standalone doc layout partial)
  validates :template_type, inclusion: { in: TEMPLATE_TYPES }
  
  def self.human_template_type(template_type)
    case template_type
    when "standalone" then "Standalone publication template"
    when "doc" then "Document publication template"
    else template_type.humanize
    end
  end
  
  def human_template_type
    self.class.human_template_type(template_type)
  end
  
  def execute(context_options)
    stack = layout_stack
    context = VPubContext.new({:format => self.read_attribute(:format), :publication_template => self, :layout_stack => stack}.update(context_options))
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(stack.first.content)
  end
  
  def output_format
    read_attribute :format
  end
  
  def layout_stack
    (layout.try(:layout_stack) || []) + [self]
  end  
end
