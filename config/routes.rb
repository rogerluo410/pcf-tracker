Pcf_Tracker::Application.routes.draw do
  get "welcome/index"

  resources :AssessmentsController
  
  resources :products do
    member do
      get 'repo_total', to:'products#repo_total_func' 
      get 'container_total', to:'products#container_total_func'
      get 'repo_mt_total', to:'products#repo_mt_total_func'
      get 'repo_ut_total', to:'products#repo_ut_total_func'
      get 'get_latest_product', to:'products#get_latest_product'
      get 'repo_details_of_product', to:'products#repo_details_of_product' 
      post 'update_product_info', to:'products#update_product_info'
      post 'update_package', to:'products#update_package'
    end
  end
  
  resources :repos do
     member do 
        get 'repo_packages', to:'repos#list_of_repo_packages' 
        get 'repo_packages_filling_missing', to:'repos#sync_missing_mt'
        post 'repo_packages_list_upload', to:'repos#upload'  
        post 'repo_packages_file_ut', to:'repos#filing_ut'
        get 'delete_repo', to:'repos#delete_repo'
        post 'update_repo_info', to:'repos#update_repo_info'
     end
    end

  resources :containers do
     member do
       get 'container_packages', to:'containers#list_of_container_packages' 
       get 'container_packages_filling_missing', to:'containers#sync_missing_mt'
       post 'container_packages_list_upload', to:'containers#upload'
       get 'delete_container', to:'containers#delete_container'
       post 'update_container_info', to:'containers#update_container_info'
    end
  end 


end
