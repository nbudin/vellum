class Project
  include Mongoid::Document
  
  field :name, type: String
  field :blurb, type: String
  field :public_visibility, type: Symbol
  index :public_visibility
  
  has_many :doc_templates, :dependent => :destroy, :autosave => true
  has_many :docs, :dependent => :destroy, :include => [:doc_template]

  has_many :relationship_types, :dependent => :destroy, :autosave => true
  has_many :relationships, :dependent => :destroy, :include => [:relationship_type]

  has_many :publication_templates, :dependent => :destroy
  has_many :maps, :dependent => :destroy
  has_many :csv_exports, :dependent => :destroy
  
  embeds_many :project_memberships
  accepts_nested_attributes_for :project_memberships, :allow_destroy => true, :reject_if => lambda { |attrs| attrs['email'].blank? }

  attr_reader :template_source_project_id
  validates_associated :doc_templates
  validates_associated :relationship_types
  validates_presence_of :name
  validates_inclusion_of :public_visibility, :in => %w(hidden visible copy_templates)
  
  def to_param
    if name
      return "#{id}-#{name.parameterize}"
    else
      return "#{id}"
    end
  end
  
  def authors
    Person.where(:id => project_memberships.select(&:author?).map(&:person_id)).all
  end

  def clone_templates_from(project)
    new_templates = {}

    project.doc_templates.each do |tmpl|
      logger.debug "Duplicating #{tmpl.name} template"
      new_tmpl = self.doc_templates.build(:name => tmpl.name)
      new_templates[tmpl.id] = new_tmpl

      tmpl.doc_template_attrs.each do |dta|
        new_attr = new_tmpl.doc_template_attrs.build(:name => dta.name, 
          :position => dta.position, :ui_type => dta.ui_type,
          :choices => dta.choices)
      end
    end

    logger.debug "Duplicating relationship types from project #{project.name}"
    project.relationship_types.each do |rt|
      self.relationship_types.build(:name => rt.name,
        :left_description => rt.left_description,
        :right_description => rt.right_description,
        :left_template => new_templates[rt.left_template.id],
        :right_template => new_templates[rt.right_template.id],
        :project => self
      )
    end
  end

  def template_source_project_id=(project_id)
    unless project_id.blank?
      self.clone_templates_from(Project.find(project_id))
      @template_source_project_id = project_id
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
            xml.email(author.email)
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
          xml.doc_template_id(structure.doc_template_id)
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
