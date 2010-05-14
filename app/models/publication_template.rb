class PublicationTemplate < ActiveRecord::Base
  belongs_to :project
  
  def execute(doc)
    context = VPubContext.new(doc)
    if format
      context.format = format
    end
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(content)
  end
end
