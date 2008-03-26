class Project < ActiveRecord::Base
  belongs_to :template_schema
  has_many :documents, :dependent => :destroy
  has_many :structures, :dependent => :destroy
  
  acts_as_permissioned :permission_names => [:view, :edit]
end
