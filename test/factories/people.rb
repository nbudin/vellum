FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :person do |p|
    p.email { FactoryGirl.generate(:email) }
    p.firstname "Firstname"
    p.lastname "Lastname"
    
    after(:build) { |p| p.username = p.email }
  end

  factory :project_membership do |m|
    m.association :person
    m.association :project
  end
  
end