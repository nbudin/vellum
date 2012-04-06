class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  
  devise :cas_authenticatable, :trackable
  has_many :project_memberships
  
  # CAS authenticatable
  field :username, type: String, null: false, default: ""
  index :username, unique: true
  
  # Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  
  # Profile info
  field :email, type: String
  field :firstname, type: String
  field :lastname, type: String
  field :gender, type: String
  field :birthdate, type: Time
  
  # Authorization
  field :admin, type: Boolean
  
  
  def name
    "#{firstname} #{lastname}"
  end
  
  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :firstname
        self.firstname = value
      when :lastname
        self.lastname = value
      when :birthdate
        self.birthdate = value
      when :gender
        self.gender = value
      when :email
        self.email = value
      end
    end
  end
end
