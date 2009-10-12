class Map < ActiveRecord::Base
  belongs_to :project
  has_many :mapped_structure_templates, :dependent => :destroy
  has_many :mapped_relationship_types, :dependent => :destroy
  has_many :structure_templates, :through => :mapped_structure_templates, :order => "id"
  has_many :relationship_types, :through => :mapped_relationship_types, :order => "id"
  
  COLORS = %w{red darkgreen blue orange purple black}
  
  def structures
    project.structures
  end
  
  def relationships
    project.relationships
  end
  
  def structure_options(structure, mapped_structure_template=nil)
    color = mapped_structure_template && mapped_structure_template.color
    color ||= color_collection(structure_templates, structure.structure_template)
    
    {
      :label => structure.name,
      :color => color,
      :fontcolor => color
    }
  end
  
  def relationship_options(relationship, mapped_relationship_type = nil)
    {
      :color => mapped_relationship_type && mapped_relationship_type.color
    }
  end
  
  def output(options={})
    tf = Tempfile.new("map_#{id}.output")
    tf.close
    graphviz.output(options.update(:file => tf.path))
    data = tf.open.read
    tf.close
    tf.unlink
    return data
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
    mapped_structure_templates.each do |mst|
      project.structures.all(:conditions => ["structure_template_id = ?",
                                             mst.structure_template.id]).each do |structure|
        nodes[structure] = g.add_node("structure_#{structure.id}",
                                    structure_options(structure, mst))
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
