module FormatConversions
  class Base < Nokogiri::XML::SAX::Document
    attr_reader :output
  
    def self.convert(html)
      doc = self.new
      Nokogiri::HTML::SAX::Parser.new(doc).parse(html)
      doc.output
    end
  
    def initialize
      @output = ""
    end
  
    def characters(string)
      @output << string
    end
  
    def cdata_block(string)
      characters(string)
    end  
  end
end