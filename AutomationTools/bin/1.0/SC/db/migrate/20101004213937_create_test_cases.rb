class CreateTestCases < ActiveRecord::Migration
    def self.up
        create_table :test_cases do |t|
            t.integer :server_id, :testlink_testcase_id, :testlink_testsuite_id, :testlink_build_id, :testlink_testplan_id, :testlink_project_id, :testlink_platform_id
            t.string :test_results, :testlink_build_version
            t.boolean :result, :tested

            t.timestamps
        end
    end

    def self.down
        drop_table :test_cases
    end
end
