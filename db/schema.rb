# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 16) do

  create_table "attr_value_metadatas", :force => true do |t|
    t.integer "attr_id"
    t.integer "structure_id"
    t.integer "value_id"
    t.string  "value_type"
  end

  create_table "attrs", :force => true do |t|
    t.string  "name"
    t.integer "structure_template_id"
    t.integer "attr_configuration_id"
    t.string  "attr_configuration_type"
    t.integer "position"
    t.boolean "required"
  end

  create_table "document_versions", :force => true do |t|
    t.integer  "document_id"
    t.integer  "version"
    t.text     "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "structure_template_id"
    t.integer  "project_id"
  end

  create_table "documents", :force => true do |t|
    t.text     "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "structure_template_id"
    t.integer  "version"
    t.integer  "project_id"
  end

  create_table "number_fields", :force => true do |t|
    t.float    "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "number_values", :force => true do |t|
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created"
  end

  create_table "open_id_authentication_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "projects", :force => true do |t|
    t.string  "name"
    t.integer "template_schema_id"
  end

  create_table "relationship_types", :force => true do |t|
    t.string  "name"
    t.string  "left_description"
    t.string  "right_description"
    t.integer "left_template_id"
    t.integer "right_template_id"
    t.integer "template_schema_id"
  end

  create_table "relationships", :force => true do |t|
    t.integer "relationship_type_id"
    t.integer "left_id"
    t.integer "right_id"
  end

  create_table "structure_templates", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.integer "template_schema_id"
  end

  create_table "structures", :force => true do |t|
    t.integer "structure_template_id"
    t.integer "project_id"
  end

  create_table "template_schemas", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "text_fields", :force => true do |t|
    t.string "default"
  end

  create_table "text_values", :force => true do |t|
    t.text "value"
  end

end
