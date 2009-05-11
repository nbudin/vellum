class ChoiceField < ActiveRecord::Base
  include AttrField

  def self.value_class
    ChoiceValue
  end
end
