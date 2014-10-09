class ProductsController < ApplicationController

  def index
     @products = Product.not_deleted 
     @product = Product.new
     @json_list = '['
     individual = ''
     products_length = @products.length
     prod_cnt = 0  #count the number of products 
      #transfer to appointed json format 
     @products.each do|product|
       @listofprod = @product.list_of_product(product.id)
        list_length = @listofprod.length
        children_cnt = 0 #count the number of children of products
        prod_cnt = prod_cnt + 1
        state = ''
        if product.status == 0
         state = 'open'
        else
         state = 'closed'
        end
        individual =individual + '{"id":"'+product.id.to_s+'","text":"'+product.name+' '+product.version+'","state":"'+state+'"' 
        #Check if the product is an empty product,no repos and containers is inside it. 
        if list_length > 0
            individual =individual + ',"children":['
          @listofprod.each do |child|
             children_cnt = children_cnt + 1
             category = ''
             if child.category == 'VMWsource'
             category = 'CF-Component'
             else
             category = 'BaseOS'
             end
             individual = individual +'{"text":"'+child.name+'","id":"'+child.id.to_s+'","attributes":{"data":"'+child.category+'"},"checked":true}'
             if  children_cnt <= list_length - 1
                individual = individual + ' , ' # add comma 
             end
          end # end  @listofprod.each do |child|      
             individual = individual + ' ] }'
             if  prod_cnt <= products_length - 1
                individual = individual + ' , ' # add comma 
             end
         else
             individual = individual + ',"children":[{"text":"No children"}] }'
             if  prod_cnt <= products_length - 1
                individual = individual + ' , ' # add comma 
             end
         end #end if list_length > 0
      end #end @products.each do|product|   
      @json_list = @json_list + individual + ' ] '
     render :json=>@json_list
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok" 
  end

  def repo_total_func
     @product = Product.find(params[:id])
     @repo_total = @product.repo_total_rate(@product.id)
     @repo_total.each do |total|
       puts total.count
     end
     puts @repo_total
     render :json=>@repo_total , status=>"200" 
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end

  def container_total_func
     @product = Product.find(params[:id])
     @container_total = @product.container_total_rate(@product.id)
     render :json=>@container_total , status=>"200 ok"
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end
  
  def repo_mt_total_func
     @product = Product.find(params[:id])
     @mt_total = @product.repo_mt_total_rate(@product.id)
     render :json=>@mt_total , status=>"200 ok"
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end

  def repo_ut_total_func
     @product = Product.find(params[:id])
     @ut_total = @product.repo_ut_total_rate(@product.id)
     render :json=>@ut_total , status=>"200 ok"
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end

  def show
     @product = Product.find(params[:id])
     render :json=>@product , status=>"200 ok"    
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end

  #show repo list of product
  #def list_of_product
  #   @product = Product.find(params[:id])
  #   @listofprod = @product.list_of_product(@product.id)
  #   render :json=>@listofprod , status=>"200 ok"     
  #end
 
  def create
     @product = Product.new params[:product]
     @product.save
     render :json=>'{"stat":"ok","msg":"Creating product is ok"}', status=>"200 ok"  
     rescue ActiveRecord::RecordInvalid => invalid
     render :json=>'{"stat":"err","msg":"'+invalid.record.errors+'"}' , status=>"200 ok"
  end 
 
  #show details of each repo of product
  def repo_details_of_product
     @product = Product.find(params[:id])
     @listofprod = @product.list_of_product(@product.id)
     total_length = @listofprod.length
     children_count = 0  
     json_return = '{"total":'+@listofprod.length.to_s+',"rows":[ '
     json_part = ''
     #to be continued   
     @listofprod.each do | child |  
          children_count = children_count + 1
          if child.category =='VMWsource'
             repo_mt_rate = @product.each_repo_mt_total_rate(@product.id,child.id)
             repo_ut_rate = @product.each_repo_ut_total_rate(@product.id,child.id)
             mt_done_cnt = repo_mt_rate[0].count.to_i
             mt_undone_cnt = repo_mt_rate[1].count.to_i
             ut_done_cnt = repo_ut_rate[0].count.to_i
             ut_undone_cnt = repo_ut_rate[1].count.to_i
             #assemble mt
             total_mt = mt_done_cnt + mt_undone_cnt
             puts "total:"+total_mt.to_s 
             done_mt = mt_done_cnt
             mt_done_rate = 0
             if done_mt > 0 and total_mt > 0
             mt_done_rate = (done_mt.to_f*100).round / total_mt
             end
             mt_str = done_mt.to_s+'/'+total_mt.to_s+'('+mt_done_rate.to_s+'%)'
             #assemble ut
             total_ut = ut_done_cnt + ut_undone_cnt
             done_ut = ut_done_cnt
             ut_done_rate = 0
             if done_ut > 0 and total_ut > 0
             ut_done_rate = (done_ut.to_f*100).round / total_ut
             end
             ut_str = done_ut.to_s+'/'+total_ut.to_s+'('+ut_done_rate.to_s+'%)'
             #assemble bugzilla status
             status = ''
             if child.status == 0
                status = 'Not applied'
             elsif child.status == 1
                status = 'Applied'
             else
                status = 'Approved'
             end
             #mt_id and ut_id of repo
             mt_id = child.mt_id.to_s
             ut_id = child.ut_id.to_s
             if child.name == 'PivotalCF'
               mt_id = 'None'
               ut_id = 'None'
             end
             json_part ='{"id":"'+child.id.to_s+'","name":"'+child.name+'","mt_status":"'+mt_str+'","ut_status":"'+ut_str+'","bugzilla_status":"'+status+'","add_mt":"'+mt_id+'","add_ut":"'+ut_id+'","category":"VMWsource"}'
          else #BaseOS
             container_mt_rate = @product.each_container_total_rate(@product.id,child.id)
             mt_done_cnt = container_mt_rate[0].count.to_i
             mt_undone_cnt = container_mt_rate[1].count.to_i
             #assemble mt
             total_mt = mt_done_cnt + mt_undone_cnt
             done_mt = mt_done_cnt
             mt_done_rate = 0
             if done_mt > 0 and total_mt > 0
             mt_done_rate = (done_mt.to_f * 100).round / total_mt
             end
             mt_str = done_mt.to_s+'/'+total_mt.to_s+'('+mt_done_rate.to_s+'%)'
             #assemble ct status
             status = ''
             if child.status == 0
                status = 'Not applied'
             elsif child.status == 1
                status = 'Applied'
             else
                status = 'Approved'
             end
             #mt_id of container is empty
             mt_id ='None'
             ut_id ='None'
             json_part ='{"id":"'+child.id.to_s+'","name":"'+child.name+'","mt_status":"'+mt_str+'","ut_status":"0/0(0%)","bugzilla_status":"'+status+'","add_mt":"'+mt_id+'","add_ut":"'+ut_id+'","category":"BaseOS"}'
          end #baseos
          if  children_count <=   total_length - 1
              json_part = json_part + ','
          end
         json_return  = json_return  + json_part
     end #end @listofprod.each do | child |
     json_return = json_return + '] }'
     render :json=>json_return, status=>"200 ok"
     rescue ActiveRecord::RecordNotFound
     render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
  end

  #update product status to be done
  def update_product_status(productid)
      @product = Product.find(productid)
      total = @product.count_number_undone(productid)
      puts "total[0].sum :"+ total[0].sum.to_s
      puts "@product.bugzilla_status :"+ @product.bugzilla_status.to_s
      if total[0].sum == '0' and @product.bugzilla_status == 2
          puts "Update product to be done"
          Product.update(@product,:status => 1 )
      else
       puts "Still be undone"
       Product.update(@product,:status => 0 ) 
      end
  end

  #update product info
    def update_product_info
       @product = Product.find(params[:id]) 
       puts @product.release_date
       product = params[:product]
       @product.name = product[:name] 
       @product.version = product[:version]
       @product.bugzilla_url = product[:bugzilla_url]
       @product.bugzilla_status = product[:bugzilla_status]
       @product.release_date = product[:release_date]
       @product.description = product[:description]
       @product.save
       #activate to observe status 
       update_product_status(@product.id)
       render :json=>'{"stat":"ok","msg":"Updating product info is ok"}', status=>"200 ok"
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
    end
   
   #get the latest product to frontend
   def get_latest_product
       @product = Product.latest_product
       render :json=>@product, status=>"200 ok"
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
   end 

   #update package's MT 
   def update_package
       @product = Product.find(params[:id])
       modify_info = params[:modify]
       category = modify_info[:category]
       package_id = modify_info[:package_id] 
       mt_id = modify_info[:mt_id]
       ut_id = modify_info[:ut_id]
       if category == 'VMWsource' 
           @repo_package = RepoPackage.find_not_deleted(package_id)
           if @repo_package.blank?
            render :json=>'{"stat":"err","msg":"Not found this package,please refresh the page"}'
            return
           end
           if mt_id.to_i > 0 
           @repo_package[0].mt_id = mt_id.to_i
           end
           if ut_id.to_i > 0
           @repo_package[0].ut_id = ut_id.to_i
           end
           if @repo_package[0].mt_id > 0 and @repo_package[0].ut_id > 0
              @repo_package[0].status = 1
           end
           @repo_package[0].save
       elsif category == 'BaseOS'
           @container_package = ContainerPackage.find_not_deleted(package_id)
           puts @container_package[0].name
           if @container_package.blank?
              render :json=>'{"stat":"err","msg":"Not found this package,please refresh the page"}'
              return
           end
           if mt_id.to_i > 0
             @container_package[0].mt_id = mt_id.to_i
             @container_package[0].status = 1 
           end
           @container_package[0].save
       end
       render :json=>'{"stat":"ok","msg":"Updating MT/UT is ok"}'
       rescue ActiveRecord::RecordNotFound
       render :json=>'{"stat":"err","msg":"Invalid parameters"}' , status=>"200 ok"
   end


end
