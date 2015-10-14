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

ActiveRecord::Schema.define(version: 20151014134025) do

  create_table "attrs", force: :cascade do |t|
    t.integer  "doc_version_id", limit: 4
    t.string   "name",           limit: 255,   null: false
    t.string   "slug",           limit: 255,   null: false
    t.integer  "position",       limit: 4
    t.text     "value",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attrs", ["doc_version_id", "slug"], name: "index_attrs_v2_on_doc_version_id_and_slug", unique: true, using: :btree

  create_table "csv_exports", force: :cascade do |t|
    t.integer  "project_id",      limit: 4
    t.integer  "doc_template_id", limit: 4
    t.string   "name",            limit: 255
    t.text     "attr_names",      limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "csv_exports", ["doc_template_id"], name: "index_csv_exports_on_doc_template_id", using: :btree
  add_index "csv_exports", ["project_id"], name: "index_csv_exports_on_project_id", using: :btree

  create_table "doc_template_attrs", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "doc_template_id", limit: 4
    t.integer  "position",        limit: 4
    t.string   "ui_type",         limit: 255,   default: "text", null: false
    t.text     "choices",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_template_attrs", ["doc_template_id", "name"], name: "index_doc_template_attrs_on_doc_template_id_and_name", unique: true, using: :btree

  create_table "doc_templates", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_templates", ["project_id"], name: "index_doc_templates_on_project_id", using: :btree

  create_table "doc_versions", force: :cascade do |t|
    t.integer  "doc_id",          limit: 4
    t.string   "name",            limit: 255
    t.integer  "doc_template_id", limit: 4
    t.text     "content",         limit: 16777215
    t.integer  "author_id",       limit: 4
    t.integer  "version",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "doc_versions", ["doc_id"], name: "index_doc_versions_v2_on_doc_id", using: :btree

  create_table "docs", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "project_id",      limit: 4
    t.integer  "doc_template_id", limit: 4
    t.integer  "position",        limit: 4
    t.text     "blurb",           limit: 65535
    t.text     "content",         limit: 16777215
    t.integer  "assignee_id",     limit: 4
    t.integer  "creator_id",      limit: 4
    t.integer  "version",         limit: 4,        default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "docs", ["project_id"], name: "index_docs_v2_on_project_id", using: :btree

  create_table "mapped_doc_templates", force: :cascade do |t|
    t.integer  "map_id",          limit: 4
    t.integer  "doc_template_id", limit: 4
    t.string   "color",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mapped_doc_templates", ["map_id", "doc_template_id"], name: "index_mapped_doc_templates_on_map_id_and_doc_template_id", unique: true, using: :btree

  create_table "mapped_relationship_types", force: :cascade do |t|
    t.integer  "map_id",               limit: 4
    t.integer  "relationship_type_id", limit: 4
    t.string   "color",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "blurb",           limit: 65535
    t.integer  "project_id",      limit: 4
    t.string   "graphviz_method", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.string   "firstname",          limit: 255
    t.string   "lastname",           limit: 255
    t.string   "gender",             limit: 255
    t.datetime "birthdate"
    t.boolean  "admin"
    t.string   "username",           limit: 255
    t.integer  "sign_in_count",      limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip", limit: 255
    t.string   "last_sign_in_ip",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["username"], name: "index_people_on_username", unique: true, using: :btree

  create_table "project_invitations", force: :cascade do |t|
    t.string   "token",                 limit: 255,               null: false
    t.string   "email",                 limit: 255,               null: false
    t.integer  "project_id",            limit: 4,                 null: false
    t.integer  "inviter_id",            limit: 4,                 null: false
    t.text     "membership_attributes", limit: 65535
    t.datetime "consumed_at"
    t.integer  "project_membership_id", limit: 4
    t.integer  "sign_in_count",         limit: 4,     default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",    limit: 255
    t.string   "last_sign_in_ip",       limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "project_invitations", ["project_id", "email"], name: "index_project_invitations_on_project_id_and_email", unique: true, using: :btree
  add_index "project_invitations", ["token"], name: "index_project_invitations_on_token", unique: true, using: :btree

  create_table "project_memberships", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.integer  "person_id",  limit: 4
    t.boolean  "author"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "blurb",             limit: 65535
    t.string   "public_visibility", limit: 255,   default: "hidden", null: false
    t.boolean  "gametex_available",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["public_visibility"], name: "index_projects_on_public_visibility", using: :btree

  create_table "publication_templates", force: :cascade do |t|
    t.integer  "project_id",      limit: 4
    t.string   "name",            limit: 255
    t.string   "format",          limit: 255
    t.text     "content",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_template_id", limit: 4
    t.integer  "layout_id",       limit: 4
    t.string   "template_type",   limit: 255,   default: "standalone"
  end

  create_table "relationship_types", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "left_description",  limit: 255
    t.string   "right_description", limit: 255
    t.integer  "project_id",        limit: 4
    t.integer  "left_template_id",  limit: 4
    t.integer  "right_template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationship_types", ["project_id"], name: "index_relationship_types_on_project_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "relationship_type_id", limit: 4
    t.integer  "project_id",           limit: 4
    t.integer  "left_id",              limit: 4
    t.integer  "right_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_settings", force: :cascade do |t|
    t.string   "site_name",    limit: 255
    t.string   "site_color",   limit: 255
    t.integer  "admin_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site_email",   limit: 255
    t.text     "welcome_html", limit: 65535
  end

end
