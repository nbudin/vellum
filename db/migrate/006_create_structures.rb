class CreateStructures < ActiveRecord::Migration
  def self.up
    create_table :structures do |t|
      t.column :structure_template_id, :integer
      t.column :name, :string
      t.column :assignee_id, :integer
    end
  end

  def self.down
    drop_table :structures
  end
end
