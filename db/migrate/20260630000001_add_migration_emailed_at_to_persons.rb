class AddMigrationEmailedAtToPersons < ActiveRecord::Migration
  def change
    add_column :people, :migration_emailed_at, :datetime
  end
end
