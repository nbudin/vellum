class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true

  validates_uniqueness_of :attr_id, :scope => :structure_id
  validate do |avm|
    if avm.attr and avm.value
      if not avm.value.kind_of?(avm.attr.attr_configuration.class.value_class)
        avm.errors.add_to_base("Value is a #{avm.value.class} but needs to be a #{avm.attr.attr_configuration.class.value_class}")
      end
    end
  end

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
      v = attr.attr_configuration.class.value_class.create
      self.value = v
      save
      return v
    end
  end
end
