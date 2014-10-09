FactoryGirl.define do
  factory :repo do
    name Faker::Name.name
    version '1.2.0.0'
    mt_id 280000 
    ut_id 280001
    bugzilla_url 'http://test_repo.bugzilla.com'
    bugzilla_status 0
    status 0
    deleted false
  end
end
