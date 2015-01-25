class AddLayoutsToPublicationTemplates < ActiveRecord::Migration
  def change
    change_table :publication_templates do |t|
      t.references :layout, index: true
    end
  end
end
