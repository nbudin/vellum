module Publication::Base
  def self.included(c)
    c.class_eval do
      belongs_to :project
    end
  end
end