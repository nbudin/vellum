class Relationship < ActiveRecord::Base
  belongs_to :relationship_type
  belongs_to :left, :class_name => "Structure", :foreign_key => "left_id"
  belongs_to :right, :class_name => "Structure", :foreign_key => "right_id"

  validates_presence_of :relationship_type_id, :left_id, :right_id
  validate { |r|
    if r.left == r.right
      r.errors.add_to_base("This relationship is circular.")
    end
  }

  def other(struct)
    if struct == left
      return right
    else
      return left
    end
  end
end
