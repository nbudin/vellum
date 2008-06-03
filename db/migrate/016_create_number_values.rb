class CreateNumberValues < ActiveRecord::Migration
  def self.up
    create_table :number_values do |t|
      t.float :value

      t.timestamps
    end
  end

  def self.down
    drop_table :number_values
  end
end
