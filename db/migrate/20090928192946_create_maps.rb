class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.string :name
      t.text :blurb
      t.integer :project_id
      t.string :graphviz_method
      t.timestamps
    end
  end

  def self.down
    drop_table :maps
  end
end
