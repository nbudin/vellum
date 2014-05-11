require 'format_conversions/base'

class FormatConversions::GameTeX < FormatConversions::Base
  class TeXPants < RubyPants
    def to_tex
      # kind of a hack, but we can't just tell RubyPants to replace e.g. double right-quotes with " because it will then replace them again
      # later in the algorithm.
      educate_quotes(self).
        gsub(entity(:single_left_quote), '`').
        gsub(entity(:single_right_quote), "'").
        gsub(entity(:double_left_quote), '``').
        gsub(entity(:double_right_quote), "''")
    end
  end
  
  def self.filename_extension
    ".tex"
  end
  
  def self.mime_type
    "application/x-tex"
  end
  
  def characters(string)
    @output << TeXPants.new(string, [:quotes]).to_tex
  end
  
  def start_element(name, attributes=[])
    @output << case name
    when "strong", "b" then '\textbf{'
    when "em", "i" then '\textit{'
    when "u" then '\uline{'
    when "ul" then "\n\n\\begin{itemz}"
    when "ol" then "\n\n\\begin{enum}"
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
    when "ul" then "\n\\end{itemz}\n\n"
    when "ol" then "\n\\end{enum}\n\n"
    else ""
    end
  end
end
