class Relationship < ActiveRecord::Base
  belongs_to :relationship_type
  belongs_to :left, :class_name => "Structure", :foreign_key => "left_id"
  belongs_to :right, :class_name => "Structure", :foreign_key => "right_id"
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
          unless struct.project == project
            errors.add(dir, "belongs to project #{struct.project.name}, but this relationship is part of #{project.name}")
          end
        end
      end
    end
  end

  def check_duplicate
    if left and right and relationship_type
      conds = {:left_id => left.id, :right_id => right.id, :relationship_type_id => relationship_type.id}
      other = nil
      if id
        conds[:id] = id
        other = Relationship.find(:first, :conditions => ["left_id = :left_id and right_id = :right_id and relationship_type = :relationship_type_id and id <> :id", conds])
      else
        other = Relationship.find(:first, :conditions => conds)
      end
      if other
        errors.add_to_base("#{left.name} already #{relationship_type.left_description} #{right.name}")
      end
    end
  end
end
