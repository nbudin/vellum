class TitleAllUntitledProjects < ActiveRecord::Migration
  def self.up
    Project.all.each do |p|
      next unless p.name.blank?
      p.name = "Untitled project"
      p.save!
    end

    DocTemplate.all.each do |t|
      next unless t.name.blank?
      t.name = "Untitled template #{t.id}"
      t.save!
    end
  end

  def self.down
  end
end
