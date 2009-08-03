class AttrValueMetadata < ActiveRecord::Base
  belongs_to :attr
  belongs_to :structure
  belongs_to :value, :polymorphic => true, :dependent => :destroy

  validates_uniqueness_of :attr_id, :scope => :structure_id
  validate :check_attr_in_template
  validate :check_value_class

  def obtain_value
    if value
      return value
    elsif attr.attr_configuration
      attr.attr_configuration.class.value_class.create! :attr_value_metadata => self
      return value(:force_reload => true)
    else
      return nil
    end
  end

  private
  def check_attr_in_template
    if attr and structure
      if not structure.structure_template.attrs.include?(attr)
        errors.add("attr", "(#{attr.name}) is not part of #{structure.name}'s template (#{structure.structure_template.name})")
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
