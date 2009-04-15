class CreateTextFields < ActiveRecord::Migration
  def self.up
    create_table :text_fields do |t|
      t.column :default, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :text_fields
  end
end
