class Container < ActiveRecord::Base
  attr_accessible :deleted, :name, :product_id, :status, :version, :ct_status, :target

  INITIAL = 0
     DONE = 1
 
  NOT_DELETED = false
      DELETED = true

  STATUS_DESC = {
      INITIAL  => 'Initial product',
         DONE  => 'Container has been finished'
  }

  DELETED_DESC = {
        NOT_DELETED => 'Container is not deleted',
            DELETED => 'Container has been deleted' 
  }


  has_many :packages, :class_name => 'ContainerPackage', :dependent => :destroy
  belongs_to :product, :class_name => 'Product',:foreign_key => 'product_id'

  scope :not_deleted, where(:deleted => NOT_DELETED)
  scope :find_not_deleted,->(id) { where("id=#{id} and deleted = false ")}
  scope :all_notdeleted_by_productid, ->(product_id) { where("product_id=#{product_id} and deleted = false") }

end
