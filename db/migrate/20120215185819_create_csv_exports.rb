class CreateCsvExports < ActiveRecord::Migration
  def change
    create_table :csv_exports do |t|
      t.references :project
      t.references :doc_template
      t.string :name
      t.text :attr_names

      t.timestamps
    end
    
    add_index :csv_exports, :project_id
    add_index :csv_exports, :doc_template_id
  end
end
