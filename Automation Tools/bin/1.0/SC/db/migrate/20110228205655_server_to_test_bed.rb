class ServerToTestBed < ActiveRecord::Migration
  def self.up
    rename_table(:servers, :test_servers)
  end

  def self.down
    rename_table(:test_servers, :servers)
  end
end
