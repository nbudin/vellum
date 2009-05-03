class CreateSiteSettings < ActiveRecord::Migration
  def self.up
    create_table :site_settings do |t|
      t.string :site_name
      t.string :site_color
      t.integer :welcome_doc_id
      t.integer :admin_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_settings
  end
end
