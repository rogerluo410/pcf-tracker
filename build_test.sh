#!/bin/sh

exitcode=0
RAILS_ENV=test rake db:create 
RAILS_ENV=test rake db:migrate
bundle exec rspec || exitcode=1
exit $exitcode
