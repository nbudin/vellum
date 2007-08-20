class Attribute < ActiveRecord::Base
  belongs_to :attribute_configuration, :polymorphic => true
end
