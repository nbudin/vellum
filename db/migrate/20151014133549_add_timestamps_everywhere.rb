class AddTimestampsEverywhere < ActiveRecord::Migration
  def change
    %i(attrs doc_template_attrs doc_templates project_memberships projects relationship_types relationships).each do |table_name|
      change_table table_name do |t|
        t.timestamps null: true
      end
    end
  end
end
