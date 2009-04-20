class CreateDocValues < ActiveRecord::Migration
  def self.up
    create_table :doc_values do |t|
      t.integer :doc_id

      t.timestamps
    end
  end

  def self.down
    drop_table :doc_values
  end
end
