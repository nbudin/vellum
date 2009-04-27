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
    Doc.create_versioned_table
  end

  def self.down
    Doc.drop_versioned_table
    drop_table :docs
  end
end
