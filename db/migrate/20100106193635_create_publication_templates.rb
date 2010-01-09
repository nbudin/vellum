class CreatePublicationTemplates < ActiveRecord::Migration
  def self.up
    create_table :publication_templates do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_templates
  end
end
