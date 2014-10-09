class ReposController < ApplicationController

  include ApplicationHelper

    #only for testing
    #def index
    # string = 'activesupport(>=3.0.2,<4.1)'
    # couple = extract_ruby(string)
    # puts couple[0],couple[1]
    # @result =search_scotzilla(couple[0],couple[1],'VMWsource') 
    # #Observe 
    # delete_all_old_packages(4)
    # product_controller  = ProductsController.new
    # product_controller.update_product_status(1) 
    # render :json=>@result , status=>"200 ok"
    #end

    def create
     @repo = Repo.new params[:repo]
     Repo.transaction do
     @repo.save
     #update product's status
     observe_product_status(@repo.product_id)
     end
     render :json=>'{"stat":"ok","msg":"Creating Repo is ok"}', status=>"200 ok"
     rescue ActiveRecord::RecordInvalid => invalid
     render :json=>'{"stat":"err","msg":"'+invalid.record.errors+'"}' , status=>"200 ok" 
    end

    def show
     @repo = Repo.find(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
        render :json=>@repo , status=>"200 ok"
      end   
     rescue ActiveRecord::RecordNotFound 
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok" 
    end

    def upload
      @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
      #format
      #json_filelist = '{"repo_id":"1","category":"ruby","list":[{"package":"activesupport(>=3.0.2,<4.1)"},{"package":"activerecord(4.0.0)"}]}'
      json_filelist = params[:packagelist]   
      data = JSON.parse(json_filelist)
      repo_package_list = []
      repoid = data['repo_id']
      #count total
      total_cnt = 0 
      #count correct search
      correct_cnt = 0
      #count failure
      f_cnt = 0
      #list of extracting failure
      failure_list = ''
      #loop
      data['list'].map{ | package | 
      couple = []
      result = ''
      if data['category'] == 'ruby'
          couple = extract_ruby(package['package'])       
      elsif data['category'] == 'go'
          couple = extract_go(package['package'])
      elsif data['category'] == 'java'
          couple = extract_java(package['package'])
      end
        total_cnt = total_cnt + 1
        if couple[0]!=nil  and couple[1] !=nil
        result = search_scotzilla(couple[0].downcase,couple[1].downcase,'VMWsource')
        repo_package = RepoPackage.new
        repo_package.name = couple[0]
        repo_package.version = couple[1]
        if result['stat'] == 'ok'
           repo_package.mt_id = result['id']
           correct_cnt = correct_cnt + 1
        else
           repo_package.mt_id = 0
           f_cnt = f_cnt + 1
        end
        repo_package.ut_id = 0
        repo_package.status = 0
        repo_package.repo_id = repoid
        repo_package_list.push(repo_package)
        else
           failure_list = failure_list + package['package'] + '|'
        end #if couple[0]!=nil and couple[1] !=nil
     } #data['list'].map{ | package | 
        
       RepoPackage.transaction do    
       delete_all_old_packages(repoid) #delete old packages,import new packages               
       repo_package_list.each do | package |
               pkg_query = RepoPackage.find_by_name(package.name,package.version,package.repo_id)
               if pkg_query.blank?
               package.save
               end
            end
       end
 
     json_result = ''
     if total_cnt == correct_cnt + f_cnt
       json_result = '{"stat":"ok","msg":"The total of filling missing MTs is '+total_cnt.to_s+',the number of success is '+correct_cnt.to_s+
                     ',the number of still missing is '+f_cnt.to_s+'"}'
     else
       json_result = '{"stat":"ok","msg":"The total of filling missing MTs is '+total_cnt.to_s+',the number of success is '+correct_cnt.to_s+
                     ',the number of still missing is '+f_cnt.to_s+',the list of failing to extract name plus version is '+ failure_list +' "}'
     end
      
     render :json=>json_result, status=>"200 ok"  
     end
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    def delete_all_old_packages(repoid)
       @repolist = RepoPackage.all_notdeleted_by_repoid(repoid)
       if @repolist.length > 0
       @repolist.each do | package |
             RepoPackage.update(package,:deleted => true)
       end
       end
    end

    def delete_repo
       @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
       RepoPackage.transaction do 
       Repo.update(@repo[0],:deleted => true)
       delete_all_old_packages(@repo[0].id)
       observe_product_status(@repo[0].product_id)
       end
       render :json=>'{"stat":"ok","msg":"Deleting all over the Repo is ok"}', status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end
    
    #get package list of repo
    def list_of_repo_packages
       @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
       repoid = params[:id]
       @repo_packages = RepoPackage.all_notdeleted_by_repoid(repoid)   
       #tansfer to appointed format to frontend
       packages_cnt = 0 #count the number of packages of repo
       total_of_packages = @repo_packages.length
       json_list = '{ "total":'+total_of_packages.to_s+',"rows":['
       rows_list = ''
       @repo_packages.each do | package |
          packages_cnt = packages_cnt + 1
          rows_list = rows_list + '{"id":"'+package.id.to_s+'","name":"'+package.name+'","version":"'+package.version+'","Master Ticket":"'+package.mt_id.to_s+'","Use Ticket":"'+package.ut_id.to_s+'"} '
          if packages_cnt <= total_of_packages-1
             rows_list = rows_list + ' , '
          end
       end
        json_list = json_list + rows_list + ' ] }'   
       render :json=>json_list, status=>"200 ok" 
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    #update the status to be done
    def update_repo_status(id)
       @repo = Repo.find(id)
       @list_of_repo = RepoPackage.all_no_ut_by_repoid(id)
       if @list_of_repo.length == 0 and @repo.mt_id > 0 and @repo.ut_id > 0 
        Repo.update(@repo,:status => 1 )
       end
    end

    #observe product's status
    def observe_product_status(productid)
     #Observe if all children of product are done,if so, changing the status of product to be done.
      product_controller  = ProductsController.new
      product_controller.update_product_status(productid) 
    end

    #update repo info
    def update_repo_info
       @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
       product_id = @repo[0].product_id
       repo = params[:repo]
       @repo[0].name = repo[:name]
       @repo[0].version = repo[:version]
       @repo[0].bugzilla_status = repo[:bugzilla_status]
       @repo[0].bugzilla_url = repo[:bugzilla_url]
       @repo[0].mt_id = repo[:mt_id]
       @repo[0].ut_id = repo[:ut_id]
       @repo[0].save
       #activate to observe state
       update_repo_status(@repo[0].id)
       observe_product_status(product_id)
       render :json=>'{"stat":"ok","msg":"Updating Repo info is ok"}', status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    def sync_missing_mt
       @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
       return
      else
       repoid = params[:id]
       @list_of_missing = RepoPackage.get_missing_mt(repoid)
       total_of_list = @list_of_missing.length
       filling_missing_cnt = 0 #count the number of filling 
       json_return = ''
       if  total_of_list > 0
       RepoPackage.transaction do
       @list_of_missing.each do | miss_package |
           result = search_scotzilla(miss_package.name.downcase,miss_package.version.downcase,'VMWsource')
           if result['stat'] == 'ok'
              filling_missing_cnt = filling_missing_cnt + 1
              #RepoPackage.update(miss_package,:mt_id => result['id'])
              miss_package.mt_id = result['id']
              miss_package.save
           end
       end    
       end #end RepoPackage.transaction do
       
	       if filling_missing_cnt == total_of_list
	       json_return = '{"stat":"ok","msg":"Have already filed '+filling_missing_cnt.to_s+' MTs,total is '+total_of_list.to_s+' MTs for this Repo" }'
	       else
	       json_return = '{"stat":"ok","msg":"Have already filled '+filling_missing_cnt.to_s+' for packages of missing MT, but still '+(total_of_list-filling_missing_cnt).to_s+' failed" }'
	       end
       else
        json_return = '{"stat":"ok","msg":"no missing MT for this Repo" }'  
       end #end if  total_of_list > 0
       render :json=>json_return, status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    def filing_ut
      @repo = Repo.find_not_deleted(params[:id])
      if @repo.blank?
          render :json=>'{"stat":"err","msg":"Not found this repo"}', status=>"200 ok"
          return
      else
      @user_info = params[:user]
      json_return =''
      if @repo[0].bugzilla_status == 2          
      product_id = @repo[0].product_id
      user = JSON.parse(@user_info)
      @list_of_missing = RepoPackage.get_missing_mt(@repo[0].id)
      #@product = Product.find(@repo.product_id)
      total_of_list = @list_of_missing.length
      
      if total_of_list == 0
          @list_of_repo = RepoPackage.all_no_ut_by_repoid(@repo[0].id)
          list_of_repo_cnt = @list_of_repo.length
          filing_ut_cnt = 0
          RepoPackage.transaction do
              @list_of_repo.each do | package |
                result = file_ut(@repo[0].name,@repo[0].version,package.mt_id,user['username'],user['password'])
                if result[:stat] == 'ok'
                puts "Successful..."
                RepoPackage.update(package,:ut_id => result[:id],:status => 1)
                filing_ut_cnt = filing_ut_cnt + 1
                else 
                    #raise ArgumentError,result[:msg]
                end
              end
          end #RepoPackage.transaction do

          #update the status of Repo to be done
          update_repo_status(@repo[0].id)
          #Observe if all children of product are done,if so, changi                    
          observe_product_status(product_id) 
         
          if list_of_repo_cnt == filing_ut_cnt
            json_return = '{"stat":"ok","msg":"Have already filed '+filing_ut_cnt.to_s+' UTs,total is '+list_of_repo_cnt.to_s+' UTs for this Repo" } '  
          elsif filing_ut_cnt == 0
            json_return = '{"stat":"ok","msg":"File UT error,Please check if the product is ok in Scotzilla"}'
          else
            json_return = '{"stat":"ok","msg":"Have already filed '+filing_ut_cnt.to_s+' UTs,total is '+list_of_repo_cnt.to_s+' UTs for this Repo,still not filing '+(list_of_repo_cnt-filing_ut_cnt).to_s+'" } '  
          end
      else
         json_return = '{"stat":"ok","msg":"Have missing MTs for this Repo,the number is '+total_of_list.to_s+'" }'  
      end #end if total_of_list == 0
      else
         json_return = '{"stat":"ok","msg":"Bugzilla is not ok,please check bugzilla status of the Repo" }'
      end
      render :json=>json_return, status=>"200 ok"
      end
      rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
      rescue => err
       puts "GO here"+err.to_s
       render :json=>'{"stat":"err","msg":"Master ticket '+err.to_s+' has problem." }', status=>"200 ok"
    end#end filing_ut
   
end
