Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.define :person do |p|
  p.email { Factory.next(:email) }
end

Factory.define :project_membership do |m|
  m.association :person
  m.association :project
end