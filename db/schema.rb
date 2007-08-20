# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 6) do

  create_table "attributes", :force => true do |t|
    t.column "name",                         :string
    t.column "attribute_configuration_id",   :integer
    t.column "attribute_configuration_type", :string
  end

  create_table "document_versions", :force => true do |t|
    t.column "document_id", :integer
    t.column "version",     :integer
    t.column "title",       :text
    t.column "content",     :text
    t.column "created_at",  :datetime
    t.column "updated_at",  :datetime
    t.column "template_id", :integer
  end

  create_table "documents", :force => true do |t|
    t.column "title",       :text
    t.column "content",     :text
    t.column "created_at",  :datetime
    t.column "updated_at",  :datetime
    t.column "template_id", :integer
    t.column "version",     :integer
  end

  create_table "relationship_types", :force => true do |t|
    t.column "name",              :string
    t.column "left_description",  :string
    t.column "right_description", :string
    t.column "left_type",         :string
    t.column "right_type",        :string
  end

  create_table "relationship_types_templates", :id => false, :force => true do |t|
    t.column "relationship_type_id", :integer
    t.column "template_id",          :integer
  end

  create_table "structures", :force => true do |t|
    t.column "template_id", :integer
  end

  create_table "templates", :force => true do |t|
    t.column "name",      :string
    t.column "parent_id", :integer
  end

end
