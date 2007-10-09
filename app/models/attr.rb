class Attr < ActiveRecord::Base
  belongs_to :structure_template
  acts_as_list :scope => :structure_template
  belongs_to :attr_configuration, :polymorphic => true, :dependent => :destroy
  has_many :attr_value_metadatas

  validates_uniqueness_of :name, :scope => :structure_template_id
end
