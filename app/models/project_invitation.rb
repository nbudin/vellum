class ProjectInvitation < ActiveRecord::Base
  class AlreadyConsumed < Exception
  end
  
  devise :trackable
  
  belongs_to :project
  belongs_to :project_membership
  belongs_to :inviter, class_name: "Person"
  
  validates :email, uniqueness: { scope: :project_id }
  validates :token, uniqueness: { scope: :project_id }
  validates :inviter, presence: true
  
  store :membership_attributes, accessors: [:author, :admin], coder: JSON
  
  scope :pending, -> { where("consumed_at is null or consumed_at > ?", Time.now) }
  
  before_validation(on: :create) do
    self.token ||= self.class.generate_token
  end
  
  after_create do
    ProjectInvitationMailer.invitation_created(self).deliver
  end
  
  def to_param
    token
  end
  
  def consumed?
    consumed_at && consumed_at < Time.now
  end
  
  def consume!(person=nil)
    raise AlreadyConsumed.new("This invitation has already been used") if consumed?
        
    transaction do
      if person
        self.project_membership = project.project_memberships.create!(membership_attributes.merge(person: person))
      end
      self.consumed_at = Time.now
      self.save!
    end
  end
  
  protected
  def self.generate_token
    loop do
      token = Devise.friendly_token
      existing = self.where(token: token).first
      break token unless existing
    end
  end
end
