class PublicationTemplate < ActiveRecord::Base
  belongs_to :template_schema
  
  def execute(structure)
    context = StructureContext.new(structure)
    if format
      context.format = format
    end
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(content)
  end
end
