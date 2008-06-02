class TextValue < ActiveRecord::Base
  include AttrValue

  def string_rep
    read_attribute(:value) || field.default
  end
  
  def has_value?
    v = read_attribute(:value)
    return ((not v.nil?) and (v.length > 0))
  end
end
