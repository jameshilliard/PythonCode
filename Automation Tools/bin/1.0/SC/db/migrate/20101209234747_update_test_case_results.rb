class UpdateTestCaseResults < ActiveRecord::Migration
  def self.up
    change_column(:test_cases, :result, :integer)
    add_column(:test_suites, :full_step_count, :integer)
  end

  def self.down
    change_column(:test_cases, :result, :boolean)
    remove_column(:test_suites, :full_step_count)
  end
end
