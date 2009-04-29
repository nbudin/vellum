class OpenIdIdentity < ActiveRecord::Base
  establish_connection :users
  belongs_to :person
  validates_uniqueness_of :identity_url
end