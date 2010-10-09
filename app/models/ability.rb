class Ability
  include CanCan::Ability
  
  def initialize(person)
    return if person.nil?

    can :create, Project
    
    if person.admin?
      can [:read, :update, :destroy, :change_permissions], Project
    else
      can(:read, Project) { |project| find_membership(person, project) }
      can(:update, Project) { |project| find_membership(person, project).try(:author?) }
      can([:destroy, :change_permissions], Project) { |project| find_membership(person, project).try(:admin?) }
    end
  end
  
  protected
  def find_membership(person, project)
    ProjectMembership.first(:conditions => {:project_id => project.id, :person_id => person.id})
  end
end