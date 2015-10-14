class DropObsoleteTables < ActiveRecord::Migration
  def change
    %i(choice_values_choices choices documents open_id_authentication_settings workflow_steps).each do |table_name|
      drop_table(table_name) if table_exists?(table_name)
    end
  end
end
