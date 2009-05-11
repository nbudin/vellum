class ChoiceField < ActiveRecord::Base
  include AttrField
  has_many :choices, :dependent => :destroy, :order => :position

  def self.value_class
    ChoiceValue
  end

  def choice_values
    choices.collect { |c| c.value }.join(", ")
  end

  def choice_values=(values)
    cvs = choices.collect { |c| c.value }
    nvs = values.split(/\s*,\s*/)
    nvs.each do |value, i|
      unless cvs.include? value
        choices.create :value => value
      end
      c = choices.find_by_value(value)
      c.position = i + 1
      c.save
    end
    cvs.each do |value|
      unless nvs.include? value
        Choice.destroy_all(:value => value, :choice_field_id => id)
      end
    end
  end

  def extra_methods
    [:choice_values]
  end
end
