class Relationship < ActiveRecord::Base
  belongs_to :relationship_type
  belongs_to :left, :class_name => "Structure", :foreign_key => "left_id", :include => [:structure_template, :attr_value_metadatas]
  belongs_to :right, :class_name => "Structure", :foreign_key => "right_id", :include => [:structure_template, :attr_value_metadatas]
  belongs_to :project

  validate :check_associations
  validate :check_circular
  validate :check_project_membership
  validate :check_duplicate

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

  private
  def check_associations
    [:left, :right, :relationship_type, :project].each do |att|
      if self.send(att).nil?
        errors.add(att, "must be specified")
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
         relationship_type == relationship_type)
      end
      if others.size > 0
        errors.add_to_base("#{left.name} already #{relationship_type.left_description} #{right.name}")
      end
    end
  end
end
