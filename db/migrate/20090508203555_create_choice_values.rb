class CreateChoiceValues < ActiveRecord::Migration
  def self.up
    create_table :choice_values do |t|
      t.integer :choice_id
      t.string :value
      t.timestamps
    end

    create_table :choice_values_choices, :id => false do |t|
      t.integer :choice_id
      t.integer :choice_value_id
    end
  end

  def self.down
    drop_table :choice_values_choices
    drop_table :choice_values
  end
end
