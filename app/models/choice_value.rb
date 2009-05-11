class ChoiceValue < ActiveRecord::Base
  include AttrValue

  has_and_belongs_to_many :choices
  validate :check_valid_choice
  validate :check_multiple

  def value
    if field.multiple
      choices.collect { |c| c.value }
    elsif choices.length > 0
      choices[0].value
    else
      nil
    end
  end

  private
  def check_valid_choice
    choices.each do |choice|
      unless choice.choice_field == field
        errors.add(:choices, "#{choice.value} is not one of the valid choices for this field")
      end
    end
  end

  def check_multiple
    unless field and field.multiple
      if choices.length > 1
        errors.add(:choices, "has multiple choices selected, but this is not a multiple choice field")
      end
    end
  end
end
