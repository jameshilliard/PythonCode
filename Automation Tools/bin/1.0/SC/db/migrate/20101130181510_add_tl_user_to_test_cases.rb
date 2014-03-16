class AddTlUserToTestCases < ActiveRecord::Migration
  def self.up
    add_column(:test_cases, :testlink_user_id, :integer)
  end

  def self.down
    remove_column(:test_cases, :testlink_user_id)
  end
end
