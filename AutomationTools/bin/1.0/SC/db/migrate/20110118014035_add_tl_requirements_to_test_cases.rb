class AddTlRequirementsToTestCases < ActiveRecord::Migration
  def self.up
    add_column(:test_cases, :reported, :boolean, :default => false)
    add_column(:test_cases, :testlink_report_response, :text)
  end

  def self.down
    remove_column(:test_cases, :reported)
    remove_column(:test_cases, :testlink_report_response)
  end
end
