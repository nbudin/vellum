class SiteSettings < ActiveRecord::Base
  acts_as_singleton
  
  belongs_to :admin, :class_name => "Person"
  
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
end
