class TextValue < ActiveRecord::Base
  include AttrValue

  def string_rep
    val = read_attribute(:value)
    val.blank? ? field.default : val
  end
  
  def has_value?
    not read_attribute(:value).blank?
  end
end
