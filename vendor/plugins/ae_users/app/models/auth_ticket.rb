require 'digest/sha1'

class AuthTicket < ActiveRecord::Base
  belongs_to :person
  validates_uniqueness_of :secret
  
  before_save do |record|
    record.secret
  end
  
  def self.find_ticket(secret)
    AuthTicket.find(:first, :conditions => ["secret = ? and (expires_at is null or expires_at > current_timestamp())", secret])
  end
  
  def generate_secret
    secret = nil
    while secret.nil?
      hashseed = "#{id}_#{Time.new.to_i}_#{rand}"
      secret = Digest::SHA1.hexdigest(hashseed)
      if AuthTicket.find_by_secret(secret)
        secret = nil
      end
    end
    self.secret = secret
    return secret
  end
  
  def secret
    if read_attribute(:secret).nil?
      generate_secret
    else
      read_attribute(:secret)
    end
  end
  
  def expired?
    expires_at and expires_at <= Time.new
  end
end