class SiteSettings < ActiveRecord::Base
  acts_as_singleton
  
  belongs_to :admin, :class_name => "Person"
  belongs_to :welcome_doc, :class_name => "Doc"
  
  def is_admin?(person)
    person and person.permitted?(SiteSettings, "admin")
  end
  
  def site_name
    sn = read_attribute(:site_name) 
    if sn.blank?
      "Vellum"
    else
      sn
    end
  end
  
  def site_color
    sc = read_attribute(:site_color)
    if sc.blank?
      "\#ff8"
    else
      sc
    end
  end
  
  def admin_kid=(kid)
    m = kid.match(/^Person:(\d+)/)
    if m
      admin = Person.find(m[1])
      save!
    end
  end
  
  def welcome_doc_content
    if welcome_doc.nil?
      return nil
    else
      return welcome_doc.content
    end
  end
  
  def welcome_doc_content=(content)
    if content.blank?
      if welcome_doc
        welcome_doc.destroy
      end
    else
      if not welcome_doc
        build_welcome_doc
      end
      welcome_doc.content = content
      welcome_doc.save
    end
  end
end
