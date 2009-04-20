class CreateDocFields < ActiveRecord::Migration
  def self.up
    create_table :doc_fields do |t|
      t.boolean :allow_linking

      t.timestamps
    end
  end

  def self.down
    Attr.destroy_all(:attr_configuration_type => 'DocField')
    drop_table :doc_fields
  end
end
