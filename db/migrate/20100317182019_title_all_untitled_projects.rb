class TitleAllUntitledProjects < ActiveRecord::Migration
  def self.up
    DocTemplate.all.each do |t|
      next unless t.name.blank?

      say "Saving a name for doc template #{t.id}"
      t.name = "Untitled template #{t.id}"
      t.save!
    end

    Project.all.each do |p|
      next unless p.name.blank?

      say "Saving a name for project #{p.id}"
      p.name = "Untitled project"
      p.save!
    end
  end

  def self.down
  end
end
