require 'ae_users_migrator/import'

class CreatePeople < ActiveRecord::Migration
  class Permission < ActiveRecord::Base
    belongs_to :permissioned, :polymorphic => true
  end
  
  def self.up
    person_ids = Doc.all(:group => "creator_id").map(&:creator_id)
    person_ids += Doc.all(:group => "assignee_id").map(&:assignee_id)
    person_ids += Doc::Version.all(:group => "author_id").map(&:author_id)
    person_ids << SiteSettings.instance.admin_id
    person_ids += Permission.all(:group => "person_id").map(&:person_id)
    person_ids = person_ids.uniq.compact
    
    role_ids = Permission.all(:group => "role_id").map(&:role_id)
    role_ids = role_ids.uniq.compact
    
    if person_ids.count > 0 or role_ids.count > 0
      # preflight checks for person/role migration
      unless File.exist?("ae_users.json")
        raise "There are users to migrate, and ae_users.json does not exist.  Please use export_ae_users.rb to create it."
      end
      @@dumpfile = AeUsersMigrator::Import::Dumpfile.load(File.new("ae_users.json"))
      
      @@merged_person_ids = {}
      role_ids.each do |role_id|
        person_ids += @@dumpfile.roles[role_id].people.map(&:id)
      end
      person_ids = person_ids.uniq.compact
      
      errors = false
      person_ids.each do |person_id|
        person = @@dumpfile.people[person_id]
        if person.nil?
          say "Person ID #{person_id.inspect} not found in ae_users.json!  Dangling references may be left in database."
          errors = true
        end
        
        if person.primary_email_address.nil?
          say "Person ID #{person.id} (#{person.firstname} #{person.lastname}) has no primary email address!  Cannot create, so dangling references may be left in database."
          errors = true
        end
      end
      
      if errors
        raise "Aborting due to above problems.  Please fix them and try the migration again."
      end
    end
    
    create_table :people do |t|
      t.string :email
      t.string :firstname
      t.string :lastname
      t.string :gender
      t.timestamp :birthdate
    
      t.boolean :admin
    
      t.cas_authenticatable
      t.trackable
      t.timestamps
    end
    add_index :people, :username, :unique => true
  
    create_table :project_memberships do |t|
      t.references :project, :person
      t.boolean :author
      t.boolean :admin
    end
    
    if person_ids.count > 0 or role_ids.count > 0    
      say "Migrating #{person_ids.size} existing people from ae_users"
      
      person_ids.each do |person_id|
        person = @@dumpfile.people[person_id]
        
        merge_into = Person.find_by(username: person.primary_email_address.address)
        if merge_into.nil?
          pr = Person.new(:firstname => person.firstname, :lastname => person.lastname, 
            :email => person.primary_email_address.address, :gender => person.gender, :birthdate => person.birthdate,
            :username => person.primary_email_address.address)
          pr.id = person.id
          pr.save!
        else
          say "Person ID #{person.id} (#{person.firstname} #{person.lastname}) has an existing email address.  Merging into ID #{merge_into.id} (#{person.firstname} #{person.lastname})."
          @@merged_person_ids[person.id] = merge_into.id
        end
      end
      
      Permission.all(:conditions => "permission is null and permissioned_id is null").each do |perm|
        say "Found admin permission #{perm.inspect}"

        people_for_permission(perm).each do |person|
          say "Granting admin rights to #{person.name}"
          person.admin = true
          person.save!
        end
      end
      
      if SiteSettings.instance && SiteSettings.instance.admin_id
        admin_id = SiteSettings.instance.admin_id
        say "Found admin permission for person #{admin_id}"
        
        person = person_for_old_id(person_id)
        person.admin = true
        person.save!
      end
      
      @@merged_person_ids.each do |orig_id, new_id|
        execute "update docs set creator_id = #{new_id} where creator_id = #{orig_id}"
        execute "update docs set assignee_id = #{new_id} where assignee_id = #{orig_id}"
        execute "update doc_versions set author_id = #{new_id} where author_id = #{orig_id}"
      end
      
      project_memberships = {}
      Permission.all(:conditions => "permissioned_type = 'Project'", :include => :permissioned).each do |perm|
        next unless perm.permissioned and perm.person_id
        
        project = perm.permissioned
        person_id = map_person_id(perm.person_id)
        
        project_memberships[project] ||= {}
        project_memberships[project][person_id] ||= ProjectMembership.new(:person => Person.find(person_id),
          :project => project)
        
        m = project_memberships[project][person_id]
        m.author = true if perm.permission == "edit"
        m.admin = true if perm.permission == "change_permissions"
      end
      
      project_memberships.each do |project, memberships|
        memberships.each do |person_id, membership|
          say "Granting #{membership.person.name} membership on #{project.name}: #{membership.inspect}"
          membership.save
        end
      end
      
      drop_table :permissions
      drop_table :open_id_authentication_associations
      drop_table :open_id_authentication_nonces
      drop_table :auth_tickets
    end
  end
  
  def self.map_person_id(person_id)
    @@merged_person_ids[person_id] || person_id
  end
  
  def self.map_person_ids(person_ids)
    person_ids.collect do |person_id|
      map_person_id(person_id)
    end
  end
  
  def self.person_for_old_id(person_id)
    Person.find(map_person_id(person_id))
  end
  
  def self.people_for_permission(perm)
    if perm.person_id
      [person_for_old_id(perm.person_id)]
    elsif perm.role_id
      Person.find(map_person_ids(@@dumpfile.roles[perm.role_id].people.map(&:id)))
    else
      []
    end
  end

  def self.down
    drop_table :people
  end
end
