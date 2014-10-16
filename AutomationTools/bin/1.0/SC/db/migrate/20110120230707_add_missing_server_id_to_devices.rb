class AddMissingServerIdToDevices < ActiveRecord::Migration
  def self.up
    add_column(:devices, :server_id, :integer)
  end

  def self.down
    remove_column(:devices, :server_id, :integer)
  end
end
