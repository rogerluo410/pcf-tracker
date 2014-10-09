class AddColumn < ActiveRecord::Migration
  def up
     add_column :containers,:target, :string, :default => nil
  end

  def down
  end
end
