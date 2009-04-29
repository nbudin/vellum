class CreateEmailAddresses < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.establish_connection :users
    create_table :email_addresses do |t|
      t.column :address, :string, :null => false
      t.column :primary, :boolean
      t.column :account_id, :integer, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    ActiveRecord::Base.establish_connection :users
    drop_table :email_addresses
  end
end
