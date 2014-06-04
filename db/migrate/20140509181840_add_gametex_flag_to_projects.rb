class AddGametexFlagToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :gametex_available, :boolean, :default => false
  end
end
