module FormatConversions
  def self.html_to_fo(html)
    xml = ""
    parser = REXML::Parsers::SAX2Parser.new(html)
    parser.listen(:characters) {|text| xml << text }

    parser.listen(:start_element, %w{ p }) do
      xml << "<block space-after.optimum=\"8pt\" widows=\"4\" orphans=\"4\">"
    end
    parser.listen(:end_element, %w{ p }) do
      xml << "</block>"
    end

    parser.listen(:start_element, %w{ ul }) do
      xml << "<list-block start-indent=\"from-parent(start-indent) + 0.5em\" "
      xml << "provisional-distance-between-starts=\"1em\" "
      xml << "provisional-label-separation=\"0.5em\" space-after.optimum=\"1em\">"
    end
    parser.listen(:end_element, %w{ ul }) do
      xml << "</list-block>"
    end

    parser.listen(:start_element, %w{ li }) do
      xml << "<list-item>"
      xml << "  <list-item-label end-indent=\"label-end()\">"
      xml << "    <block>&#x2022;</block>"
      xml << "  </list-item-label>"
      xml << "  <list-item-body start-indent=\"body-start()\">"
      xml << "    <block>"
    end
    parser.listen(:end_element, %w{ li }) do
      xml << "    </block>"
      xml << "  </list-item-body>"
      xml << "</list-item>"
    end

    parser.parse

    return xml
  end
end