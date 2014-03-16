class ServersDevicesJoinTable < ActiveRecord::Migration
  def self.up
    create_table(:devices_on_servers, :id => false) do |t|
      t.integer :device_id, :null => false
      t.integer :server_id, :null => false
    end
    add_index(:devices_on_servers, [:device_id, :server_id])
  end

  def self.down
    drop_table :devices_servers
    remove_index(:devices_servers)
  end
end
