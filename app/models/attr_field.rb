module AttrField
  def AttrField.included(c)
    c.class_eval "has_one :attr, :as => :attr_configuration"
  end

  # This needs to be overridden by subclasses.
  def value_class
    raise "This is an abstract method."
  end
end
