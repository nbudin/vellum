class Choice < ActiveRecord::Base
  belongs_to :choice_field
  acts_as_list :scope => :choice_field_id
  validates_uniqueness_of :value, :scope => :choice_field_id
end
