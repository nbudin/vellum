class Role < ActiveRecord::Base
  acts_as_permissioned :permission_names => ['edit']

  establish_connection :users
  has_and_belongs_to_many :people
  has_many :permissions, :dependent => :destroy
end
