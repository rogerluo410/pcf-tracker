
class RepoPackage < ActiveRecord::Base
  attr_accessible :deleted, :mt_id, :name, :repo_id, :status, :ut_id, :version

  INITIAL = 0
     DONE = 1
 
  NOT_DELETED = false
      DELETED = true

  STATUS_DESC = {
      INITIAL  => 'Initial product',
         DONE  => 'Package has been finished'
  }

  DELETED_DESC = {
        NOT_DELETED => 'Package is not deleted',
            DELETED => 'Package has been deleted' 
  }

  belongs_to :repo, :class_name => 'Repo',:foreign_key => 'repo_id'

  scope :not_deleted, where(:deleted => NOT_DELETED)
  scope :find_not_deleted,->(id) { where("id=#{id} and deleted = false ")}
  scope :all_notdeleted_by_repoid, ->(repo_id) { where("repo_id=#{repo_id} and deleted = false" ).order('name,id desc') }
  scope :all_no_ut_by_repoid, ->(repo_id) { where("repo_id=#{repo_id} and ut_id =0 and deleted = false" ).order('name,id desc') }
  scope :get_missing_mt,->(repo_id) { where("repo_id=#{repo_id} and deleted = false and mt_id = 0 " ).order('name,id desc') }
  scope :get_pkgs_undone_status, ->(repo_id) {  where("repo_id=#{repo_id} and deleted = false and status = 0 " ).order('name,id desc')  }
   scope :find_by_name, ->(name,version,repo_id) { where("name='#{name}' and version = '#{version}' and repo_id = #{repo_id} and deleted = false ") } 
  
end
