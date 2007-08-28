class AddRequiredAttrs < ActiveRecord::Migration
  def self.up
    add_column :attrs, :required, :boolean
  end

  def self.down
    remove_column :attrs, :required
  end
end
