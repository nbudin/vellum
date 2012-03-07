FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :person do |p|
    p.email { FactoryGirl.generate(:email) }
  end

  factory :project_membership do |m|
    m.association :person
    m.association :project
  end
  
end