require 'format_conversions/base'

class FormatConversions::FO < FormatConversions::Base
  def self.filename_extension
    ".xml"
  end
  
  def self.mime_type
    "application/xslfo+xml"
  end
  
  def start_element(name, attributes=[])
    @output << case name
    when "p" then %(<block space-after.optimum="8pt" widows="4" orphans="4">)
    when "ul"
      %(
      <list-block start-indent="from-parent(start-indent) + 0.5em"
                  provisional-distance-between-starts="1em"
                  provisional-label-separation="0.5em" space-after.optimum="1em">
      )
    when "li"
      %(
      <list-item>
        <list-item-label end-indent="label-end()">
          <block>&#x2022;</block>
        </list-item-label>
        <list-item-body start-indent="body-start()">
          <block>
      )
    else ""
    end
  end
  
  def end_element(name, attributes=[])
    @output << case name
    when "p" then "</block>"
    when "ul" then "</list-block>"
    when "li"
      %(
          </block>
        </list-item-body>
      </list-item>
      )
    else ""
    end
  end
end