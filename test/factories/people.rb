Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.define :person do |p|
  p.email { Factory.next(:email) }
end