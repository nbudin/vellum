class TextField < ActiveRecord::Base
  include AttrField

  def self.value_class
    TextValue
  end
end
