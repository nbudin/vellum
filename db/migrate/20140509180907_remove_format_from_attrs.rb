class RemoveFormatFromAttrs < ActiveRecord::Migration
  def up
    remove_column :attrs, :format
  end

  def down
    add_column :attrs, :format, :string
  end
end
