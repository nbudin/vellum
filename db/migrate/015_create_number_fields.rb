class CreateNumberFields < ActiveRecord::Migration
  def self.up
    create_table :number_fields do |t|
      t.float :default

      t.timestamps
    end
  end

  def self.down
    drop_table :number_fields
  end
end
