class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.column :title, :text
      t.column :content, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :template_id, :integer
      t.column :version, :integer
    end
    Document.create_versioned_table
  end

  def self.down
    Document.drop_versioned_table
    drop_table :documents
  end
end
