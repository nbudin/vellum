namespace :google_drive do
  desc <<~DESC
    Export Vellum projects to Google Drive.

    Required setup (recommended — gcloud user credentials):
      1. Install gcloud: https://cloud.google.com/sdk/docs/install
      2. Run: gcloud auth application-default login \
                --scopes=https://www.googleapis.com/auth/drive
      3. Set GOOGLE_APPLICATION_CREDENTIALS to the path printed by that command
         (typically ~/.config/gcloud/application_default_credentials.json).
         Files will be created in your own Google Drive.

    Alternative setup (service account + Shared Drive):
      1. Create a Google Cloud project and enable the Google Drive API.
      2. Create a service account, download its JSON key.
      3. Create a Shared Drive and add the service account as a Content Manager.
         (Service accounts have no personal storage quota.)
      4. Use the Shared Drive or a folder inside it as GOOGLE_DRIVE_PARENT_FOLDER_ID.

    Environment variables:
      GOOGLE_APPLICATION_CREDENTIALS   Path to service account JSON key (required)
      GOOGLE_DRIVE_PARENT_FOLDER_ID    Drive folder ID to export into (recommended)
      PROJECT_ID                       Export only this project ID (exports all if omitted)

    Examples:
      GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \\
      GOOGLE_DRIVE_PARENT_FOLDER_ID=1AbCdEfGhIjKlMnOpQ \\
      bundle exec rake google_drive:export

      PROJECT_ID=42 \\
      GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \\
      bundle exec rake google_drive:export
  DESC
  task export: :environment do
    creds_path = ENV['GOOGLE_APPLICATION_CREDENTIALS'].presence
    abort "Set GOOGLE_APPLICATION_CREDENTIALS to the path of your service account JSON key." unless creds_path
    abort "File not found: #{creds_path}" unless File.exist?(creds_path)

    parent_folder_id = ENV['GOOGLE_DRIVE_PARENT_FOLDER_ID'].presence

    projects = if ENV['PROJECT_ID'].present?
      [Project.find(ENV['PROJECT_ID'])]
    else
      Project.order(:name).to_a
    end

    puts "Authenticating with Google Drive..."
    exporter = GoogleDriveExporter.new(creds_path)

    puts "Exporting #{projects.size} project(s)...\n\n"

    projects.each do |project|
      puts "=== #{project.name} ==="
      result = exporter.export_project(project, parent_folder_id: parent_folder_id)
      puts "  Folder URL: #{result[:folder_url]}\n\n"
    end

    puts "Done."
  end
end
