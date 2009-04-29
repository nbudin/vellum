class Permission < ActiveRecord::Base
  belongs_to :role
  belongs_to :person
  belongs_to :permissioned, :polymorphic => true
  
  def object
    return permissioned
  end
  
  def grantee
    if not role.nil?
      return role
    else
      return person
    end
  end
  
  def cache_conds
    cond_sql = "permission_name = ?"
    cond_objs = [permission]
    if person
      cond_sql += " and person_id = ?"
      cond_objs += [person.id]
    end
    if permissioned
      cond_sql += " and permissioned_type = ? and permissioned_id = ?"
      cond_objs += [permissioned.class.name, permissioned.id]
    end
    return [cond_sql] + cond_objs
  end
  
  def caches
    if AeUsers.cache_permissions?
      PermissionCache.find(:all, :conditions => cache_conds)
    else
      []
    end
  end
  
  def destroy_caches
    if AeUsers.cache_permissions?
      PermissionCache.destroy_all(cache_conds)
    end
  end
end
