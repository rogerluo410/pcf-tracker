FactoryGirl.define do
  factory :repo_package do
    name Faker::Name.name
    version '1.2.3'
    mt_id 0 
    ut_id 0
    status  0
    deleted false
  end
end
