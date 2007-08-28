class Attr < ActiveRecord::Base
  belongs_to :template
  acts_as_list :scope => :template
  belongs_to :attr_configuration, :polymorphic => true, :dependent => :destroy
  has_many :attr_value_metadatas

  validates_uniqueness_of :name, :scope => :template_id
end
