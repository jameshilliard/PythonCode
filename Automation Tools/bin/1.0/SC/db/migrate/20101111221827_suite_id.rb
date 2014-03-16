class SuiteId < ActiveRecord::Migration
  def self.up
    # test case additions and removals
    add_column(:test_cases, :suite_id, :integer)
    add_column(:test_cases, :filename, :string)
    add_column(:test_cases, :firmware_version, :string)
    add_column(:test_cases, :device_type, :string)
    add_column(:test_cases, :test_section, :string)
    add_column(:test_cases, :test_log_location, :string)

    remove_column(:test_cases, :server_id)
    remove_column(:test_cases, :testlink_testsuite_id)
    remove_column(:test_cases, :testlink_build_id)
    remove_column(:test_cases, :testlink_platform_id)

    # server additions and removals
    add_column(:servers, :firmware_version, :string)
    add_column(:servers, :device_type, :string)
    remove_column(:servers, :connected_to)
  end

  def self.down
    # test cases
    remove_column(:test_cases, :suite_id)
    remove_column(:test_cases, :filename)
    remove_column(:test_cases, :firmware_version)
    remove_column(:test_cases, :device_type)
    remove_column(:test_cases, :test_section)
    remove_column(:test_cases, :test_log_location)

    add_column(:test_cases, :server_id, :integer)
    add_column(:test_cases, :testlink_testsuite_id, :integer)
    add_column(:test_cases, :testlink_build_id, :integer)
    add_column(:test_cases, :testlink_platform_id, :integer)

    # servers
    remove_column(:servers, :firmware_version)
    remove_column(:servers, :device_type)
    add_column(:servers, :connected_to, :string)
  end
end
