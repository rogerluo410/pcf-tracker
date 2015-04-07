require 'spec_helper'


describe RepoPackage do
   it 'has a valid RepoPackage object' do
    RepoPackage.new.should be_valid
   end
   
end
