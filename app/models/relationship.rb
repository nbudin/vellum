class Relationship < ActiveRecord::Base
  belongs_to :relationship_type
  belongs_to :left, :class_name => "Doc", :foreign_key => "left_id"
  belongs_to :right, :class_name => "Doc", :foreign_key => "right_id"
  belongs_to :project

  validates_presence_of :left, :right, :relationship_type, :project
  validate :check_circular
  validate :check_project_membership
  validate :check_duplicate
  validate :check_templates
  
  attr_reader :source_direction, :source_id, :target_id

  def other(struct)
    if struct == left
      return right
    else
      return left
    end
  end

  def left_description
    relationship_type.left_description
  end

  def right_description
    relationship_type.right_description
  end
  
  def description_for(structure)
    if structure == left
      left_description
    else
      right_description
    end
  end
  
  def relationship_type_id_and_source_direction
    if @source_direction
      "#{relationship_type.id}_#{@source_direction}"
    end
  end
  
  def relationship_type_id_and_source_direction=(str)
    if str =~ /^(\d+)_(left|right)$/
      self.relationship_type_id = $1.to_i
      @source_direction = $2
      setup_from_source_and_target!
    end
  end
  
  def source_direction=(source_direction)
    @source_direction = source_direction
    setup_from_source_and_target!
  end
  
  def target_direction
    case @source_direction
    when "left"
      "right"
    when "right"
      "left"
    end
  end
  
  def source_id=(source_id)
    @source_id = source_id
    setup_from_source_and_target!
  end
  
  def target_id=(target_id)
    @target_id = target_id
    setup_from_source_and_target!
  end

  private
  def setup_from_source_and_target!
    if @source_direction and @source_id and @target_id
      case @source_direction
      when "left"
        self.left_id = @source_id
        self.right_id = @target_id
      when "right"
        self.right_id = @source_id
        self.left_id = @target_id
      end
    end
  end
  
  def check_circular
    if left == right
      errors.add_to_base("This relationship is circular.")
    end
  end

  def check_project_membership
    if project
      [:left, :right].each do |dir|
        struct = self.send(dir)
        if struct
          if struct.project.nil?
            errors.add(dir, "belongs to no project, but this relationship is part of #{project.name}")
          elsif struct.project != project
            errors.add(dir, "belongs to project #{struct.project.name}, but this relationship is part of #{project.name}")
          end
        end
      end
    end
  end

  def check_duplicate
    if left and right and relationship_type and not (left.new_record? or right.new_record?)
      others = left.outward_relationships.select do |rel| 
        ((self.new_record? or rel.id != self.id) and
         rel.right == right and
         rel.relationship_type == relationship_type)
      end
      if others.size > 0
        errors.add_to_base("#{left.name} already #{relationship_type.left_description} #{right.name}")
      end
    end
  end

  def check_templates
    [:left, :right].each do |dir|
      doc = self.send(dir)
      if doc and relationship_type
        tmpl = relationship_type.send("#{dir}_template")
        if tmpl and doc.doc_template and doc.doc_template != tmpl
          errors.add(dir, "should be a #{tmpl.name} but instead is a #{doc.doc_template.name}")
        end
      end
    end
  end
end
