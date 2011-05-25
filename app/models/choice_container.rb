module ChoiceContainer
  class ChoicesCoder
    def dump(obj)
      obj.join(",")
    end
    
    def load(str)
      if str
        str.split(/,/).collect(&:strip)
      else
        []
      end
    end
  end
  
  extend ActiveSupport::Concern
  
  included do
    if respond_to?(:serialize)
      serialize :choices, ChoicesCoder.new
    else
      attr_accessor :choices
    end
  end
  
  module InstanceMethods
    def human_choices
      choices.join(", ")
    end

    def human_choices=(human_choices)
      self.choices = human_choices.split(/,/).collect { |choice| choice.strip }
    end
  end
end