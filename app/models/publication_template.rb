class PublicationTemplate < ActiveRecord::Base
  class VPubPreprocessor < Radius::Context
    def initialize(publication_template)
      super

      @publication_template = publication_template
      
      
    end
    
    def tag_missing(tag, attr, &block)
      "<v:#{tag}>"
    end
  end
  
  belongs_to :project
  belongs_to :doc_template
  belongs_to :layout, class_name: "PublicationTemplate"
  
  def execute(context_options)
    stack = layout_stack
    context = VPubContext.new({:format => self.read_attribute(:format), :publication_template => self, :layout_stack => stack}.update(context_options))
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(stack.first.content)
  end
  
  def output_format
    read_attribute :format
  end
  
  private
  def layout_stack
    (layout.try(:layout_stack) || []) + [self]
  end  
end
