class Ability
  include CanCan::Ability
  
  def initialize(person)
    return if person.nil?

    can :create, Project
    project_contents = [Doc, DocTemplate, Map, PublicationTemplate, RelationshipType, Relationship]
    map_contents = [MappedDocTemplate, MappedRelationshipType]
    
    if person.admin?
      can [:read, :update, :destroy, :change_permissions, :copy_templates], Project
      can :manage, project_contents
      can :manage, map_contents
    else
      memberships = person.project_memberships
      read_project_ids = memberships.map(&:project_id)
      author_project_ids = memberships.select(&:author?).map(&:project_id)
      admin_project_ids = memberships.select(&:admin?).map(&:project_id)
      
      can([:read, :copy_templates], Project, :id => read_project_ids)
      can(:read, Project, :public_visibility => "visible")
      can(:copy_templates, Project, :public_visibility => "copy_templates")
      can(:update, Project, :id => author_project_ids)
      can([:destroy, :change_permissions], Project, :id => admin_project_ids)
      
      can(:read, project_contents, :project_id => read_project_ids)
      can(:read, project_contents, :project => {:public_visibility => "visible"})
      can(:manage, project_contents, :project_id => author_project_ids)
      
      can(:read, map_contents, :map => { :project_id => read_project_ids })
      can(:read, map_contents, :map => { :project => {:public_visibility => "visible"} })
      can(:manage, map_contents, :map => { :project_id => author_project_ids })
    end
  end
end