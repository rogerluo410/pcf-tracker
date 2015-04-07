class ContainersController < ApplicationController

   include ApplicationHelper

    def create
     @container = Container.new params[:container]
     Container.transaction do
     @container.save
     observe_product_status(@container.product_id)
     end
     render :json=>'{"stat":"ok","msg":"Creating Container is ok"}', status=>"200 ok"
     rescue ActiveRecord::RecordInvalid => invalid
     render :json=>'{"stat":"err","msg":"'+invalid.record.errors+'"}' , status=>"200 ok" 
    end
   
    def show
     @container = Container.find_not_deleted(params[:id])
       if @container.blank?
          render :json=>'{"stat":"err","msg":"Not found this container,please refresh the page"}', status=>"200 ok"
          return
       else
           render :json=>@container[0] , status=>"200 ok"    
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    def upload
      @container_1 = Container.find_not_deleted(params[:id])
      if @container_1.blank?
          render :json=>'{"stat":"err","msg":"Not found this container"}', status=>"200 ok"
          return
      else
      #format
      #json_filelist = '{"container_id":"1","target":"ubuntu"/"centos","list":[{"package":"activesupport(>=3.0.2,<4.1)"},{"package":"activerecord(4.0.0)"}]}'
      json_filelist = params[:packagelist]  
      data = JSON.parse(json_filelist)
      @container = Container.find( data['container_id'] )
      productid = @container.product_id
      container_package_list = []     
      puts productid
      #count total
      total_cnt = 0 
      #count correct search
      correct_cnt = 0
      #count failure
      f_cnt = 0
      #list of extracting failure
      failure_list = ''
      target = data['target']
      #loop
      data['list'].map{ | package | 
      couple = extract_linux(package['package'])
      total_cnt = total_cnt + 1 
      if couple[0]!=nil and couple[1] !=nil
        result = search_scotzilla_baseos(couple[0].downcase,couple[1].downcase,'BaseOS',target)       
        container_package = ContainerPackage.new
        container_package.name = couple[0]
        container_package.version = couple[1]
        if result['stat'] == 'ok'
           container_package.mt_id = result['id']
           container_package.status = 1
           correct_cnt = correct_cnt + 1
        else
           container_package.mt_id = 0
           container_package.status = 0
           f_cnt = f_cnt + 1
        end
        container_package.ut_id = 0    
        container_package.container_id = @container.id
        container_package_list.push(container_package)
        else
           failure_list = failure_list + package['package'] + '|'
        end #if couple[0]!=nil and couple[1] !=nil
     }
       ContainerPackage.transaction do 
       delete_all_old_packages(@container.id)                 
       container_package_list.each do | package |
              pkg_query = ContainerPackage.find_by_name(package.name,package.version,package.container_id)
               if pkg_query.blank?
                 package.save
               end
            end
        #update target column of container
        Container.update(@container,:target => target )
       end

     #update the status of Container to be done
     update_container_status(@container.id)

     #Observe if all children of product are done,if so, changing the status of product to be done.
     observe_product_status(productid)      

     json_result = ''
     if total_cnt == correct_cnt + f_cnt
       json_result = '{"stat":"ok","msg":"The total of filling missing MTs is '+total_cnt.to_s+',the number of success is '+correct_cnt.to_s+
                     ',the number of still missing is '+f_cnt.to_s+'"}'
     else
       json_result = '{"stat":"ok","msg":"The total of filling missing MTs is '+total_cnt.to_s+',the number of success is '+correct_cnt.to_s+
                     ',the number of still missing is '+f_cnt.to_s+',the list of failing to extract name plus version is '+ failure_list +' "}'
     end

     render :json=>json_result, status=>"200 ok" 
     end #if @container.blank?
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

     def delete_all_old_packages(containerid)
       @containerlist = ContainerPackage.all_notdeleted_by_containerid(containerid)
       if @containerlist.length > 0
       @containerlist.each do | package |
             ContainerPackage.update(package,:deleted => true)
       end
       end
    end

    def delete_container
       @container_1 = Container.find_not_deleted(params[:id])
      if @container_1.blank?
          render :json=>'{"stat":"err","msg":"Not found this container"}', status=>"200 ok"
         return
      else
       @container = @container_1[0]
       ContainerPackage.transaction do 
       Container.update(@container,:deleted => true)
       delete_all_old_packages(@container.id)
       observe_product_status(@container.product_id)
       end
       render :json=>'{"stat":"ok","msg":"Deleting all over the Container is ok"}', status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

    #get package list of container
    def list_of_container_packages
       @container = Container.find_not_deleted(params[:id])
      if @container.blank?
          render :json=>'{"stat":"err","msg":"Not found this container"}', status=>"200 ok"
          return
      else
       containerid = params[:id]
       @container_packages = ContainerPackage.all_notdeleted_by_containerid(containerid)
       
       #tansfer to appointed format to frontend
       packages_cnt = 0 #count the number of packages of container
       total_of_packages = @container_packages.length
       json_list = '{ "total":'+total_of_packages.to_s+',"rows":['
       rows_list = ''
       @container_packages.each do | package |
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


    def sync_missing_mt
       @container_1 = Container.find_not_deleted(params[:id])
      if @container_1.blank?
          render :json=>'{"stat":"err","msg":"Not found this container"}', status=>"200 ok"
          return
      else
       @container = @container_1[0]
       productid = @container.product_id
       @list_of_missing = ContainerPackage.get_missing_mt(@container.id)
       total_of_list = @list_of_missing.length
       filling_missing_cnt = 0 #count the number of filling  
       json_return = ''
       if  total_of_list > 0
       ContainerPackage.transaction do
       @list_of_missing.each do | miss_package |
           result = search_scotzilla_baseos(miss_package.name.downcase,miss_package.version.downcase,'BaseOS',@container.target)
           if result['stat'] == 'ok'
              filling_missing_cnt = filling_missing_cnt + 1
              ContainerPackage.update(miss_package,:mt_id => result['id'],:status => 1)
           end
       end    
       end #end RepoPackage.transaction do
       
       #update the status of Container to be done
       update_container_status(@container.id)

       #Observe if all children of product are done,if so, changing the status of product to be done.
       observe_product_status(productid)
              
         if filling_missing_cnt == total_of_list
	  json_return = '{"stat":"ok","msg":"Have already filed '+filling_missing_cnt.to_s+' MTs,total is '+total_of_list.to_s+' MTs for this Repo" }'
         else
	  json_return = '{"stat":"ok","msg":"Have already filed '+filling_missing_cnt.to_s+' for packages of missing MT, but still '+(total_of_list-filling_missing_cnt).to_s+' failed" }'
	 end

       else
        json_return = '{"stat":"ok","msg":"no missing MT for this Repo" }'  
       end #end if  total_of_list > 0
       render :json=>json_return, status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end

  
   def update_container_status(containerid)
       @container = Container.find(containerid)
       ct_status =@container.ct_status
       @list_of_missing = ContainerPackage.get_missing_mt(containerid)
       if @list_of_missing.length == 0 and  ct_status == 2
          Container.update(@container,:status => 1 )
       end
   end

    #observe product's status
    def observe_product_status(productid)
     #Observe if all children of product are done,if so, changing the status of product to be done.
      product_controller  = ProductsController.new
      product_controller.update_product_status(productid) 
    end
  
   #update container info
    def update_container_info
       @container = Container.find_not_deleted(params[:id])    
       if @container.blank?
          render :json=>'{"stat":"err","msg":"Not found this container"}', status=>"200 ok"
          return
       else
       productid = @container[0].product_id
       container = params[:container]
       @container[0].name = container[:name]
       @container[0].version = container[:version]
       @container[0].ct_status = container[:ct_status]
       @container[0].save
       update_container_status(@container[0].id)
       observe_product_status(productid)
       render :json=>'{"stat":"ok","msg":"Updating Container info is ok"}', status=>"200 ok"
       end
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end
  
    
end
