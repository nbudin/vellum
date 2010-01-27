class TemplateSchema < ActiveRecord::Base
  has_many :structure_templates
  has_many :projects
  has_many :relationship_types
end

class StructureTemplate < ActiveRecord::Base
  belongs_to :project
  belongs_to :template_schema
  has_many :attrs
  has_many :required_attrs, :class_name => "Attr", :conditions => "required = 1"
end

class RelationshipType < ActiveRecord::Base
  belongs_to :project
  belongs_to :template_schema
  belongs_to :left_template, :class_name => "StructureTemplate"
  belongs_to :right_template, :class_name => "StructureTemplate"
end

class Project < ActiveRecord::Base
  belongs_to :template_schema
  has_many :structure_templates
  has_many :relationship_types
  has_many :relationships
  has_many :structures
end

class MoveStructureTemplatesOntoProjects < ActiveRecord::Migration
  def self.up
    add_column :structure_templates, :project_id, :integer
    add_index :structure_templates, :project_id
    remove_column :structure_templates, :workflow_id
    remove_column :structure_templates, :parent_id

    add_column :relationship_types, :project_id, :integer
    add_index :relationship_types, :project_id

    TemplateSchema.all(:include => [:structure_templates, :projects]).each do |schema|
      say "Migrating template schema #{schema.name}"
      if schema.projects.size > 1
        say "Schema has multiple projects, creating duplicates for each project"
        schema.projects.slice(1, schema.projects.length).each do |project|
          say "Duplicating templates for project #{project.name}"

          new_templates = {}

          schema.structure_templates.each do |tmpl|
            say "Duplicating #{tmpl.name} template"
            new_tmpl = StructureTemplate.new :project => project, :name => tmpl.name
            new_tmpl.save!
            new_templates[tmpl.id] = new_tmpl

            project.structures.all(:conditions => {:structure_template_id => tmpl.id}).each do |structure|
              structure.structure_template = new_tmpl
              structure.save!
            end

            tmpl.attrs.each do |attr|
              new_attr = new_tmpl.attrs.new :name => attr.name, :position => attr.position,
                :required => attr.required
              if attr.attr_configuration
                new_conf = attr.attr_configuration.clone
                new_conf.save!
                new_attr.attr_configuration = new_conf
              end
              new_attr.save!

              avms = attr.attr_value_metadatas.all(
                :conditions => ["structures.project_id = ?", project.id], :joins => :structure,
                :readonly => false)
              avms.each do |avm|
                avm.attr = new_attr
                avm.save!
              end
            end
          end

          say "Duplicating relationship types for project #{project.name}"
          schema.relationship_types.each do |rt|
            new_rt = project.relationship_types.new(:name => rt.name,
              :left_description => rt.left_description,
              :right_description => rt.right_description,
              :left_template => new_templates[rt.left_template.id],
              :right_template => new_templates[rt.right_template.id]
            )
            new_rt.save!

            project.relationships.all(:conditions => { :relationship_type_id => rt.id }).each do |rel|
              rel.relationship_type = new_rt
              rel.save!
            end
          end
        end
      end

      project = schema.projects.first
      if project.nil?
        say "Creating empty project for unused schema #{schema.name}"
        project = Project.create :name => schema.name
      end

      say "Moving schema's templates onto project #{project.name}"
      schema.structure_templates.each do |tmpl|
        tmpl.project = project
        tmpl.save!
      end

      say "Moving schema's relationship types onto project #{project.name}"
      schema.relationship_types.each do |rt|
        rt.project = project
        rt.save!
      end
    end

    remove_column :structure_templates, :template_schema_id
    remove_column :relationship_types, :template_schema_id
    remove_column :projects, :template_schema_id
    drop_table :template_schemas
  end

  def self.down
    create_table "template_schemas", :force => true do |t|
      t.string "name"
      t.text "description"
    end

    add_column :structure_templates, :template_schema_id, :integer
    add_column :relationship_types, :template_schema_id, :integer
    add_column :projects, :template_schema_id, :integer

    Project.all.each do |project|
      say "Creating template schema for project #{project.name}"

      schema = project.create_template_schema :name => "#{project.name} templates"
      project.save!
      
      project.structure_templates.each do |tmpl|
        tmpl.template_schema = schema
        tmpl.save!
      end

      project.relationship_types.each do |rt|
        rt.template_schema = schema
        rt.save!
      end
    end

    remove_column :relationship_types, :project_id

    add_column :structure_templates, :parent_id, :integer
    add_column :structure_templates, :workflow_id, :integer

    remove_column :structure_templates, :project_id
  end
end
