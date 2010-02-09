module ChoiceContainer
  def choices
    choice_str = read_attribute(:choices)
    choice_str ? choice_str.split(/\|/) : []
  end

  def choices=(new_choices)
    write_attribute :choices, case new_choices
    when Array
      new_choices.join("|")
    else
      new_choices
    end
  end
end