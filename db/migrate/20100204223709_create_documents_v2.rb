class DocField < ActiveRecord::Base
  has_one :attr, :class_name => "AttrV1", :as => :attr_configuration
end

class ChoiceField < ActiveRecord::Base
  has_one :attr, :class_name => "AttrV1", :as => :attr_configuration
  has_many :choices
  
  def multiple
    display_type == "multiple"
  end
end

class TextField < ActiveRecord::Base
  has_one :attr, :class_name => "AttrV1", :as => :attr_configuration
end

class NumberField < ActiveRecord::Base
  has_one :attr, :class_name => "AttrV1", :as => :attr_configuration
end

class Choice < ActiveRecord::Base
  belongs_to :choice_field
  acts_as_list :scope => :choice_field_id
end

class DocValue < ActiveRecord::Base
  has_one :attr_value_metadata, :class_name => "CreateDocumentsV2::AttrValueMetadata", :as => :value
  belongs_to :doc, :class_name => "CreateDocumentsV2::DocV1", :foreign_key => "doc_id"
  
  def attr
    attr_value_metadata.try(:attr)
  end
end

class ChoiceValue < ActiveRecord::Base
  has_one :attr_value_metadata, :class_name => "CreateDocumentsV2::AttrValueMetadata", :as => :value
  has_and_belongs_to_many :choices
  
  def value
    if attr_value_metadata.try(:attr).try(:attr_configuration).try(:multiple)
      choices.collect { |c| c.value }
    elsif choices.length > 0
      choices[0].value
    else
      nil
    end
  end
end

class TextValue < ActiveRecord::Base
end

class NumberValue < ActiveRecord::Base
end

class CreateDocumentsV2 < ActiveRecord::Migration
  class DocV1 < ActiveRecord::Base
    set_table_name "docs"
    version_fu :table_name => "doc_versions", :foreign_key => "doc_id"

    has_one :doc_value, :foreign_key => "doc_id"
    belongs_to :author, :class_name => "Person"
  end

  class Project < ActiveRecord::Base
    has_many :structures
    has_many :docs, :class_name => "DocV2"
    has_many :relationships
    has_many :structure_templates
    has_many :doc_templates
    has_many :maps
  end

  class DocV2 < ActiveRecord::Base
    set_table_name "docs_v2"

    version_fu :foreign_key => "doc_id", :table_name => "doc_versions_v2" do
      belongs_to :author, :class_name => "::Person"
      has_many :attrs, :class_name => "::CreateDocumentsV2::AttrV2", 
        :foreign_key => "doc_version_id", :autosave => true

      def working_attrs
        attr_hash = {}
        self.attrs.each do |attr|
          working_attr = attr.clone
          working_attr.doc_version_id = nil
          working_attr.doc_version = nil
          attr_hash[working_attr.name] = working_attr
        end
        
        return attr_hash
      end

      # we're going to be saving these manually in the migration
      self.record_timestamps = false
    end

    belongs_to :project
    belongs_to :doc_template
    belongs_to :creator, :class_name => "Person"
    belongs_to :assignee, :class_name => "Person"

    has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship"

    def current_version
      versions.select { |v| v.version == self.version }.first
    end

    def last_saved_version
      versions.reject { |v| v.new_record? }.sort_by { |v| v.version }.last
    end

    def attrs
      @attrs || reload_working_attrs
    end

    def reload_working_attrs
      if current_version.nil?
        @attrs = {}
      else
        @attrs = current_version.working_attrs
      end
    end

    def create_new_version?
      super || attrs.values.any? { |a| (a.changes.keys - ["doc_version_id"]).size > 0 }
    end

    def instatiate_revision
      super
      
      self.attrs.each_value do |a|
        a.doc_version = current_version
        current_version.attrs << a
      end

      reload_working_attrs
    end
    
    def attr(name)
      self.attrs[name]
    end

    def obtain_attr(name)
      a = attr(name)
      return a unless a.nil?

      @attrs[name] = AttrV2.new(:name => name)
    end
  end

  class AttrV2 < ActiveRecord::Base
    set_table_name "attrs_v2"

    belongs_to :doc_version, :class_name => "DocV2::Version"
    has_one :doc, :through => :doc_version
    acts_as_list :scope => :doc_version
  end

  class DocTemplate < ActiveRecord::Base
    belongs_to :project
    has_many :doc_template_attrs

    has_many :outward_relationship_types, :foreign_key => :left_template_id, :class_name => "RelationshipType"
  end

  class DocTemplateAttr < ActiveRecord::Base
    belongs_to :doc_template
  end

  class Relationship < ActiveRecord::Base
    belongs_to :project
    belongs_to :left_structure, :class_name => "Structure"
    belongs_to :right_structure, :class_name => "Structure"
    belongs_to :left, :class_name => "DocV2"
    belongs_to :right, :class_name => "DocV2"
    belongs_to :relationship_type
    
    def right_name_v1
      right_id && Structure.find(right_id).try(:name)
    end
    
    def left_description
      relationship_type.try(:left_description)
    end
  end

  class RelationshipType < ActiveRecord::Base
    belongs_to :project
    belongs_to :left_structure_template, :class_name => "StructureTemplate"
    belongs_to :right_structure_template, :class_name => "StructureTemplate"
    belongs_to :left_template, :class_name => "DocTemplate"
    belongs_to :right_template, :class_name => "DocTemplate"

    def left_name_v1
      lt = left_template_id && StructureTemplate.find(left_template_id)
      rt = right_template_id && StructureTemplate.find(right_template_id)
      if lt and rt and left_description
        "#{lt.name} #{left_description} #{rt.name}"
      elsif lt and rt
        "Untitled relationship type (#{left_template.name} to #{right_template.name})"
      else
        "Untitled relationship type"
      end
    end

    def left_name
      if left_template and right_template and left_description
        "#{left_template.name} #{left_description} #{right_template.name}"
      elsif left_template and right_template
        "Untitled relationship type (#{left_template.name} to #{right_template.name})"
      else
        "Untitled relationship type"
      end
    end
  end

  class Map < ActiveRecord::Base
    belongs_to :project
    
    has_many :mapped_structure_templates
    has_many :mapped_relationship_types
    has_many :mapped_doc_templates
  end

  class MappedDocTemplate < ActiveRecord::Base
    belongs_to :map
    belongs_to :doc_template
  end
  
  class MappedStructureTemplate < ActiveRecord::Base
    belongs_to :map
    belongs_to :structure_template
  end
  
  class StructureTemplate < ActiveRecord::Base
    belongs_to :project
    has_many :attrs, :class_name => "AttrV1"
    
    has_many :outward_relationship_types, :foreign_key => :left_template_id, :class_name => "RelationshipType"
  end
  
  class Structure < ActiveRecord::Base
    belongs_to :project
    belongs_to :structure_template
    has_many :attr_value_metadatas
    has_many :attrs, :through => :attr_value_metadatas
    
    has_many :outward_relationships, :foreign_key => :left_id, :class_name => "Relationship"
    has_many :inward_relationships, :foreign_key => :right_id, :class_name => "Relationship"
    
    def avm_for_attr(a)
      a = self.attr(a)
      attr_value_metadatas.select { |avm| avm.attr == a }.first
    end

    def attr_value(a)
      avm = avm_for_attr(a)
      avm && avm.value
    end
    
    def attr(name)
      if name.kind_of? AttrV1
        if name.structure_template == self.structure_template
          name
        else
          attrs.select {|a| a.id == name.id }.first
        end
      elsif name.kind_of? Fixnum
        attrs.select {|a| a.id == name }.first
      else
        attrs.select {|a| a.name == name }.first
      end
    end
  end
  
  class AttrV1 < ActiveRecord::Base
    set_table_name "attrs"
    belongs_to :structure_template
    belongs_to :attr_configuration, :polymorphic => true
  end
  
  class AttrValueMetadata < ActiveRecord::Base
    belongs_to :structure
    belongs_to :attr, :class_name => "AttrV1"
    belongs_to :value, :polymorphic => true
  end

  def self.up
    say "Doing pre-migration data dump..."
    File.open(File.join(RAILS_ROOT, "all-data-structures-v1.txt"), "w") do |file|
      Project.all(:order => "name").each do |project|
        file.puts "Project: #{project.name}"

        project.structure_templates.all(:order => "name").each do |tmpl|
          file.puts "  Template: #{tmpl.name}"

          tmpl.attrs.all(:order => "position").each do |attr|
            file.print "    Attr: #{attr.name}"
            if attr.attr_configuration
              if attr.attr_configuration.kind_of? ChoiceField
                file.print " (#{attr.attr_configuration.display_type}) - "
                file.print(attr.attr_configuration.choices.collect do |choice|
                  choice.value
                end.join("|"))
              else
                display_type = case attr.attr_configuration
                when DocField
                  "textarea"
                else
                  "text"
                end
                file.print " (#{display_type}) - "
              end
            else
              file.print " (no associated config object)"
            end
            file.print "\n"
          end

          tmpl.outward_relationship_types.all(:order => "left_description").each do |rt|
            file.puts "    Relationship type: #{rt.left_name_v1}"
          end

          project.structures.all(:conditions => {:structure_template_id => tmpl.id}, :order => "position").each do |s|
            file.puts "    Doc: #{s.name}"
            tmpl.attrs.all(:order => "position").each do |attr|
              av = s.attr_value(attr.name)
              if av.kind_of? DocValue
                file.puts "      #{attr.name}: #{av.try(:doc).try(:content)}"
              else
                file.puts "      #{attr.name}: #{av.try :value}"
              end
            end

            s.outward_relationships.all.sort_by { |r| "#{r.left_description}#{r.right_name_v1}" }.each do |r|
              file.puts "      Relationship: #{r.left_description} #{r.right_name_v1}"
            end
          end
        end

        project.maps.all(:order => "name").each do |map|
          file.puts "  Map: #{map.name}"
          map.mapped_structure_templates.all(:order => "name", :joins => :structure_template).each do |mst|
            file.puts "    Includes #{mst.structure_template.name} docs in #{mst.color}"
          end
        end
      end
    end

    create_table "doc_templates" do |t|
      t.string "name"
      t.integer "project_id"
    end

    add_index "doc_templates", "project_id"

    create_table "doc_template_attrs" do |t|
      t.string  "name"
      t.integer "doc_template_id"
      t.integer "position"
      t.string  "ui_type", :null => false, :default => "text"

      # only applies if it's a multiple-choice attr
      t.text "choices"
    end

    add_index "doc_template_attrs", [:doc_template_id, :name], :unique => true

    create_table "docs_v2" do |t|
      t.string  "name"
      t.integer "project_id"

      t.integer "doc_template_id"

      t.integer "position"
      t.text    "blurb"

      t.text    "content"

      t.integer "assignee_id"
      t.integer "creator_id"
      t.integer "version", :default => 1
      t.timestamps
    end

    add_index "docs_v2", :project_id

    create_table "doc_versions_v2" do |t|
      t.integer "doc_id"
      t.string  "name"

      t.integer "doc_template_id"

      t.text "content"

      t.integer "author_id"
      t.integer "version"
      t.timestamps
    end

    add_index "doc_versions_v2", :doc_id

    create_table "attrs_v2" do |t|
      t.integer "doc_version_id"

      t.string "name", :null => false
      t.integer "position"

      t.string "format"
      t.text "value"
    end

    add_index "attrs_v2", [:doc_version_id, :name], :unique => true

    create_table "mapped_doc_templates" do |t|
      t.integer "map_id"
      t.integer "doc_template_id"

      t.string "color"
      t.timestamps
    end

    add_index "mapped_doc_templates", [:map_id, :doc_template_id], :unique => true

    # since we just created the docs_v2 table we need to tell it explicitly which
    # the versioned columns are.
    DocV2.versioned_columns = DocV2::Version.new.attributes.keys -
      ['id', 'doc_id', 'version', 'created_at', 'updated_at', 'author_id']

    doc_template_ids = {}
    StructureTemplate.all.each do |tmpl|
      say "Converting #{tmpl.name} to DocTemplate"

      doc_tmpl = DocTemplate.create(:name => tmpl.name, :project => tmpl.project)
      doc_template_ids[tmpl.id] = doc_tmpl.id
      tmpl.attrs.all.each do |attr|
        doc_attr = doc_tmpl.doc_template_attrs.new(
          :name => attr.name,
          :position => attr.position
        )

        case attr.attr_configuration
        when DocField
          doc_attr.ui_type = "textarea"
        when ChoiceField
          doc_attr.ui_type = attr.attr_configuration.display_type || "radio"
          doc_attr.choices = attr.attr_configuration.choices.collect { |c| c.value }.join("|")
        else
          doc_attr.ui_type = "text"
        end

        doc_tmpl.doc_template_attrs << doc_attr
      end
      
      doc_tmpl.save!
    end

    rename_column "relationship_types", "left_template_id", "left_structure_template_id"
    rename_column "relationship_types", "right_template_id", "right_structure_template_id"
    add_column "relationship_types", "left_template_id", :integer
    add_column "relationship_types", "right_template_id", :integer
    
    RelationshipType.reset_column_information

    RelationshipType.all.each do |rt|
      say "Converting references on relationship type \"#{rt.left_description}\" (#{rt.inspect})"
      rt.left_template_id = doc_template_ids[rt.left_structure_template_id]
      rt.right_template_id = doc_template_ids[rt.right_structure_template_id]
      rt.save!
    end

    remove_column "relationship_types", "left_structure_template_id"
    remove_column "relationship_types", "right_structure_template_id"

    MappedStructureTemplate.all.each do |mst|
      MappedDocTemplate.create(
        :doc_template_id => doc_template_ids[mst.structure_template_id],
        :map_id => mst.map_id,
        :color => mst.color
      )
    end

    docv2_ids = {}
    Structure.all.each do |structure|
      say "Creating DocV2 for #{structure.name}"

      docv2 = DocV2.create(
        :name => structure.name,
        :project => structure.project,
        :doc_template_id => doc_template_ids[structure.structure_template_id],
        :position => structure.position,
        :blurb => structure.blurb
        )
      docv2_ids[structure.id] = docv2.id
      docv1s = []
      structure.attr_value_metadatas.each do |avm|
        if avm.attr && avm.value
          case avm.value
          when DocValue
            docv1s << avm.value.doc unless avm.value.doc.nil?
          when ChoiceValue
            new_value = avm.value.value
            if new_value.kind_of? Array
              new_value = new_value.join("|")
            end
            a = docv2.obtain_attr(avm.attr.name)
            a.attributes = {
              :position => avm.attr.position,
              :value => new_value
            }
          else
            a = docv2.obtain_attr(avm.attr.name)
            a.attributes = {
              :position => avm.attr.position,
              :value => avm.value.value
            }
          end
        end
      end

      if docv1s.length == 1
        say "#{structure.name} contains a single doc; using that doc for the content"
        attr_name = docv1s.first.doc_value.attr.name
        docv2.attrs.delete(attr_name)
        template_attr = docv2.doc_template.doc_template_attrs.find_by_name(attr_name)
        template_attr.destroy unless template_attr.nil?

        docv1s.first.versions.all(:order => "version").each do |version|
          docv2.version += 1

          docv2.versions.create(
            :name => docv2.name,
            :doc_template_id => docv2.doc_template_id,
            :author_id => version.author_id,
            :content => version.content,
            :version => docv2.version,
            :created_at => version.created_at,
            :updated_at => version.updated_at
          )
        end
      elsif docv1s.length > 1
        say "#{structure.name} contains #{docv1s.length} docs; interleaving docs as attr versions"

        docv1_versions = docv1s.collect {|d| d.versions}.flatten
        docv1_versions.sort_by {|v| v.updated_at}.each do |version|
          attr = docv2.obtain_attr(version.doc_v1.doc_value.attr.name)
          attr.format = "html"
          attr.value = version.content
          docv2.save!

          docv2_version = docv2.versions.latest
          docv2_version.updated_at = version.updated_at
          docv2_version.created_at = version.created_at
          docv2_version.author_id = version.author_id
          docv2_version.save!
        end
      end

      # propagate versioned columns back
      %w{name doc_template_id content}.each do |k|
        docv2.send("#{k}=", docv2.current_version.send(k))
      end
      docv2.creator_id = docv2.versions.first.author_id
      docv2.save!
    end

    rename_column "relationships", "left_id", "left_structure_id"
    rename_column "relationships", "right_id", "right_structure_id"
    add_column "relationships", "left_id", :integer
    add_column "relationships", "right_id", :integer

    Relationship.reset_column_information

    Relationship.all.each do |r|
      r.left_id = docv2_ids[r.left_structure_id]
      r.right_id = docv2_ids[r.right_structure_id]
      r.save!
    end
    
    remove_column "relationships", "left_structure_id"
    remove_column "relationships", "right_structure_id"

    drop_table :text_fields
    drop_table :number_fields
    drop_table :choice_fields
    drop_table :doc_fields
    drop_table :attrs
    drop_table :structure_templates

    drop_table :mapped_structure_templates

    drop_table :text_values
    drop_table :number_values
    drop_table :choice_values
    drop_table :doc_values
    drop_table :attr_value_metadatas
    drop_table :structures

    drop_table :doc_versions
    drop_table :docs

    say "Doing post-migration data dump..."
    File.open(File.join(RAILS_ROOT, "all-data-structures-v2.txt"), "w") do |file|
      Project.all(:order => "name").each do |project|
        file.puts "Project: #{project.name}"

        project.doc_templates.all(:order => "name").each do |tmpl|
          file.puts "  Template: #{tmpl.name}"

          tmpl.doc_template_attrs.all(:order => "position").each do |attr|
            file.puts "    Attr: #{attr.name} (#{attr.ui_type}) - #{attr.choices}"
          end

          tmpl.outward_relationship_types.all(:order => "left_description").each do |rt|
            file.puts "    Relationship type: #{rt.left_name}"
          end

          project.docs.all(:conditions => {:doc_template_id => tmpl.id}, :order => "position").each do |d|
            file.puts "    Doc: #{d.name}"
            d.doc_template.doc_template_attrs.all(:order => "position").each do |dta|
              a = d.attr(dta.name)
              file.puts "      #{dta.name}: #{a.try :value}"
            end
            file.puts "      Content: #{d.content}" unless d.content.blank?

            d.outward_relationships.all(:order => "left_description, docs_v2.name", :joins => [:relationship_type, :right]).each do |r|
              file.puts "      Relationship: #{r.relationship_type.left_description} #{r.right.name}"
            end
          end
        end

        project.maps.all(:order => "name").each do |map|
          file.puts "  Map: #{map.name}"
          map.mapped_doc_templates.all(:order => "name", :joins => :doc_template).each do |mdt|
            file.puts "    Includes #{mdt.doc_template.name} docs in #{mdt.color}"
          end
        end
      end
    end

    rename_table "docs_v2", "docs"
    rename_table "doc_versions_v2", "doc_versions"
    rename_table "attrs_v2", "attrs"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
