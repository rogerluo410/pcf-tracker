FactoryGirl.define do
  factory :product do
    name Faker::Name.name
    version '1.2.0.0'
    bugzilla_url 'http://test_product.bugzilla.com'
    bugzilla_status 0
    status 0
    release_date  '05/02/2014'
    description Faker::Lorem.sentence
    deleted false
  end
end
