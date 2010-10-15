class SanitizeExistingDocs < ActiveRecord::Migration

  def self.up
    transaction do
      docs = Doc.all
      
      docs.each_with_index do |doc, i|
        say "Sanitizing #{doc.name} (finished #{i} of #{docs.size} docs)" if (i % 10) == 0
        
        doc.content = sanitize(doc.content) if doc.content
        doc.attrs.each do |attr|
          attr.value = sanitize(attr.value) if attr.value
        end
        doc.save!
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
  
  protected
  def self.sanitize(content)
    Sanitize.clean(content, Sanitize::Config::VELLUM)
  end
end
