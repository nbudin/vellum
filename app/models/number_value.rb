class NumberValue < ActiveRecord::Base
  include AttrValue
  
  validates_numericality_of :value, :allow_nil => true
  
  def string_rep
    val = read_attribute(:value)
    if val.blank?
      val = field.default
    end
    if val.to_i == val
      return val.to_i.to_s
    else
      return val.to_s
    end
  end
  
  def has_value?
    not read_attribute(:value).blank?
  end
end
