class Project < ActiveRecord::Base
  has_many :structure_templates, :dependent => :destroy, :autosave => true
  has_many :structures, :dependent => :destroy, :include => [:structure_template]

  has_many :relationship_types, :dependent => :destroy, :autosave => true
  has_many :relationships, :dependent => :destroy, :include => [:relationship_type]

  has_many :publication_templates, :dependent => :destroy
  has_many :maps, :dependent => :destroy
  
  acts_as_permissioned

  attr_reader :template_source_project_id
  validates_associated :structure_templates
  validates_associated :relationship_types

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
    people = ids.collect { |id| id and Person.find(id) }.compact
    people += self.permitted_people("edit")
    people.uniq
  end
  
  def to_param
    if name
      return "#{id}-#{name.parameterize}"
    else
      return "#{id}"
    end
  end

  def clone_templates_from(project)
    new_templates = {}

    project.structure_templates.each do |tmpl|
      logger.debug "Duplicating #{tmpl.name} template"
      new_tmpl = tmpl.clone
      self.structure_templates << new_tmpl
      new_templates[tmpl.id] = new_tmpl

      tmpl.attrs.each do |attr|
        new_attr = attr.clone
        new_tmpl.attrs << new_attr
        if attr.attr_configuration
          new_conf = attr.attr_configuration.clone
          new_attr.attr_configuration = new_conf
        end
      end
    end

    logger.debug "Duplicating relationship types from project #{project.name}"
    project.relationship_types.each do |rt|
      self.relationship_types << RelationshipType.new(:name => rt.name,
        :left_description => rt.left_description,
        :right_description => rt.right_description,
        :left_template => new_templates[rt.left_template.id],
        :right_template => new_templates[rt.right_template.id]
      )
    end
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
