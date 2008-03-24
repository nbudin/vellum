module AttrField
  def AttrField.included(c)
    c.class_eval "has_one :attr, :as => :attr_configuration"
  end

  # This needs to be overridden by subclasses.
  def AttrField.value_class
    raise "This is an abstract method."
  end
   
  def AttrField.partial
    return self.class.name.tableize.singularize
  end
  
  def AttrField.config_partial
    return "config_" + partial
  end
end
