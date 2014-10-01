# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140509181840) do

  create_table "attrs", :force => true do |t|
    t.integer "doc_version_id"
    t.string  "name",           :null => false
    t.string  "slug",           :null => false
    t.integer "position"
    t.text    "value"
  end

  add_index "attrs", ["doc_version_id", "slug"], :name => "index_attrs_v2_on_doc_version_id_and_slug", :unique => true

  create_table "auth_tickets", :force => true do |t|
    t.string   "secret"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
  end

  add_index "auth_tickets", ["secret"], :name => "index_auth_tickets_on_secret", :unique => true

  create_table "choice_values_choices", :id => false, :force => true do |t|
    t.integer "choice_id"
    t.integer "choice_value_id"
  end

  add_index "choice_values_choices", ["choice_id"], :name => "index_choice_values_choices_on_choice_id"
  add_index "choice_values_choices", ["choice_value_id"], :name => "index_choice_values_choices_on_choice_value_id"

  create_table "choices", :force => true do |t|
    t.string    "value"
    t.integer   "choice_field_id"
    t.integer   "position"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "choices", ["choice_field_id"], :name => "index_choices_on_choice_field_id"

  create_table "csv_exports", :force => true do |t|
    t.integer   "project_id"
    t.integer   "doc_template_id"
    t.string    "name"
    t.text      "attr_names"
    t.timestamp "created_at",      :null => false
    t.timestamp "updated_at",      :null => false
  end

  add_index "csv_exports", ["doc_template_id"], :name => "index_csv_exports_on_doc_template_id"
  add_index "csv_exports", ["project_id"], :name => "index_csv_exports_on_project_id"

  create_table "doc_template_attrs", :force => true do |t|
    t.string  "name"
    t.integer "doc_template_id"
    t.integer "position"
    t.string  "ui_type",         :default => "text", :null => false
    t.text    "choices"
  end

  add_index "doc_template_attrs", ["doc_template_id", "name"], :name => "index_doc_template_attrs_on_doc_template_id_and_name", :unique => true

  create_table "doc_templates", :force => true do |t|
    t.string  "name"
    t.integer "project_id"
  end

  add_index "doc_templates", ["project_id"], :name => "index_doc_templates_on_project_id"

  create_table "doc_versions", :force => true do |t|
    t.integer   "doc_id"
    t.string    "name"
    t.integer   "doc_template_id"
    t.text      "content"
    t.integer   "author_id"
    t.integer   "version"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "doc_versions", ["doc_id"], :name => "index_doc_versions_v2_on_doc_id"

  create_table "docs", :force => true do |t|
    t.string    "name"
    t.integer   "project_id"
    t.integer   "doc_template_id"
    t.integer   "position"
    t.text      "blurb"
    t.text      "content"
    t.integer   "assignee_id"
    t.integer   "creator_id"
    t.integer   "version",         :default => 1
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "docs", ["project_id"], :name => "index_docs_v2_on_project_id"

  create_table "documents", :force => true do |t|
    t.text      "title"
    t.text      "content"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "structure_template_id"
    t.integer   "version"
    t.integer   "project_id"
  end

  create_table "mapped_doc_templates", :force => true do |t|
    t.integer   "map_id"
    t.integer   "doc_template_id"
    t.string    "color"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "mapped_doc_templates", ["map_id", "doc_template_id"], :name => "index_mapped_doc_templates_on_map_id_and_doc_template_id", :unique => true

  create_table "mapped_relationship_types", :force => true do |t|
    t.integer   "map_id"
    t.integer   "relationship_type_id"
    t.string    "color"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "maps", :force => true do |t|
    t.string    "name"
    t.text      "blurb"
    t.integer   "project_id"
    t.string    "graphviz_method"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "open_id_authentication_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "people", :force => true do |t|
    t.string    "email"
    t.string    "firstname"
    t.string    "lastname"
    t.string    "gender"
    t.timestamp "birthdate"
    t.boolean   "admin"
    t.string    "username"
    t.integer   "sign_in_count",      :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "people", ["username"], :name => "index_people_on_username", :unique => true

  create_table "permission_caches", :force => true do |t|
    t.integer "person_id"
    t.integer "permissioned_id"
    t.string  "permissioned_type"
    t.string  "permission_name"
    t.boolean "result"
  end

  add_index "permission_caches", ["permission_name"], :name => "index_permission_caches_on_permission_name"
  add_index "permission_caches", ["permissioned_id", "permissioned_type"], :name => "perm_id_type_key"
  add_index "permission_caches", ["person_id"], :name => "index_permission_caches_on_person_id"

  create_table "permissions", :force => true do |t|
    t.integer "role_id"
    t.integer "person_id"
    t.string  "permission"
    t.integer "permissioned_id"
    t.string  "permissioned_type"
  end

  create_table "project_memberships", :force => true do |t|
    t.integer "project_id"
    t.integer "person_id"
    t.boolean "author"
    t.boolean "admin"
  end

  create_table "projects", :force => true do |t|
    t.string  "name"
    t.text    "blurb"
    t.string  "public_visibility", :default => "hidden", :null => false
    t.boolean "gametex_available", :default => false
  end

  add_index "projects", ["public_visibility"], :name => "index_projects_on_public_visibility"

  create_table "publication_templates", :force => true do |t|
    t.integer   "project_id"
    t.string    "name"
    t.string    "format"
    t.text      "content"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "doc_template_id"
  end

  create_table "relationship_types", :force => true do |t|
    t.string  "name"
    t.string  "left_description"
    t.string  "right_description"
    t.integer "project_id"
    t.integer "left_template_id"
    t.integer "right_template_id"
  end

  add_index "relationship_types", ["project_id"], :name => "index_relationship_types_on_project_id"

  create_table "relationships", :force => true do |t|
    t.integer "relationship_type_id"
    t.integer "project_id"
    t.integer "left_id"
    t.integer "right_id"
  end

  create_table "site_settings", :force => true do |t|
    t.string    "site_name"
    t.string    "site_color"
    t.integer   "admin_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "site_email"
    t.text      "welcome_html"
  end

  create_table "workflow_steps", :force => true do |t|
    t.string    "name"
    t.integer   "position"
    t.integer   "workflow_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "workflow_steps", ["workflow_id"], :name => "index_workflow_steps_on_workflow_id"

end
