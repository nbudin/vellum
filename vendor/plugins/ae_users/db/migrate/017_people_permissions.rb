class PeoplePermissions < ActiveRecord::Migration
  def self.up
    add_column "permissions", "person_id", :integer
  end

  def self.down
    remove_column "permissions", "person_id"
  end
end