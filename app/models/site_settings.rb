class SiteSettings < ActiveRecord::Base
  acts_as_singleton
  
  belongs_to :admin, :class_name => "Person"
  
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
      self.admin = Person.find(m[1])
      save!
    end
  end
end
