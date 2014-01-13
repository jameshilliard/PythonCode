class CreateTestlinkUsers < ActiveRecord::Migration
  def self.up
    create_table :testlink_users do |t|
      t.string :username, :null => false
      t.string :apikey, :null => false
      t.string :server_address, :null => false
      t.integer :user_id
      t.integer :project_id
      t.string :project_name, :null => false
      t.boolean :default, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :testlink_users
  end
end
