class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true

  validates_uniqueness_of :attr_id, :scope => :structure_id

  # Get the value pointed to by this AVM.  If it doesn't yet exist, create
  # a nil value and return it.
  def value
    v = nil
    if value_type
      v = eval(value_type).find(value_id)
    end
    if v
      return v
    else
      v = attr.attr_configuration.value_class.create
      self.value = v
      save
      return v
    end
  end
end
