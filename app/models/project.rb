require 'zip/zip'

class Project < ActiveRecord::Base
  has_many :doc_templates, :dependent => :destroy, :autosave => true
  has_many :docs, :dependent => :destroy, :include => [:doc_template]

  has_many :relationship_types, :dependent => :destroy, :autosave => true
  has_many :relationships, :dependent => :destroy, :include => [:relationship_type]

  has_many :publication_templates, :dependent => :destroy
  has_many :maps, :dependent => :destroy
  has_many :csv_exports, :dependent => :destroy
  
  has_many :project_memberships
  has_many :members, :class_name => "Person", :through => :project_memberships, :source => :person
  has_many :authors, :class_name => "Person", :through => :project_memberships, :source => :person, :conditions => { "project_memberships.author" => true }
  has_many :admins, :class_name => "Person", :through => :project_memberships, :source => :person, :conditions => { "project_memberships.admin" => true }
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

  def as_vproj_json(options = {})
    as_json( 
      { include: { 
        :project_memberships => { methods: [:email] }, 
        :doc_templates => { include: [:doc_template_attrs] }, 
        :relationship_types => {}, 
        :docs => {}, 
        :relationships => {}, 
        :publication_templates => {}, 
        :maps => { include: [:mapped_doc_templates, :mapped_relationship_types] }, 
        :csv_exports => {}
      } }.merge(options)
    )
  end

  def to_vproj_json(options = {})
    as_vproj_json(options).to_json
  end

  def to_vproj(options = {})
    tempfile = Tempfile.new("#{name}.vproj")
    
    Zip::ZipOutputStream.open(tempfile.path) do |zipfile|
      zipfile.put_next_entry "project.json"
      zipfile.print(to_vproj_json(options))
    end

    tempfile
  end
end
