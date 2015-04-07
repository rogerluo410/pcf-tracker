require 'spec_helper'

describe Repo do
   it 'has a valid Repo object' do
    Repo.new.should be_valid
   end

end
