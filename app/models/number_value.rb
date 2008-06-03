class NumberValue < ActiveRecord::Base
  include AttrValue
  
  def string_rep
    val = read_attribute(:value) || field.default
    if val.to_i == val
      return val.to_i.to_s
    else
      return val.to_s
    end
  end
  
  def has_value?
    read_attribute(:value)
  end
end
