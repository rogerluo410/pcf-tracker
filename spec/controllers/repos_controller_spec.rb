require 'spec_helper'

describe ReposController do

  before :all do
     @product = Product.create! FactoryGirl.attributes_for(:product)
   end
 
  #Access to Scotzilla for filing UT 
  def access_to_scotzilla 
    user ='{"username":"wluo","password":"Eclipse18$"}'
  end
 
  def valid_attributes_for_create_repo
    FactoryGirl.attributes_for(:repo).merge(:product_id => @product.id)
  end
 
  #prodcut name'lwq' and version '1.2.3' need to be created in Scotzilla 
  def valid_attributes_for_done_repo
    FactoryGirl.attributes_for(:repo).merge(:product_id => @product.id,:name =>'lwq',:version => '1.2.3', :bugzilla_status => 2,:mt_id => 280314,:ut_id => 280315,:status => 1)
  end

  #prodcut name'lwq' and version '1.2.3' need to be created in Scotzilla
  def valid_attributes_for_undone_repo
    FactoryGirl.attributes_for(:repo).merge(:product_id => @product.id,:name =>'lwq',:version => '1.2.3', :bugzilla_status => 1)
  end

  def invalid_attributes_for_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>400000,:ut_id => 0)
  end

  def valid_attributes_for_done_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>170628,:ut_id => 228124,:status => 1) 
  end

  def valid_attributes_for_missing_mt_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>0,:ut_id => 0)
  end

   def valid_attributes_for_missing_mt_sycn_err_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.2', :mt_id =>0,:ut_id => 0)
  end


  def valid_attributes_for_missing_ut_repo_package(repoid)
    FactoryGirl.attributes_for(:repo_package).merge(:repo_id =>repoid,:name =>'activesupport', :version => '3.0.20', :mt_id =>170628,:ut_id => 0)
  end




  def valid_ruby_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"ruby","list":[{"package":"activesupport(>=3.0.2,<4.1)"},{"package":"activerecord(4.0.0)"}]}'
     return packagelist
  end
  
  def invalid_ruby_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"ruby","list":[{"package":"activesupport3"},{"package":"activerecord4"}]}'
     return packagelist
  end

  def valid_ruby_package_list_for_missing_mt(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"ruby","list":[{"package":"activesupport(10.0.0)"},{"package":"activerecord(12.0.0)"}]}'
     return packagelist
  end


   def valid_java_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"java","list":[{"package":"spring-context,3.1.0.RELEASE"},{"package":"spring-orm,3.1.0.RELEASE"},{"package":"spring-data-mongodb,1.0.1.RELEASE"}]}'
     return packagelist
  end

   def invalid_java_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"java","list":[{"package":"spring-context3.1.0.RELEASE"},{"package":"spring-orm3.1.0.RELEASE"},{"package":"spring-data-mongodb1.0.1.RELEASE"}]}'
     return packagelist
  end

   def valid_go_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"go","list":[{"package":"gouuid,87bcc4729f2c5a08d2513ad10684c6bbd256380f"},{"package":"gocheck,85"}]}'
     return packagelist
  end

   def invalid_go_package_list(repoid)
     packagelist = '{"repo_id":"'+repoid.to_s+'","category":"go","list":[{"package":"gouuid87bcc4729f2c5a08d2513ad10684c6bbd256380f"},{"package":"gocheck85"}]}'
     return packagelist
  end
   
   describe "POST #create" do
    it "responds successfully with an HTTP 200 status code" do
      post :create ,{:repo => valid_attributes_for_create_repo }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "creates a new Repo" do
          expect {
            post :create,{:repo => valid_attributes_for_create_repo }
          }.to change(Repo, :count).by(1)
        end
  end

  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      get :show,{:id => @repo.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it "Show a Repo as @Repo" do
      @repo = Repo.create! valid_attributes_for_undone_repo 
      get :show,{:id => @repo.to_param}
      assigns(:repo).should be_a(Repo)
    end
  end
 
  describe "POST #upload" do
    it "using correct parameters to upload ruby package list,responding successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => valid_ruby_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end

     it "using wrong parameters to upload ruby package list,responding successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => invalid_ruby_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
    end

    it "using correct parameters to upload ruby package list but missing MT,responding successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => valid_ruby_package_list_for_missing_mt(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end

    it "using correct parameters to upload java package list,responding successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => valid_java_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end

    it "using wrong parameters to upload java package list,responding successfully with an HTTP 200 status code,but stat of JSON data is equal to 'err'" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => invalid_java_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
    end
   
    it "using correct parameters to upload go package list,responding successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => valid_go_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end

    it "using wrong parameters to upload go package list,responding successfully with an HTTP 200 status code,but stat of JSON data is equal to 'err'" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      post :upload, {:id => @repo.to_param , :packagelist => invalid_go_package_list(@repo.id) }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
    end
       
  end

  
  describe "Get #list_of_repo_packages" do
    it "responds successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo      
      @repopackage_1 = RepoPackage.create! valid_attributes_for_done_repo_package(@repo.id)
      @repopackage_2 = RepoPackage.create! valid_attributes_for_done_repo_package(@repo.id)
      get :list_of_repo_packages, {:id => @repo.to_param }
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["total"].should == 2
    end
  end

  
  describe "Get #delete_repo" do
    it "responds successfully with an HTTP 200 status code" do 
      @repo = Repo.create! valid_attributes_for_undone_repo
      @repopackage_1 = RepoPackage.create! valid_attributes_for_done_repo_package(@repo.id)
      get :delete_repo, {:id => @repo.to_param }
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
  
  describe "Get #update_repo_info" do
    it "responds successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      @repopackage_1 = RepoPackage.create! valid_attributes_for_done_repo_package(@repo.id)
      get :update_repo_info, {:id => @repo.to_param , :repo => valid_attributes_for_done_repo}
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "Get #sync_missing_mt" do 
    it "package has mt,responds successfully with an HTTP 200 status code,but stat of JSON data should be 'err'" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      @repopackage = RepoPackage.create! valid_attributes_for_missing_ut_repo_package(@repo.id)
      get :sync_missing_mt, {:id => @repo.to_param}    
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'err'
    end
   
    it "missing MT and sync all missing, responds successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      @repopackage = RepoPackage.create! valid_attributes_for_missing_mt_repo_package(@repo.id)
      get :sync_missing_mt, {:id => @repo.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end

    it "missing MT and sync part of all, responds successfully with an HTTP 200 status code" do
      @repo = Repo.create! valid_attributes_for_undone_repo
      @repopackage = RepoPackage.create! valid_attributes_for_missing_mt_repo_package(@repo.id)
      @repopackage = RepoPackage.create! valid_attributes_for_missing_mt_sycn_err_repo_package(@repo.id)     
      get :sync_missing_mt, {:id => @repo.to_param}
      expect(response).to be_success
      expect(response.status).to eq(200)
      JSON.parse(response.body)["stat"].should == 'ok'
    end
  end

  describe "Get #filing_ut" do
       it "using wrong parameters to file UT,responds successfully with an HTTP 200 status code,but stat of JSON data should be 'err' " do
        @repo = Repo.create! valid_attributes_for_done_repo
        @repopackage = RepoPackage.create! invalid_attributes_for_repo_package(@repo.id)
        get :filing_ut , {:id => @repo.to_param, :user=> access_to_scotzilla }
        expect(response).to be_success
        expect(response.status).to eq(200)
        JSON.parse(response.body)["stat"].should == 'err'
        end

       it "using correct parameters to file UT,responds successfully with an HTTP 200 status code,and colume 'stat' of JSON data should be 'ok' " do
        @repo = Repo.create! valid_attributes_for_done_repo
        @repopackage = RepoPackage.create! valid_attributes_for_missing_ut_repo_package(@repo.id)
        get :filing_ut , {:id => @repo.to_param, :user=> access_to_scotzilla }
        expect(response).to be_success
        expect(response.status).to eq(200)
        JSON.parse(response.body)["stat"].should == 'ok'
        end
 
       it "using undone bugzilla status to file UT,responds successfully with an HTTP 200 status code,but stat of JSON data should be 'err' " do
        @repo = Repo.create! valid_attributes_for_undone_repo
        @repopackage = RepoPackage.create! valid_attributes_for_missing_ut_repo_package(@repo.id)
        get :filing_ut , {:id => @repo.to_param, :user=> access_to_scotzilla }
        expect(response).to be_success
        expect(response.status).to eq(200)
        JSON.parse(response.body)["stat"].should == 'err'
        end

       it "using missing MT to file UT,responds successfully with an HTTP 200 status code,but stat of JSON data should be 'err' " do
        @repo = Repo.create! valid_attributes_for_done_repo
        @repopackage = RepoPackage.create! valid_attributes_for_missing_mt_repo_package(@repo.id)
        get :filing_ut , {:id => @repo.to_param, :user=> access_to_scotzilla }
        expect(response).to be_success
        expect(response.status).to eq(200)
        JSON.parse(response.body)["stat"].should == 'err'
        end


  end

end
