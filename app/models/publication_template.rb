class PublicationTemplate < ActiveRecord::Base
  belongs_to :project
  belongs_to :doc_template
  
  def execute(context_options)
    context = VPubContext.new({:format => self.read_attribute(:format)}.update(context_options))
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(content)
  end
  
  def output_format
    read_attribute :format
  end
end
