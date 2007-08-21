class AttributeValueMetadata < ActiveRecord::Base
  belongs_to :attribute
  belongs_to :structure
  belongs_to :value, :polymorphic => true
end
