class CsvExport
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :project
  belongs_to :doc_template
  
  field :name, type: String
  field :attr_names, type: Array
  
  def attr_names_commasep
    return "" unless attr_names
    
    attr_names.join(", ")
  end
  
  def attr_names_commasep=(names)
    self.attr_names = (names && names.split(/,/).map(&:strip))
  end
  
  def filename
    "#{project.name} - #{name}.csv"
  end
  
  def values_for(doc)
    attr_names.collect do |attr_name| 
      case attr_name
      when "@name"
        doc.name
      when "@content"
        doc.content
      else
        doc.attrs[attr_name].value
      end
    end
  end
  
  def write(csv)
    csv << attr_names
    doc_template.docs.find_each do |doc|
      csv << values_for(doc)
    end
  end
end
