class ConvertWelcomeDocToField < ActiveRecord::Migration
  class SiteSettings < ActiveRecord::Base
    acts_as_singleton

    belongs_to :welcome_doc, :class_name => "Doc"
  end

  def self.up
    add_column :site_settings, :welcome_html, :text

    settings = SiteSettings.instance
    if settings.welcome_doc
      settings.welcome_html = settings.welcome_doc.content

    end
    settings.save!

    settings.welcome_doc.destroy unless settings.welcome_doc.nil?
    remove_column :site_settings, :welcome_doc_id
  end

  def self.down
    add_column :site_settings, :welcome_doc_id, :integer

    settings = SiteSettings.instance
    doc = settings.build_welcome_doc
    doc.content = settings.welcome_html
    doc.save!
    settings.save!

    remove_column :site_settings, :welcome_html
  end
end
