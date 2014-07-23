class CreateProjectInvitations < ActiveRecord::Migration
  def change
    create_table :project_invitations do |t|
      t.string :token, null: false
      t.string :email, null: false
      t.references :project, null: false
      t.references :inviter, null: false
      t.text :membership_attributes
      
      t.timestamp :consumed_at
      t.references :project_membership
      
      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      
      t.timestamps
    end
    
    add_index :project_invitations, [:project_id, :email], unique: true
    add_index :project_invitations, [:token], unique: true
  end
end
