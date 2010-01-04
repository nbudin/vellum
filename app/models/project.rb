class Project < ActiveRecord::Base
  belongs_to :template_schema
  has_many :structures, :dependent => :destroy, :include => [:structure_template]
  has_many :relationships, :dependent => :destroy, :include => [:relationship_type]
  has_many :maps, :dependent => :destroy
  
  acts_as_permissioned

  def docs
    structures.collect do |struct|
      struct.attr_values.collect do |av|
        if av.kind_of? DocValue
          av.doc
        end
      end
    end.flatten.compact.uniq
  end

  def authors
    ids = docs.collect { |doc| doc.versions.collect { |version| version.author_id }.uniq }.flatten.uniq
    ids.collect { |id| id and Person.find(id) }.compact
  end
  
  def to_param
    return "#{id}-#{name.parameterize}"
  end

  def to_vproj(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]

    xml.vellumproject do
      xml.name(name)

      xml.authors do
        authors.each do |author|
          xml.author(:id => author.id) do
            xml.name(author.name)
            xml.email(author.primary_email_address)
          end
        end
      end

      unless options[:skip_schema]
        xml << template_schema.to_vschema(:skip_instruct => true)
      end

      docs.each do |doc|
        xml.doc(:id => doc.id) do
          versions = options[:all_doc_versions] ? doc.versions : [doc]
          versions.each do |version|
            xml.version(:number => version.version) do
              if version.author_id
                xml.author_id(version.author_id)
              end
              xml.updated_at(version.updated_at)
              xml.content(version.content)
            end
          end
        end
      end
      
      structures.each do |structure|
        xml.structure(:id => structure.id) do
          xml.structure_template_id(structure.structure_template_id)
          xml.attr_values do
            structure.attr_values.each do |av|
              xml.type(av.class.name)
              xml << av.to_xml(:skip_instruct => true)
            end
          end

          xml.outward_relationships do
            structure.outward_relationships.each do |rel|
              xml.relationship_type_id(rel.relationship_type_id)
              xml.right_id(rel.right_id)
            end
          end
        end
      end
    end
  end
end
