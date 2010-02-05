class CreateDocumentsV2 < ActiveRecord::Migration
  class DocV1 < ActiveRecord::Base
    set_table_name "docs"
    version_fu

    has_one :doc_value
    validates_presence_of :doc_value
    belongs_to :author, :class_name => "Person"
  end

  class Project < ActiveRecord::Base
    has_many :structures
  end

  class DocV2 < ActiveRecord::Base
    set_table_name "docs_v2"

    version_fu :foreign_key => "doc_id", :table_name => "doc_versions_v2" do
      belongs_to :author, :class_name => "::Person"
      has_many :attrs, :class_name => "::CreateDocumentsV2::AttrV2", 
        :foreign_key => "doc_version_id", :autosave => true

      # we're going to be saving these manually in the migration
      self.record_timestamps = false
    end

    belongs_to :project
    belongs_to :doc_template
    belongs_to :creator, :class_name => "Person"
    belongs_to :assignee, :class_name => "Person"

    after_save :save_versions

    def current_version
      versions.select { |v| v.version == self.version }.first
    end

    def attrs
      current_version.attrs
    end

    def create_new_version?
      super || attrs.any? { |a| a.changed? }
    end

    def instantiate_revision
      super
      attrs.each do |a|
        new_a = a.clone
        new_a.doc_version = current_version
        current_version.attrs << new_a
      end
    end

    def save_versions
      versions.each do |v|
        v.save! if (v.changed? || v.attrs.any? { |a| a.changed? })
      end
    end
    
    def attr(name)
      attrs.select {|a| a.name == name}.first
    end

    def obtain_attr(name)
      a = attr(name)
      return a unless a.nil?
      
      attrs << attrs.build(:name => name)
      return attr(name)
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
  end

  class DocTemplateAttr < ActiveRecord::Base
    belongs_to :doc_template
  end

  def self.up
    create_table "doc_templates" do |t|
      t.string "name"
      t.integer "project_id"
    end

    add_index "doc_templates", "project_id"

    create_table "doc_template_attrs" do |t|
      t.string "name"
      t.integer "doc_template_id"
      t.integer "position"
      t.string "type"

      # only applies if it's a multiple-choice attr
      t.text "choices"
    end

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

    create_table "doc_versions_v2" do |t|
      t.integer "doc_id"
      t.string  "name"

      t.integer "doc_template_id"

      t.text "content"

      t.integer "author_id"
      t.integer "version"
      t.timestamps
    end

    create_table "attrs_v2" do |t|
      t.integer "doc_version_id"

      t.string "name", :null => false
      t.integer "position"

      t.string "format"
      t.text "value"
    end

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
          doc_attr.type = "textarea"
        when ChoiceField
          doc_attr.type = attr.attr_configuration.display_type
          doc_attr.choices = attr.attr_configuration.choices.collect { |c| c.value }.join("|")
        else
          doc_attr.type = "text"
        end

        doc_tmpl.doc_template_attrs << doc_attr
      end
      
      doc_tmpl.save!
    end

    Structure.all.each do |structure|
      say "Creating DocV2 for #{structure.name}"

      docv2 = DocV2.create(
        :name => structure.name,
        :project => structure.project,
        :doc_template_id => doc_template_ids[structure.structure_template_id],
        :position => structure.position,
        :blurb => structure.blurb
        )
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
            docv2.attrs << docv2.attrs.build(:name => avm.attr.name,
              :position => avm.attr.position,
              :value => new_value)
          else
            docv2.attrs << docv2.attrs.build(:name => avm.attr.name,
              :position => avm.attr.position,
              :value => avm.value.value)
          end
        end
      end

      if docv1s.length == 1
        say "#{structure.name} contains a single doc; using that doc for the content"
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
          attr = docv2.obtain_attr(version.doc.doc_value.attr.name)
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
  end

  def self.down
  end
end
