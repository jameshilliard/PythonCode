class CreateTimerSets < ActiveRecord::Migration
  def self.up
    create_table :timer_sets do |t|
      t.integer :test_suite_creation, :test_server_timeout_state_change, :test_case_update_interval, :automatic_result_reporting_interval, :test_suite_assignment_interval
      t.string :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :timer_sets
  end
end