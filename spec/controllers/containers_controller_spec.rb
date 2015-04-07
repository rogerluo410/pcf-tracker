require 'spec_helper'

describe ContainersController do
     
    before :all do
     @product = Product.create! FactoryGirl.attributes_for(:product)
   end
 
   def valid_attributes_for_container
    FactoryGirl.attributes_for(:container).merge(:product_id => @product.id)
   end 

   def valid_attributes_for_done_container
    FactoryGirl.attributes_for(:container).merge(:product_id => @product.id,:ct_status => 2)
   end
  
   def valid_attributes_for_undone_container
    FactoryGirl.attributes_for(:container).merge(:product_id => @product.id,:ct_status => 1)
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


   def valid_baseos_package_list(containerid)
     packagelist = '{"container_id":"'+containerid.to_s+'","category":"baseos","list":[{"package":"bind9-host,1:9.7.0.dfsg.P1-1ubuntu0.9"},{"package":"cmake,2.8.0-5ubuntu1"}]}'
     return packagelist
   end

   def valid_baseos_package_list_for_sync_err(containerid)
     packagelist = '{"container_id":"'+containerid.to_s+'","category":"baseos","list":[{"package":"bind9-host,10:9.7.0.dfsg.P1-1ubuntu0.9"},{"package":"cmake,9.8.0-5ubuntu1"}]}'
     return packagelist
   end

   def invalid_baseos_package_list(containerid)
     packagelist = '{"container_id":"'+containerid.to_s+'","category":"baseos","list":[{"package":"bind9-host1:9.7.0.dfsg.P1-1ubuntu0.9"},{"package":"cmake2.8.0-5ubuntu1"}]}'
     return packagelist
   end
 

    describe "POST #create" do
    it "responds successfully with an HTTP 200 status code" do
      post :create ,{:container => valid_attributes_for_container }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "creates a new Container" do
          expect {
            post :create,{:container => valid_attributes_for_container}
          }.to change(Container, :count).by(1)
        end
  end

  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_container
      get :show,{:id => @container.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "Show a Container as @Container" do
        @container = Container.create! valid_attributes_for_container
        get :show,{:id => @container.to_param}
        assigns(:container).should be_a(Container)
    end
  end

  describe "POST #upload" do
    it "using correct parameters to upload baseos package list,responding successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      post :upload, {:id => @container.to_param , :packagelist => valid_baseos_package_list(@container.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end
  
     it "using correct parameters but missing MT to upload baseos package list,responding successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      post :upload, {:id => @container.to_param , :packagelist => valid_baseos_package_list_for_sync_err(@container.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end


     it "using wrong parameters to upload baseos package list,responding successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      post :upload, {:id => @container.to_param , :packagelist => invalid_baseos_package_list(@container.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
    end
   end

  describe "Get #delete_container" do
    it "responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      @containerpackage = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      get :delete_container, {:id => @container.id }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "Get #update_container_info" do
    it "responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_done_container
      @containerpackage = ContainerPackage.create! valid_attributes_for_done_container_package(@container.id)
      get :update_container_info, {:id => @container.to_param , :container => valid_attributes_for_done_container}
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "Get #list_of_container_packages" do
    it "responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      @containerpackage_1 = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      @containerpackage_2 = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      get :list_of_container_packages, {:id => @container.to_param }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["total"].should == 2
    end
  end 
 
  describe "Get #sync_missing_mt" do
    it "package have already had MT,responds successfully with an HTTP 200 status code,but stat of JSON data should be 'err'" do
      @container = Container.create! valid_attributes_for_undone_container
      @containerpackage_1 = ContainerPackage.create! valid_attributes_for_done_container_package(@container.id)
      get :sync_missing_mt, {:id => @container.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
     end

    it "missing MT and sync error, responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      @containerpackage_1 = ContainerPackage.create! invalid_attributes_for_missing_mt_container_package(@container.id)
      get :sync_missing_mt, {:id => @container.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
     end
  
     it "missing MT and file right automatically, responds successfully with an HTTP 200 status code" do
      @container = Container.create! valid_attributes_for_undone_container
      @containerpackage_1 = ContainerPackage.create! valid_attributes_for_missing_mt_container_package(@container.id)
      get :sync_missing_mt, {:id => @container.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
     end  
  end
end
