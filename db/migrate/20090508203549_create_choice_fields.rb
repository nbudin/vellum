class CreateChoiceFields < ActiveRecord::Migration
  def self.up
    create_table :choice_fields do |t|
      t.integer :default_choice_id
      t.string :display_type
      t.boolean :multiple
      t.timestamps
    end
  end

  def self.down
    drop_table :choice_fields
  end
end
