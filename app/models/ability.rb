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
      can(:read, Project, :public_visibility => "visible")
      can(:update, Project, :id => author_project_ids)
      can([:destroy, :change_permissions], Project, :id => admin_project_ids)
      
      project_contents = [Doc, DocTemplate, Map, PublicationTemplate, RelationshipType, Relationship]
      can(:read, project_contents, :project_id => read_project_ids)
      can(:read, project_contents, :project => {:public_visibility => "visible"})
      can(:manage, project_contents, :project_id => author_project_ids)
    end
  end
end