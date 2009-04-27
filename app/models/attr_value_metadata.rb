class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true, :dependent => :destroy

  validates_uniqueness_of :attr_id, :scope => :structure_id
  validate :check_attr_in_template
  validate :check_value_class

  # Get the value pointed to by this AVM.  If it doesn't yet exist, create
  # a nil value and return it.
  def value
    v = nil
    if value_type and value_id
      begin
        v = eval(value_type).find(value_id)
      rescue ActiveRecord::RecordNotFound
        v = nil
      end
    end
    if v
      return v
    else
      v = attr.attr_configuration.class.value_class.create
      self.value = v
      save
      v.reload
      return v
    end
  end

  private
  def check_attr_in_template
    if attr and structure
      if not structure.template_attrs.include?(attr)
        errors.add("attr", "is not part of #{structure.name}'s template (#{structure.structure_template.name})")
      end
    end
  end

  def check_value_class
    if attr and value_type and value_id
      if not value.kind_of?(attr.attr_configuration.class.value_class)
        avm.errors.add_to_base("Value is a #{value.class} but needs to be a #{attr.attr_configuration.class.value_class}")
      end
    end
  end
end
