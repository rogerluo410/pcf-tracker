class InitialSchema < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      #t.string   :reset_password_token
      #t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      #t.integer  :sign_in_count, :default => 0
      #t.datetime :current_sign_in_at
      #t.datetime :last_sign_in_at
      #t.string   :current_sign_in_ip
      #t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token


      t.string  :name                     # display name
      t.boolean :admin, :null => false, :default => false # whether is system administrator
      t.integer :roles_mask, :default => 1
      t.integer :department_id
      t.string :authentication_token
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    #add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true

	  create_table :products do |t|
	    t.string   :name,                       :null => false
	    t.string   :version,                    :null => false
	    t.text     :bugzilla_url 
	    t.integer  :bugzilla_status,            :default => 0  
	    t.integer  :status,                     :default => 0
	    t.string   :release_date,               :null => false
	    t.string   :description
	    t.boolean  :deleted,                    :null => false, :default => false
	    t.timestamps
	  end

	  add_index :products, [:name,:version], :name => "index_products"

	  create_table :repos do |t|
	    t.string   :name,                                          :null => false
	    t.string   :version,                                       :null => false
	    t.integer  :mt_id,                                         :null => 0,:default => 0 
	    t.integer  :ut_id,                                         :null => 0,:default => 0
	    t.integer  :product_id,                                    :null => false
	    t.text     :bugzilla_url 
	    t.integer  :bugzilla_status,                               :default => 0
	    t.integer  :status,                                        :default => 0 
	    t.boolean  :deleted,                                       :null => false, :default => false
	    t.timestamps
	  end

	  add_index :repos, [:name,:version], :name => "index_repos"
          add_index :repos, :product_id, :name => "index_repos_productid"
	  

	  create_table :containers do |t|
	    t.string   :name,                                          :null => false
	    t.string   :version,                                       :null => false
	    t.integer  :product_id,                                    :null => false
            t.integer  :ct_status,                                     :default => 0
	    t.integer  :status,                                        :default => 0 
	    t.boolean  :deleted,                                       :null => false, :default => false
	    t.timestamps
	  end

	  add_index :containers, [:name,:version], :name => "index_containers"
          add_index :containers, :product_id, :name => "index_containers_productid"

	  create_table :repo_packages do |t|
	    t.string   :name,                                          :null => false
	    t.string   :version,                                       :null => false
	    t.integer  :mt_id,                                         :null => 0,:default => 0
	    t.integer  :ut_id,                                         :null => 0,:default => 0
	    t.integer  :repo_id,                                       :null => false
	    t.integer  :status,                                        :default => 0 
	    t.boolean  :deleted,                                       :null => false, :default => false
	    t.timestamps
	  end

	  add_index :repo_packages, [:name,:version], :name => "index_repo_packages"
          add_index :repo_packages, :repo_id, :name => "index_repo_packages_repoid"

          create_table :container_packages do |t|
	    t.string   :name,                                          :null => false
	    t.string   :version,                                       :null => false
	    t.integer  :mt_id,                                         :null => 0,:default => 0
	    t.integer  :ut_id,                                         :null => 0,:default => 0
	    t.integer  :container_id,                                  :null => false
	    t.integer  :status,                                        :default => 0 
	    t.boolean  :deleted,                                       :null => false, :default => false
	    t.timestamps
	  end

	  add_index :container_packages, [:name,:version], :name => "index_container_packages"
          add_index :container_packages, :container_id, :name => "index_repo_packages_containerid"

 end
end
