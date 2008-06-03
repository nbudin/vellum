class NumberField < ActiveRecord::Base
  include AttrField

  def self.value_class
    NumberValue
  end
end
