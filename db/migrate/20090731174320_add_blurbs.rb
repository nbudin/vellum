class AddBlurbs < ActiveRecord::Migration
  def self.up
    add_column :projects, :blurb, :text
    add_column :structures, :blurb, :text
    add_column :structures, :position, :integer
    Project.all.each do |project|
      project.blurb ||= "Click here to write a description of this project."
      project.save
      project.structures.sort_by {|s| s.name.sort_normalize }.each_with_index do |structure, i|
        structure.position = i + 1
        structure.save
      end
    end
  end

  def self.down
    remove_column :structures, :position
    remove_column :structures, :blurb
    remove_column :projects, :blurb
  end
end
