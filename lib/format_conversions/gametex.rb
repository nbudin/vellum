class FormatConversions::GameTeX < Nokogiri::XML::SAX::Document
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
    @output << string.gsub(/\s+/, ' ').gsub(/"(?=\S)/, '``')
  end
  
  def cdata_block(string)
    characters(string)
  end
  
  def start_element(name, attributes=[])
    @output << case name
    when "strong", "b" then '\textbf{'
    when "em", "i" then '\textit{'
    when "u" then '\uline{'
    when "ul" then "\n\n\\begin{itemize}"
    when "ol" then "\n\n\\begin{enumerate}"
    when "li" then "\n\\item "
    when "h1" then "\n\\section{"
    when "h2" then "\n\\subsection{"
    when "h3" then "\n\\subsubsection{"
    when "h4" then "\n\\paragraph{"
    when "h5" then "\n\\subparagraph{"      
    when "table", "thead", "tbody", "tr", "td", "th", "caption" then ""
    else ""
    end
  end
  
  def end_element(name)
    @output << case name
    when "strong", "em", "b", "i", "u" then '}'
    when "h1", "h2", "h3", "h4", "h5" then "}\n\n"
    when "p" then "\n\n"
    when "ul" then "\n\\end{itemize}\n\n"
    when "ol" then "\n\\end{enumerate}\n\n"
    else ""
    end
  end
end