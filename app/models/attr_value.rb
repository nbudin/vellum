module AttrValue
  def AttrValue.included(c)
    c.class_eval "has_one :attr_value_metadata, :as => :value"
    c.class_eval "validates_associated :attr_value_metadata"
  end

  def attr
    attr_value_metadata.attr
  end

  def field
    attr.attr_configuration
  end
  
  def string_rep
    "This attribute cannot be represented as a string"
  end
  
  def html_rep
    ERB::Util.html_escape(string_rep)
  end
  
  def has_value?
    return false
  end
end
