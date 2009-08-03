module AttrValue
  def AttrValue.included(c)
    c.class_eval do
      has_one :attr_value_metadata, :as => :value
      
      # validate AVM and pass along errors
      validate do |av|
        if av.attr_value_metadata
          if not av.attr_value_metadata.valid?
            av.attr_value_metadata.errors.each do |attr, msg|
              av.errors.add("#{av.attr.name} #{attr}", msg)
            end
          end
        end
      end
    end
  end

  def attr
    attr_value_metadata && attr_value_metadata.attr
  end

  def field
    attr && attr.attr_configuration
  end

  def structure
    attr_value_metadata && attr_value_metadata.structure
  end
  
  def string_rep
    "This attribute cannot be represented as a string"
  end
  
  def html_rep
    ERB::Util.html_escape(string_rep)
  end
  
  def has_value?
    return false
  end
end
