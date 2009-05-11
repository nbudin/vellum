class CreateChoices < ActiveRecord::Migration
  def self.up
    create_table :choices do |t|
      t.string :value
      t.integer :choice_field_id
      t.integer :position
      t.timestamps
    end
    add_index :choices, :choice_field_id
  end

  def self.down
    drop_table :choices
  end
end
