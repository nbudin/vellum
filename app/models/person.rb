class Person < ActiveRecord::Base
  devise :cas_authenticatable, :trackable
  has_many :project_memberships
  
  def name
    "#{firstname} #{lastname}"
  end
end
