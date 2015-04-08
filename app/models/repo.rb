class Repo < ActiveRecord::Base
  attr_accessible :bugzilla_status, :bugzilla_url, :deleted, :mt_id, :name, :product_id, :status, :ut_id, :version

  INITIAL = 0
     DONE = 1

  NOT_APPLIED = 0
      APPLIED = 1
     APPROVED = 2
 
  NOT_DELETED = false
      DELETED = true

  STATUS_DESC = {
      INITIAL  => 'Initial product',
         DONE  => 'Repo has been finished'
  }

  BUGZILLA_STATUS_DESC = {
      NOT_APPLIED  =>  'Bugzilla product is still not applied',
          APPLIED  =>  'Bugzilla product is applied,waiting for approval',
         APPROVED  =>  'Bugzilla product is approved' 
  }

  DELETED_DESC = {
        NOT_DELETED => 'Repo is not deleted',
            DELETED => 'Repo has been deleted' 
  }

  has_many :packages, :class_name => 'RepoPackage', :dependent => :destroy
  belongs_to :product, :class_name => 'Product',:foreign_key => 'product_id'

  scope :not_deleted, where(:deleted => NOT_DELETED)
  scope :find_not_deleted,->(id) { where("id = ? and deleted = false ",id)}
  scope :all_notdeleted_by_productid, ->(product_id) { where("product_id = ?) and deleted = false", product_id) }

end
