class Project < ActiveRecord::Base
  belongs_to :template_schema
  has_many :documents, :dependent => destroy
  has_many :structures, :dependent => destroy
end
