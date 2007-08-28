module AttrValue
  def AttrValue.included(c)
    c.class_eval "has_one :attr_value_metadata, :as => :value"
  end

  def attr
    attr_value_metadata.attr
  end

  def field
    attr.attr_configuration
  end
end
