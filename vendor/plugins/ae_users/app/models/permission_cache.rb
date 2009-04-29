class PermissionCache < ActiveRecord::Base
  belongs_to :person
  belongs_to :permissioned, :polymorphic => true
end