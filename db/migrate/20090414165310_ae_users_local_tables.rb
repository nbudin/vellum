class AeUsersLocalTables < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.column :role_id, :integer
      t.column :person_id, :integer
      t.column :permission, :string
      t.column :permissioned_id, :integer
      t.column :permissioned_type, :string
    end
    
    create_table :auth_tickets do |t|
      t.column :secret, :string
      t.column :person_id, :integer
      t.timestamps
      t.column :expires_at, :datetime
    end

    add_index :auth_tickets, :secret, :unique => true

    create_table :permission_caches do |t|
      t.column :person_id, :integer
      t.column :permissioned_id, :integer
      t.column :permissioned_type, :string
      t.column :permission_name, :string
      t.column :result, :boolean
    end

    add_index :permission_caches, :person_id
    add_index :permission_caches, [:permissioned_id, :permissioned_type]
    add_index :permission_caches, :permission_name
  end

  def self.down
    drop_table :permission_caches
    drop_table :auth_tickets
    drop_table :permissions
  end
end
