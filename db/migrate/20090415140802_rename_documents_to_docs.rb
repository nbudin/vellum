class RenameDocumentsToDocs < ActiveRecord::Migration
  def self.up
    rename_table :documents, :docs
    rename_table :document_versions, :doc_versions
    rename_column :doc_versions, :document_id, :doc_id
  end

  def self.down
    rename_column :doc_versions, :doc_id, :document_id
    rename_table :doc_versions, :document_versions
    rename_table :docs, :documents
  end
end
