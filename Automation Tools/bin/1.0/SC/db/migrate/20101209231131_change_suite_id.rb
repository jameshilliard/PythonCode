class ChangeSuiteId < ActiveRecord::Migration
  def self.up
    rename_column(:test_cases, :suite_id, :test_suite_id)
  end

  def self.down
    rename_column(:test_cases, :test_suite_id, :suite_id)
  end
end
