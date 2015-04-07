require 'spec_helper'

describe ContainerPackage do
  it 'has a valid ContainerPackage object' do
    ContainerPackage.new.should be_valid
   end
end
