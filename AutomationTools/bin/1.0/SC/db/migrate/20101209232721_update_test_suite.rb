class UpdateTestSuite < ActiveRecord::Migration
  def self.up
    change_column(:test_suites, :result, :integer)
  end

  def self.down
    change_column(:test_suites, :result, :boolean)
  end
end
