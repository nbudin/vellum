class TextValue < ActiveRecord::Base
  include AttrValue

  def value
    read_attribute(:value) || field.default
  end
end
