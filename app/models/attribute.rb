class Attribute < ActiveRecord::Base
  belongs_to :template
  acts_as_list :scope => :template
  belongs_to :attribute_configuration, :polymorphic => true, :dependent => :destroy
  has_many :attribute_value_metadatas
end
