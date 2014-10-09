require 'spec_helper'

describe Product do
  
  before :all do
     @product = Product.create! FactoryGirl.attributes_for(:product)
     @repo = Repo.create! FactoryGirl.attributes_for(:repo).merge(:product_id => @product.id)
     @container = Container.create! FactoryGirl.attributes_for(:container).merge(:product_id => @product.id)
   end

   it 'has a valid Product object' do
    Product.new.should be_valid
   end
  
   it 'has a valid factory' do
    Product.create!(FactoryGirl.attributes_for(:product)).should be_valid
  end

   describe "Test Product scopes" do 
     it 'returns a list with not_deleted scope' do
      result = Product.not_deleted
      result.length.should >= 0
     end
     it 'returns a Product with latest_product scope' do
      result = Product.latest_product
      result.length.should >= 0
     end
   end
  
    describe "Test Product functions" do
        it "returns data with count_number_undone function" do
           result = @product.count_number_undone(@product.id)
           result.length.should >= 1
           result[0].sum.to_i.should >= 0
        end
      
       it "returns data with repo_total_rate function" do
           result = @product.repo_total_rate(@product.id)
           result.length.should eq(2)
       end
       
       it "returns data with container_total_rate function" do
           result = @product.container_total_rate(@product.id)
           result.length.should eq(2)  
       end
 
       it "returns data with repo_mt_total_rate function" do
           result = @product.repo_mt_total_rate(@product.id)
           result.length.should eq(2)    
       end
 
      it "returns data with repo_ut_total_rate  function" do
           result = @product.repo_ut_total_rate(@product.id)
           result.length.should eq(2)
       end
     
      it "returns data with each_repo_mt_total_rate  function" do
           result = @product.each_repo_mt_total_rate(@product.id,@repo.id)
           result.length.should eq(2)
       end
 
       it "returns data with each_repo_ut_total_rate  function" do
           result = @product.each_repo_ut_total_rate(@product.id,@repo.id)
           result.length.should eq(2)
       end

       it "returns data with each_container_total_rate function" do
           result = @product.each_repo_mt_total_rate(@product.id,@container.id)
           result.length.should eq(2)
       end

       it "returns data with list_of_product function" do
           result = @product.list_of_product(@product.id)
           result.length.should >= 0
       end 
 
    end
  
end
