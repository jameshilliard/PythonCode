class ChangeServerAttributes < ActiveRecord::Migration
  def self.up
    add_column(:servers, :username, :string)
    add_column(:servers, :password, :string)
    rename_column(:servers, :host, :hostname)
    remove_column(:servers, :firmware_version)
    remove_column(:servers, :device_type)
  end

  def self.down
    remove_column(:servers, :username)
    remove_column(:servers, :password)
    rename_column(:servers, :hostname, :host)
    add_column(:servers, :firmware_version, :string)
    add_column(:servers, :device_type, :string)
  end
end
