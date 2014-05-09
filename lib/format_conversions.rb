require 'format_conversions/fo'
require 'format_conversions/gametex'

module FormatConversions  
  class HTML
    def self.convert(html)
      html
    end
  end
  
  CONVERTERS = {
    fo: FormatConversions::FO,
    gametex: FormatConversions::GameTeX,
    html: FormatConversions::HTML
  }
  
  class UnknownFormatException < RuntimeError
    attr_reader :format
    
    def initialize(format)
      @format = format
    end
    
    def message
      "#{@format} is not a supported format for output; supported formats are #{FormatConversions::CONVERTERS.keys.sort.to_sentence}"
    end
  end
  
  def self.converter_class(format)
    CONVERTERS[format.to_sym].tap do |klass|
      raise UnknownFormatException.new(format) unless klass
    end
  end
  
  def self.convert(html, format)
    converter_class(format).convert(html)
  end
end