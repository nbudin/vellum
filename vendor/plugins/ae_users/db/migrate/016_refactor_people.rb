class RefactorPeople < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.establish_connection :users
    create_table :procon_profiles do |t|
      t.column :person_id, :integer, :null => false
      t.column :nickname, :string
      t.column :phone, :string
      t.column :best_call_time, :string
    end
    Person.find(:all).each do |person|
      prof = ProconProfile.new :person => person
      prof.nickname = person.nickname
      prof.phone = person.phone
      prof.best_call_time = person.best_call_time
      prof.save
    end
    remove_column "people", "nickname"
    remove_column "people", "phone"
    remove_column "people", "best_call_time"
  end

  def self.down
    ActiveRecord::Base.establish_connection :users
    add_column "people", "nickname", :string
    add_column "people", "phone", :string
    add_column "people", "best_call_time", :string
    ProconProfile.find(:all).each do |prof|
      person = prof.person
      person.nickname = prof.nickname
      person.phone = prof.phone
      person.best_call_time = prof.best_call_time
      person.save
    end
    drop_table :procon_profiles
  end
end
