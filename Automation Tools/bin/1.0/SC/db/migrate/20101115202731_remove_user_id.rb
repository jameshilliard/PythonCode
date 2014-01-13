class RemoveUserId < ActiveRecord::Migration
  def self.up
    remove_column(:testlink_users, :user_id)
  end

  def self.down
    add_column(:testlink_users, :user_id, :integer)
  end
end
