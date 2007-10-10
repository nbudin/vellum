class TemplateSchema < ActiveRecord::Base
  has_many :projects
  has_many :structure_templates, :dependent => :destroy
  has_many :relationship_types, :dependent => :destroy
end
