class ServerIdleChange < ActiveRecord::Migration
  def self.up
    rename_column(:servers, :idle, :state)
  end

  def self.down
    rename_column(:servers, :state, :idle)
  end
end
