class Ability
  include CanCan::Ability

  attr_reader :person

  PROJECT_CONTENTS = [Doc, DocTemplate, CsvExport, Map, PublicationTemplate, RelationshipType, Relationship]
  DOC_CONTENTS = [Doc::Version]
  MAP_CONTENTS = [MappedDocTemplate, MappedRelationshipType]

  def initialize(person)
    @person = person
    return unless person

    can :create, Project

    if person.admin?
      grant_admin_permissions
    else
      grant_non_admin_permissions
    end
  end

  private

  def grant_admin_permissions
    can [:read, :update, :destroy, :change_permissions, :copy_templates], Project
    can :manage, PROJECT_CONTENTS + MAP_CONTENTS + [SiteSettings]
  end

  def grant_non_admin_permissions
    can([:read, :copy_templates], Project, :id => read_project_ids)
    can(:read, Project, :public_visibility => "visible")
    can(:copy_templates, Project, :public_visibility => "copy_templates")
    can(:update, Project, :id => author_project_ids)
    can([:destroy, :change_permissions], Project, :id => admin_project_ids)

    can(:read, PROJECT_CONTENTS, :project_id => read_project_ids)
    can(:read, PROJECT_CONTENTS, :project => {:public_visibility => "visible"})
    can(:manage, PROJECT_CONTENTS, :project_id => author_project_ids)

    can([:test, :publish], PublicationTemplate, :project_id => read_project_ids)
    can([:test, :publish], PublicationTemplate, :project => {:public_visibility => "visible"})

    can(:read, MAP_CONTENTS, :map => { :project_id => read_project_ids })
    can(:read, MAP_CONTENTS, :map => { :project => {:public_visibility => "visible"} })
    can(:manage, MAP_CONTENTS, :map => { :project_id => author_project_ids })

    can(:read, DOC_CONTENTS, :doc => { :project_id => read_project_ids })
    can(:read, DOC_CONTENTS, :doc => { :project => {:public_visibility => "visible"} })
    can(:manage, DOC_CONTENTS, :doc => { :project_id => author_project_ids })
  end

  def memberships
    @memberships ||= person.project_memberships
  end

  def read_project_ids
    @read_project_ids ||= memberships.map(&:project_id)
  end

  def author_project_ids
    @author_project_ids ||= memberships.select(&:author?).map(&:project_id)
  end

  def admin_project_ids
    @admin_project_ids ||= memberships.select(&:admin?).map(&:project_id)
  end
end