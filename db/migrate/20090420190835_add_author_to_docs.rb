class AddAuthorToDocs < ActiveRecord::Migration
  def self.up
    add_column :docs, :author_id, :integer
    add_column :doc_versions, :author_id, :integer
  end

  def self.down
    remove_column :doc_versions, :author_id
    remove_column :docs, :author_id
  end
end
