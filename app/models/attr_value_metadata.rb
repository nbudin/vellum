class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true

  # Get the value pointed to by this AVM.  If it doesn't yet exist, create
  # a nil value and return it.
  def value
    v = read_attribute(value)
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
