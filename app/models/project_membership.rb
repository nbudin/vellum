class ProjectMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
  
  validates_presence_of :person, :project
  
  def email
    person.try(:email)
  end
  
  def email=(email)
    self.person = Person.find_by_email(email)
    if email and self.person.nil?
      errors.add_to_base("Can't find an existing user with the email address #{email}.")
    end
  end
end