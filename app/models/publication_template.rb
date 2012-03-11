class PublicationTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :project
  belongs_to :doc_template
  
  field :name, type: String
  field :format, type: Symbol
  field :content, type: String
  
  index :project  
  
  def execute(context_options)
    context = VPubContext.new({:format => self.read_attribute(:format), :publication_template => self}.update(context_options))
    parser = Radius::Parser.new(context, :tag_prefix => 'v')
    parser.parse(content)
  end
  
  def output_format
    read_attribute :format
  end
end
