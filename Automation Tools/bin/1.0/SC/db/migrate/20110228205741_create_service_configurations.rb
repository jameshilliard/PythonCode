class CreateServiceConfigurations < ActiveRecord::Migration
  def self.up
    rename_column(:connections_on_servers, :server_id, :test_server_id)
    remove_index(:connections_on_servers, :name => "index_connections_on_servers_on_connection_type_id_and_server_id")
    add_index "connections_on_servers", ["connection_type_id", "test_server_id"], :name => :connections_available_on_server

    rename_column(:devices, :server_id, :test_server_id)
    rename_column(:devices_on_servers, :server_id, :test_server_id)
    remove_index(:devices_on_servers, :name => "index_devices_on_servers_on_device_id_and_server_id")
    add_index "devices_on_servers", ["device_id", "test_server_id"], :name => :devices_attached_to_server
    
    rename_column(:test_suites, :server_id, :test_server_id)

    create_table :service_configurations do |t|
      t.text :server_states, :test_states, :override_states
      t.integer :server_fallback_state, :server_default_state
      t.boolean :server_rdns_lookup, :server_requires_key
      t.integer :testsuite_max_steps, :testsuite_min_steps, :testsuite_default_state, :testsuite_min_steps_server_assignment
      t.boolean :testsuite_wait_for_all
      t.integer :testcase_default_state, :testcase_default_suite_state
      t.boolean :testcase_auto_push_results
      t.integer :timer_set_id
      t.timestamps
    end
  end

  def self.down
    drop_table :service_configurations

    rename_column(:connections_on_servers, :test_server_id, :server_id)
    remove_index(:connections_on_servers, :name => "index_connections_on_servers_on_connection_type_id_and_test_server_id")
    add_index "connections_on_servers", ["connection_type_id", "server_id"], :name => "index_connections_on_servers_on_connection_type_id_and_server_id"

    rename_column(:devices, :test_server_id, :server_id)
    rename_column(:devices_on_servers, :test_server_id, :server_id)
    remove_index(:devices_on_servers, :name => "index_devices_on_servers_on_device_id_and_server_id")
    add_index "devices_on_servers", ["device_id", "server_id"], :name => "index_devices_on_servers_on_device_id_and_test_server_id"

    rename_column(:test_suites, :test_server_id, :server_id)
  end
end