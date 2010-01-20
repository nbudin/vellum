class CreatePublicationHTMLs < ActiveRecord::Migration
  def self.up
    create_table :publication_htmls do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_htmls
  end
end
