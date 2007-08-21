class Relationship < ActiveRecord::Base
  belongs_to :relationship_type
  belongs_to :left, :polymorphic => true
  belongs_to :right, :polymorphic => true
end
