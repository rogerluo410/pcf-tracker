require 'yaml'

desc 'Run Travis CI job'
task :ci do
  Rails.env = 'ci'
  Rake::Task['spec'].invoke
end
