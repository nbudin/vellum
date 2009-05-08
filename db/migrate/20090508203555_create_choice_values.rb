class CreateChoiceValues < ActiveRecord::Migration
  def self.up
    create_table :choice_values do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :choice_values
  end
end
