class ServerIdleToState < ActiveRecord::Migration
  def self.up
    change_column(:servers, :idle, :integer)
  end

  def self.down
    change_column(:servers, :idle, :boolean)
  end
end
