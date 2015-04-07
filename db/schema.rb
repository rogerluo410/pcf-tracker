# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140806025537) do

  create_table "container_packages", :force => true do |t|
    t.string   "name",                            :null => false
    t.string   "version",                         :null => false
    t.integer  "mt_id",        :default => 0
    t.integer  "ut_id",        :default => 0
    t.integer  "container_id",                    :null => false
    t.integer  "status",       :default => 0
    t.boolean  "deleted",      :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "container_packages", ["container_id"], :name => "index_repo_packages_containerid"
  add_index "container_packages", ["name", "version"], :name => "index_container_packages"

  create_table "containers", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "version",                       :null => false
    t.integer  "product_id",                    :null => false
    t.integer  "ct_status",  :default => 0
    t.integer  "status",     :default => 0
    t.boolean  "deleted",    :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "target"
  end

  add_index "containers", ["name", "version"], :name => "index_containers"
  add_index "containers", ["product_id"], :name => "index_containers_productid"

  create_table "products", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "version",                            :null => false
    t.text     "bugzilla_url"
    t.integer  "bugzilla_status", :default => 0
    t.integer  "status",          :default => 0
    t.string   "release_date",                       :null => false
    t.string   "description"
    t.boolean  "deleted",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "products", ["name", "version"], :name => "index_products"

  create_table "repo_packages", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "version",                       :null => false
    t.integer  "mt_id",      :default => 0
    t.integer  "ut_id",      :default => 0
    t.integer  "repo_id",                       :null => false
    t.integer  "status",     :default => 0
    t.boolean  "deleted",    :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "repo_packages", ["name", "version"], :name => "index_repo_packages"
  add_index "repo_packages", ["repo_id"], :name => "index_repo_packages_repoid"

  create_table "repos", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "version",                            :null => false
    t.integer  "mt_id",           :default => 0
    t.integer  "ut_id",           :default => 0
    t.integer  "product_id",                         :null => false
    t.text     "bugzilla_url"
    t.integer  "bugzilla_status", :default => 0
    t.integer  "status",          :default => 0
    t.boolean  "deleted",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "repos", ["name", "version"], :name => "index_repos"
  add_index "repos", ["product_id"], :name => "index_repos_productid"

  create_table "users", :force => true do |t|
    t.string   "email",                :default => "",    :null => false
    t.string   "encrypted_password",   :default => "",    :null => false
    t.datetime "remember_created_at"
    t.string   "name"
    t.boolean  "admin",                :default => false, :null => false
    t.integer  "roles_mask",           :default => 1
    t.integer  "department_id"
    t.string   "authentication_token"
    t.boolean  "deleted",              :default => false, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
