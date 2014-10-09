require 'spec_helper'

describe ProductsController do
     
   before :all do
     @product = Product.create! FactoryGirl.attributes_for(:product)
   end
   
   def valid_attributes_for_product
     FactoryGirl.attributes_for(:product).merge(:name => 'PCF',:version => '1.2.0.0')
   end

   def valid_attributes_for_undone_product
     FactoryGirl.attributes_for(:product).merge(:name => 'PCF',:version => '1.2.0.0',:bugzilla_status =>2)
   end
 
   def valid_attributes_for_done_product
     FactoryGirl.attributes_for(:product).merge(:name => 'PCF',:version => '1.2.0.0',:status=>1,:bugzilla_status =>2)
   end
 

   #container relevant
   def valid_attributes_for_container(productid)
    FactoryGirl.attributes_for(:container).merge(:product_id => productid)
   end 

   def valid_attributes_for_done_container(productid)
    FactoryGirl.attributes_for(:container).merge(:product_id => productid,:ct_status => 2,:status => 1 )
   end
  
   def valid_attributes_for_undone_container(productid)
    FactoryGirl.attributes_for(:container).merge(:product_id => productid,:ct_status => 1,:status => 0 )
   end
 
   def valid_attributes_for_initial_container(productid)
    FactoryGirl.attributes_for(:container).merge(:product_id => productid,:ct_status => 0,:status => 0 )
   end

   def valid_attributes_for_missing_mt_container_package(containerid)
    FactoryGirl.attributes_for(:container_package).merge(:container_id => containerid , :name => 'bind9-host' , :version => '1:9.7.0.dfsg.P1-1ubuntu0.9', :mt_id => 0)
   end

   def invalid_attributes_for_missing_mt_container_package(containerid)
    FactoryGirl.attributes_for(:container_package).merge(:container_id => containerid , :name => 'bind9-host' , :version => '10:9.7.0.dfsg.P1-1ubuntu0.9', :mt_id => 0)
   end

   def valid_attributes_for_done_container_package(containerid)
    FactoryGirl.attributes_for(:container_package).merge(:container_id => containerid , :name => 'bind9-host' , :version => '1:9.7.0.dfsg.P1-1ubuntu0.9', :mt_id => 228086,:status => 1 )
   end
  
  #repo relevant
  #prodcut name'lwq' and version '1.2.3' need to be created in Scotzilla 
  def valid_attributes_for_done_repo(productid)
    FactoryGirl.attributes_for(:repo).merge(:product_id => productid,:name =>'lwq',:version => '1.2.3', :bugzilla_status => 2,:mt_id => 280314,:ut_id => 280315,:status => 1)
  end

  #prodcut name'lwq' and version '1.2.3' need to be created in Scotzilla
  def valid_attributes_for_undone_repo(productid)
    FactoryGirl.attributes_for(:repo).merge(:product_id => productid,:name =>'lwq',:version => '1.2.3', :bugzilla_status => 1 ,:mt_id => 0,:ut_id => 0)
  end
 
   def valid_attributes_for_initial_repo(productid)
    FactoryGirl.attributes_for(:repo).merge(:product_id => productid,:name =>'lwq',:version => '1.2.3', :bugzilla_status => 0)
  end

  def invalid_attributes_for_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>400000,:ut_id => 0)
  end

  def valid_attributes_for_done_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>170628,:ut_id => 228124,:status => 1)
  end

    describe "POST #create" do
    it "responds successfully with an HTTP 200 status code" do
      post :create ,{:product => valid_attributes_for_product }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "creates a new Product" do
          expect {
            post :create,{:product => valid_attributes_for_product  }
          }.to change(Product, :count).by(1)
        end
  end

  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      @product = Product.create! valid_attributes_for_product
      get :show,{:id => @product.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "Show a Product as @Product" do
        @product = Product.create! valid_attributes_for_product
        get :show,{:id => @product.to_param}
        assigns(:product).should be_a(Product)
    end
  end


  describe "Get #index" do
    it "undone product, responds successfully with an HTTP 200 status code" do
      @product = Product.create! valid_attributes_for_product
      @container = Container.create! valid_attributes_for_undone_container(@product.id)
      @containerpackage = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      @repo = Repo.create! valid_attributes_for_done_repo(@product.id)
      @repopackage = RepoPackage.create!  valid_attributes_for_done_repo_package(@repo.id)
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
    
     it "done product,responds successfully with an HTTP 200 status code" do
      @product = Product.create! valid_attributes_for_done_product
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end 
  end

  describe "Get #repo_total_func" do
    it "responds successfully with an HTTP 200 status code" do
       @product = Product.create! valid_attributes_for_product
       get :repo_total_func,{:id => @product.to_param }
       expect(response).to be_success
       expect(response.status).to eq(200)
       response.body.length.should >= 0
    end
  end

  describe "Get #container_total_func" do
    it "responds successfully with an HTTP 200 status code" do
       @product = Product.create! valid_attributes_for_product
       get :container_total_func,{:id => @product.to_param }
       expect(response).to be_success
       expect(response.status).to eq(200)
       response.body.length.should >= 0
    end
  end

  describe "Get #repo_mt_total_func" do
    it "responds successfully with an HTTP 200 status code" do
       @product = Product.create! valid_attributes_for_product
       get :repo_mt_total_func,{:id => @product.to_param }
       expect(response).to be_success
       expect(response.status).to eq(200)
       response.body.length.should >= 0
    end
  end
 
  describe "Get #repo_ut_total_func" do
    it "responds successfully with an HTTP 200 status code" do
       @product = Product.create! valid_attributes_for_product
       get :repo_ut_total_func,{:id => @product.to_param }
       expect(response).to be_success
       expect(response.status).to eq(200)
       response.body.length.should >= 0
    end
  end

  describe "Get #repo_details_of_product" do
    it "responds successfully with an HTTP 200 status code" do
      @product = Product.create! valid_attributes_for_product
      @container = Container.create! valid_attributes_for_undone_container(@product.id)
      @container_1 = Container.create! valid_attributes_for_done_container(@product.id)
      @container_2 = Container.create! valid_attributes_for_initial_container(@product.id)
      @containerpackage = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      @containerpackage_1 = ContainerPackage.create! valid_attributes_for_done_container_package(@container.id)
      @repo = Repo.create! valid_attributes_for_done_repo(@product.id)
      @repo_1 = Repo.create! valid_attributes_for_undone_repo(@product.id)
      @repo_2 = Repo.create! valid_attributes_for_initial_repo(@product.id)
      @repopackage = RepoPackage.create!  valid_attributes_for_done_repo_package(@repo.id)
      get :repo_details_of_product, {:id => @product.to_param }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "Get #update_product_info" do
     it "responds successfully with an HTTP 200 status code" do
         @product = Product.create! valid_attributes_for_product
         post :update_product_info,{ :id =>@product.to_param ,:product => valid_attributes_for_undone_product  }
         expect(response).to be_success
         expect(response.status).to eq(200)
     end
  end

  describe "Get #get_latest_product" do
      it "responds successfully with an HTTP 200 status code" do
         @product = Product.create! valid_attributes_for_product
         get :get_latest_product , {:id => @product.to_param }
         expect(response).to be_success
         expect(response.status).to eq(200)
      end
  end

end
