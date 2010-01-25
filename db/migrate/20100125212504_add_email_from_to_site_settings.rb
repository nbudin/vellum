class AddEmailFromToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column "site_settings", "site_email", :string
  end

  def self.down
    remove_column "site_settings", "site_email"
  end
end
