class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :docs do |t|
      t.column :title, :text
      t.column :content, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :structure_template_id, :integer
      t.column :version, :integer
    end

    create_table :doc_versions do |t|
      t.column :doc_id, :integer
      t.column :title, :text
      t.column :content, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :structure_template_id, :integer
      t.column :version, :integer
    end
  end

  def self.down
    drop_table :doc_versions
    drop_table :docs
  end
end
