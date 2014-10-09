class Product < ActiveRecord::Base
  attr_accessible :name, :version, :bugzilla_url, :bugzilla_status, :status, :release_date, :description, :deleted
  
  # product status constants
  INITIAL = 0
     DONE = 1

  NOT_APPLIED = 0
      APPLIED = 1
     APPROVED = 2
 
  NOT_DELETED = false
      DELETED = true

  STATUS_DESC = {
      INITIAL  => 'Initial product',
         DONE  => 'Product has been finished'
  }

  BUGZILLA_STATUS_DESC = {
      NOT_APPLIED  =>  'Bugzilla product is still not applied',
          APPLIED  =>  'Bugzilla product is applied,waiting for approval',
         APPROVED  =>  'Bugzilla product is approved' 
  }

  DELETED_DESC = {
        NOT_DELETED => 'Product is not deleted',
            DELETED => 'Product has been deleted' 
  }
  
  has_many :repos, :class_name => 'Repo', :dependent => :destroy
  has_many :containers, :class_name => 'Container', :dependent => :destroy

  scope :not_deleted, where(:deleted => NOT_DELETED)
  scope :latest_product, where('deleted = false').order('created_at desc').limit(1)

  #fetch undone children of product
  def count_number_undone(productid)
     total = Product.find_by_sql("select sum(cnt) from (select count(1) cnt from repos where product_id = "+productid.to_s+" and deleted = false and status = 0 union all
select count(1) cnt from containers where product_id = "+productid.to_s+" and deleted = false and status = 0 ) a")
     return total
  end

  def repo_total_rate(productid)
    repo_total  = Product.find_by_sql("select count(*),'Done' title from repos where product_id = "+productid.to_s+" and deleted =  false and status = 1  union all
       select count(*),'Undone' title from repos where product_id = "+productid.to_s+" and deleted =  false and status = 0")
    return repo_total
  end

 
  def container_total_rate(productid)
      container_total = Product.find_by_sql("select count(1),'Done' title from container_packages,(select id from containers where product_id = "+productid.to_s+" and deleted =false) containerid_list   
where container_packages.deleted =  false and container_packages.status = 1 and containerid_list.id = container_packages.container_id
union all 
select count(1),'Undone' title from container_packages,(select id from containers where product_id = "+productid.to_s+" and deleted =false) containerid_list   
where container_packages.deleted =  false and container_packages.status = 0 and containerid_list.id = container_packages.container_id")
      return container_total 
  end

  def repo_mt_total_rate(productid)
      mt_total = Product.find_by_sql("select count(1),'Done' title from repo_packages,(select id from repos where product_id = "+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.mt_id > 0 and repo_list.id = repo_packages.repo_id
union all 
select count(1),'Undone' title from repo_packages,(select id from repos where product_id = "+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.mt_id = 0 and repo_list.id = repo_packages.repo_id")
     return mt_total
  end

  def repo_ut_total_rate(productid)
      ut_total = Product.find_by_sql("select count(1),'Done' title from repo_packages , (select id from repos where product_id ="+productid.to_s+" and deleted =false) repo_list  
where repo_packages.deleted =  false and repo_packages.ut_id > 0 and repo_list.id = repo_packages.repo_id
union all 
select count(1),'Undone' title from repo_packages,(select id from repos where product_id ="+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.ut_id = 0 and repo_list.id = repo_packages.repo_id")
     return ut_total
  end

    def each_repo_mt_total_rate(productid,repoid)
      mt_total = Product.find_by_sql("select count(1),'Done' title from repo_packages,(select id from repos where id = "+repoid.to_s+" and product_id = "+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.mt_id > 0 and repo_list.id = repo_packages.repo_id
union all 
select count(1),'Undone' title from repo_packages,(select id from repos where id = "+repoid.to_s+" and product_id = "+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.mt_id = 0 and repo_list.id = repo_packages.repo_id")
     return mt_total
  end

  def each_repo_ut_total_rate(productid,repoid)
      ut_total = Product.find_by_sql("select count(1),'Done' title from repo_packages , (select id from repos where id = "+repoid.to_s+" and product_id ="+productid.to_s+" and deleted =false) repo_list  
where repo_packages.deleted =  false and repo_packages.ut_id > 0 and repo_list.id = repo_packages.repo_id
union all 
select count(1),'Undone' title from repo_packages,(select id from repos where id = "+repoid.to_s+" and product_id ="+productid.to_s+" and deleted =false) repo_list   
where repo_packages.deleted =  false and repo_packages.ut_id = 0 and repo_list.id = repo_packages.repo_id")
     return ut_total
  end

  def each_container_total_rate(productid,containerid)
      container_total = Product.find_by_sql("select count(1),'Done' title from container_packages,(select id from containers where id = "+containerid.to_s+" and product_id = "+productid.to_s+" and deleted =false) containerid_list   
where container_packages.deleted =  false and container_packages.status = 1 and containerid_list.id = container_packages.container_id
union all 
select count(1),'Undone' title from container_packages,(select id from containers where id = "+containerid.to_s+" and product_id = "+productid.to_s+" and deleted =false) containerid_list   
where container_packages.deleted =  false and container_packages.status = 0 and containerid_list.id = container_packages.container_id")
      return container_total 
  end


  def list_of_product(productid)
      listofprod = Product.find_by_sql("select * from (select  id,name,status,'VMWsource' category,mt_id,ut_id,bugzilla_url,bugzilla_status status ,created_at from repos where product_id = "+productid.to_s+" and deleted =false union all
select  id,name,status,'BaseOS' category,null,null,null,ct_status status, created_at  from containers where product_id = "+productid.to_s+" and deleted =false ) a order by category ,created_at desc ")
      return listofprod    
  end

end
