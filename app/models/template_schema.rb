class TemplateSchema < ActiveRecord::Base
  has_many :projects
  has_many :structure_templates, :dependent => :destroy
  has_many :relationship_types, :dependent => :destroy
  
  acts_as_permissioned

  def to_vschema(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]

    xml.vellumschema do
      xml.name(name)

      xml.structure_templates do
        structure_templates.each do |template|
          xml.doc_template(:id => template.id) do
            xml.name(template.name)
            
            xml.attrs do
              template.attrs.each do |attr|
                xml.attr(:id => attr.id) do
                  xml.name(attr.name)
                  if attr.required
                    xml.required(attr.required)
                  end
                  xml.config_type(attr.attr_configuration.type)
                  xml << attr.attr_configuration.to_xml(:skip_instruct => true)
                end
              end
            end
          end
        end
      end
      
      xml.relationship_types do
        relationship_types.each do |relationship_type|
          xml.relationship_type(:id => relationship_type.id) do
            %w{ name left_description right_description left_template_id right_template_id }.each do |a|
              xml.tag!(a, relationship_type.send(a))
            end
          end
        end
      end
    end
  end
end
