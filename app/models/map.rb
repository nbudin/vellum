class Map < ActiveRecord::Base
  belongs_to :project
  has_many :mapped_doc_templates, :dependent => :destroy
  has_many :mapped_relationship_types, :dependent => :destroy
  has_many :doc_templates, :through => :mapped_doc_templates, :order => "id"
  has_many :relationship_types, :through => :mapped_relationship_types, :order => "id"
  
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
  
  def output(format, options={})
    graphviz.output(options.update(format.to_sym => String))
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
      project.docs.all(:conditions => ["doc_template_id = ?",
                                       mdt.doc_template.id]).each do |doc|
        nodes[doc] = g.add_node("doc_#{doc.id}",
                                doc_options(doc, mdt))
      end
    end
    
    mapped_relationship_types.each do |mrt|
      project.relationships.all(:conditions => ["relationship_type_id = ?",
                                                mrt.relationship_type.id]).each do |relationship|
        g.add_edge(nodes[relationship.left], nodes[relationship.right],
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
