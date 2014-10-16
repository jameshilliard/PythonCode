class TlUserId < ActiveRecord::Migration
  def self.up
    add_column(:testlink_users, :testlink_user_id, :integer)
  end

  def self.down
    remove_column(:testlink_users, :testlink_user_id)
  end
end
