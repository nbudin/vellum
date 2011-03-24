class Ability
  include CanCan::Ability
  
  def initialize(person)
    return if person.nil?

    can :create, Project
    
    if person.admin?
      can [:read, :update, :destroy, :change_permissions], Project
      can :manage, Doc
    else
      memberships = person.project_memberships
      read_project_ids = memberships.map(&:project_id)
      author_project_ids = memberships.select(&:author?).map(&:project_id)
      admin_project_ids = memberships.select(&:admin?).map(&:project_id)
      
      can(:read, Project, :id => read_project_ids)
      can(:update, Project, :id => author_project_ids)
      can([:destroy, :change_permissions], Project, :id => admin_project_ids)
      
      can(:read, Doc, :project_id => read_project_ids)
      can(:manage, Doc, :project_id => author_project_ids)
    end
  end
end