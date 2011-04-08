class AddPublicOptionsToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "public_visibility", :string, :null => false, :default => "hidden"
    add_index "projects", "public_visibility"
  end

  def self.down
    remove_column "projects", "public_visibility"
  end
end
