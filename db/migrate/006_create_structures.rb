class CreateStructures < ActiveRecord::Migration
  def self.up
    create_table :structures do |t|
      t.column :template_id, :integer
    end
  end

  def self.down
    drop_table :structures
  end
end
