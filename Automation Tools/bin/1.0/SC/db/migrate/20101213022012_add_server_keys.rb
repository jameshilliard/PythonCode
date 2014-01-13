class AddServerKeys < ActiveRecord::Migration
  def self.up
    add_column(:servers, :key, :string, :limit => 32, :null => false)
  end

  def self.down
    remove_column(:servers, :key, :string)
  end
end
