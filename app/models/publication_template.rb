class PublicationTemplate < ActiveRecord::Base
  belongs_to :project
  
  def execute(context_options)
    context = VPubContext.new({:format => format}.update(context_options))
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(content)
  end
end
