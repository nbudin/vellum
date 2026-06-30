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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20260630000001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attrs", id: :bigserial, force: :cascade do |t|
    t.integer  "doc_version_id", limit: 8
    t.text     "name",                     null: false
    t.text     "slug",                     null: false
    t.integer  "position",       limit: 8
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attrs", ["doc_version_id", "slug"], name: "idx_18312_index_attrs_v2_on_doc_version_id_and_slug", unique: true, using: :btree

  create_table "csv_exports", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id",      limit: 8
    t.integer  "doc_template_id", limit: 8
    t.text     "name"
    t.text     "attr_names"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "csv_exports", ["doc_template_id"], name: "idx_18321_index_csv_exports_on_doc_template_id", using: :btree
  add_index "csv_exports", ["project_id"], name: "idx_18321_index_csv_exports_on_project_id", using: :btree

  create_table "doc_template_attrs", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.integer  "doc_template_id", limit: 8
    t.integer  "position",        limit: 8
    t.text     "ui_type",                   default: "text", null: false
    t.text     "choices"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_template_attrs", ["doc_template_id", "name"], name: "idx_18349_index_doc_template_attrs_on_doc_template_id_and_name", unique: true, using: :btree

  create_table "doc_templates", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.integer  "project_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_templates", ["project_id"], name: "idx_18340_index_doc_templates_on_project_id", using: :btree

  create_table "doc_versions", id: :bigserial, force: :cascade do |t|
    t.integer  "doc_id",          limit: 8
    t.text     "name"
    t.integer  "doc_template_id", limit: 8
    t.text     "content"
    t.integer  "author_id",       limit: 8
    t.integer  "version",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_versions", ["doc_id"], name: "idx_18359_index_doc_versions_v2_on_doc_id", using: :btree

  create_table "docs", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.integer  "project_id",      limit: 8
    t.integer  "doc_template_id", limit: 8
    t.integer  "position",        limit: 8
    t.text     "blurb"
    t.text     "content"
    t.integer  "assignee_id",     limit: 8
    t.integer  "creator_id",      limit: 8
    t.integer  "version",         limit: 8, default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "docs", ["project_id"], name: "idx_18330_index_docs_v2_on_project_id", using: :btree

  create_table "mapped_doc_templates", id: :bigserial, force: :cascade do |t|
    t.integer  "map_id",          limit: 8
    t.integer  "doc_template_id", limit: 8
    t.text     "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mapped_doc_templates", ["map_id", "doc_template_id"], name: "idx_18368_index_mapped_doc_templates_on_map_id_and_doc_template", unique: true, using: :btree

  create_table "mapped_relationship_types", id: :bigserial, force: :cascade do |t|
    t.integer  "map_id",               limit: 8
    t.integer  "relationship_type_id", limit: 8
    t.text     "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.text     "blurb"
    t.integer  "project_id",      limit: 8
    t.text     "graphviz_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", id: :bigserial, force: :cascade do |t|
    t.text     "email"
    t.text     "firstname"
    t.text     "lastname"
    t.text     "gender"
    t.datetime "birthdate"
    t.boolean  "admin"
    t.text     "username"
    t.integer  "sign_in_count",        limit: 8, default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "migration_emailed_at"
  end

  add_index "people", ["username"], name: "idx_18395_index_people_on_username", unique: true, using: :btree

  create_table "project_memberships", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id", limit: 8
    t.integer  "person_id",  limit: 8
    t.boolean  "author"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.text     "blurb"
    t.text     "public_visibility",        default: "hidden", null: false
    t.boolean  "gametex_available",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "google_drive_folder_url"
    t.datetime "google_drive_exported_at"
    t.text     "google_drive_warnings"
    t.datetime "google_drive_notified_at"
  end

  add_index "projects", ["public_visibility"], name: "idx_18405_index_projects_on_public_visibility", using: :btree

  create_table "publication_templates", id: :bigserial, force: :cascade do |t|
    t.integer  "project_id",      limit: 8
    t.text     "name"
    t.text     "format"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_template_id", limit: 8
    t.integer  "layout_id",       limit: 8
    t.text     "template_type",             default: "standalone"
  end

  create_table "relationship_types", id: :bigserial, force: :cascade do |t|
    t.text     "name"
    t.text     "left_description"
    t.text     "right_description"
    t.integer  "project_id",        limit: 8
    t.integer  "left_template_id",  limit: 8
    t.integer  "right_template_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationship_types", ["project_id"], name: "idx_18438_index_relationship_types_on_project_id", using: :btree

  create_table "relationships", id: :bigserial, force: :cascade do |t|
    t.integer  "relationship_type_id", limit: 8
    t.integer  "project_id",           limit: 8
    t.integer  "left_id",              limit: 8
    t.integer  "right_id",             limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_settings", id: :bigserial, force: :cascade do |t|
    t.text     "site_name"
    t.text     "site_color"
    t.integer  "admin_id",     limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "site_email"
    t.text     "welcome_html"
  end

end
