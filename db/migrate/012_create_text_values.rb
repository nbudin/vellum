class CreateTextValues < ActiveRecord::Migration
  def self.up
    create_table :text_values do |t|
      t.column :value, :text
    end
  end

  def self.down
    drop_table :text_values
  end
end
