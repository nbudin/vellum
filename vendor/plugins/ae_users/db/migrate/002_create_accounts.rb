class CreateAccounts < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.establish_connection :users
    create_table :accounts do |t|
      t.column :password, :string, :null => false
      t.column :active, :boolean
      t.column :activation_key, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    ActiveRecord::Base.establish_connection :users
    drop_table :accounts
  end
end
