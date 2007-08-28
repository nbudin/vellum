class TextField < ActiveRecord::Base
  include AttrField

  def value_class
    TextValue
  end
end
