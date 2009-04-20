class DocField < ActiveRecord::Base
  include AttrField
  
  def self.value_class
    DocValue
  end
end
