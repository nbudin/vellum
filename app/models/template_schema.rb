class TemplateSchema < ActiveRecord::Base
  has_many :projects
  has_many :templates, :dependent => destroy
end
