xml.root :xmlns => "http://www.w3.org/1999/XSL/Format" do
  xml.tag!("layout-master-set") do
    xml.tag!("simple-page-master", "master-name" => "letter") do
      xml.tag!("region-body")
    end
    
    xml.tag!("page-sequence-master", "master-name" => "document") do
      xml.tag!("repeatable-page-master-reference", "master-reference" => "letter")
    end
  end
  
  xml.tag!("page-sequence", "master-reference" => "letter") do
    xml.flow "flow-name" => "xsl-region-body" do
      @structure.attrs.each do |a|
        xml.block "font-weight" => "bold" do
          xml.text! a.name
        end
        
        value = @structure.attr_value(a)
        
        case value
        when TextValue, NumberValue
          xml.block { xml.text! value.value.to_s }
        when ChoiceValue
          xml.block { xml.text! value.values.join(", ") }
        when DocValue
          value.doc.write_fo(xml)
        end
      end
    end
  end
end
