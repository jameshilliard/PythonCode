class CreateTestSuites < ActiveRecord::Migration
  def self.up
    create_table :test_suites do |t|
      t.string :suite_name, :null => false
      t.string :firmware_version, :null => false
      t.string :device_type, :null => false
      t.string :test_section, :null => false

      t.string :test_log_location
      t.boolean :currently_running, :null => false, :default => false
      t.boolean :result
      t.boolean :assigned, :null => false, :default => false
      t.boolean :review_required, :null => false, :default => false
      t.boolean :manual_override, :null => false, :default => false

      t.integer :server_id

      t.timestamps
    end
  end

  def self.down
    drop_table :test_suites
  end
end
