class RemoveProjectFromDocs < ActiveRecord::Migration
  def self.up
    remove_column :docs, :project_id
  end

  def self.down
    add_column :docs, :project_id, :integer
  end
end
