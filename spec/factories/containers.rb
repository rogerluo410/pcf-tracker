FactoryGirl.define do
  factory :container do
    name Faker::Name.name
    version '1.2.0.0'
    ct_status 0
    status  1
    deleted false
  end
end
