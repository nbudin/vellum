class ProjectMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
  
  validates_presence_of :person, :project
  
  def email
    person.try(:email)
  end
  
  def email=(email)
    if email.blank?
      self.person = nil
      return
    end
    
    logger.debug "Trying to find person with email #{email}"
    self.person = Person.find_by_email(email)
    if email and self.person.nil?
      logger.debug "Not found, trying Illyan invite"
      begin
        invitee = IllyanClient::Person.new(:person => { :email => email })
        invitee.save
        logger.debug "Invite successful!  Got back #{invitee.inspect}"
        
        invitee = invitee.person
        self.person = Person.create(:email => email, :username => email, :firstname => invitee.firstname, 
          :lastname => invitee.lastname, :gender => invitee.gender, :birthdate => invitee.birthdate)
      rescue
        logger.error "Error during invite: #{$!}"
        errors.add_to_base("Error inviting new user #{email}: $!")
      end
    end
  end
end