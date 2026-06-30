class AddGoogleDriveExportToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :google_drive_folder_url,  :string
    add_column :projects, :google_drive_exported_at,  :datetime
    add_column :projects, :google_drive_warnings,     :text
    add_column :projects, :google_drive_notified_at,  :datetime
  end
end
