class Map < ActiveRecord::Base
  belongs_to :project
  has_many :mapped_doc_templates, :dependent => :destroy
  has_many :mapped_relationship_types, :dependent => :destroy
  has_many :doc_templates, -> { order("doc_templates.id") }, :through => :mapped_doc_templates
  has_many :relationship_types, -> { order("relationship_types.id") }, :through => :mapped_relationship_types
  
  COLORS = %w{red darkgreen blue orange purple black}
  
  def docs
    project.docs
  end
  
  def relationships
    project.relationships
  end
  
  def doc_options(doc, mapped_doc_template=nil)
    color = mapped_doc_template && mapped_doc_template.color
    color ||= color_collection(docs, doc.doc_template)
    
    {
      :label => doc.name,
      :color => color,
      :fontcolor => color
    }
  end
  
  def relationship_options(relationship, mapped_relationship_type = nil)
    {
      :color => mapped_relationship_type && mapped_relationship_type.color
    }
  end
  
  def dot_output_for_gvapi(options={})
    generate_output("none", options).gsub(/\s+/, " ")
  end
  
  def output(format, options={})
    if ENV["GVAPI_URL"]
      url = URI.parse(ENV["GVAPI_URL"])
      req = Net::HTTP::Post.new(url.path)
      req.form_data = gvapi_params(format, options)
      req.basic_auth url.user, url.password if url.user
      
      Net::HTTP.new(url.host, url.port).start do |http|
        return http.request(req).body
      end
    else
      generate_output(format, options)
    end
  end
  
  def generate_output(format, options={})
    graphviz.output(options.update(format.to_sym => String))
  end
  
  def gvapi_params(format, options={})
    key = ENV["GVAPI_KEY"]
    params = { :data => dot_output_for_gvapi(options) }
    params[:format] = format if format
    params[:key] = key if key

    params
  end
  
  def graphviz_method
    method = read_attribute :graphviz_method
    if method.blank?
      return "neato"
    else
      return method
    end
  end
  
  def graphviz
    g = GraphViz::new("map_#{id}", :use => graphviz_method, :size => "8.5,11",
                      :overlap => "false", :splines => "true")

    nodes = {}
    mapped_doc_templates.each do |mdt|
      next unless mdt.doc_template
      mdt.doc_template.docs.all(:conditions => { :project_id => project.id }).each do |doc|
        nodes[doc.id] = g.add_node("doc_#{doc.id}",
                                doc_options(doc, mdt))
      end
    end
    
    mapped_relationship_types.each do |mrt|
      next unless mrt.relationship_type
      mrt.relationship_type.relationships.all(:conditions => { :project_id => project.id }).each do |relationship|
        next unless nodes[relationship.left_id] && nodes[relationship.right_id]
        g.add_edge(nodes[relationship.left_id], nodes[relationship.right_id],
                 relationship_options(relationship, mrt))
      end
    end
    
    return g
  end
  
  def color_collection(coll, obj)
    unless coll.include?(obj)
      coll << obj
    end
    color_number(coll.index(obj))
  end
  
  def color_number(n)
    COLORS[n % COLORS.size]
  end
end
