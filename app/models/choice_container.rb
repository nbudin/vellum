module ChoiceContainer
  def choices
    choice_str = read_attribute(:choices)
    case choice_str
    when String
      choice_str.split(/,/).collect { |choice| choice.strip }
    else
      []
    end
  end

  def choices=(new_choices)
    write_attribute :choices, case new_choices
    when Array
      new_choices.join(",")
    else
      new_choices
    end
  end

  def human_choices
    choices.join(", ")
  end

  def human_choices=(human_choices)
    self.choices = human_choices.split(/,/).collect { |choice| choice.strip }
  end
end