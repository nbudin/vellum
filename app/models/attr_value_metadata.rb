class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true
end
