class CreateChoiceFields < ActiveRecord::Migration
  def self.up
    create_table :choice_fields do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :choice_fields
  end
end
