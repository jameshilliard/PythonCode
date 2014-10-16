# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110302202648) do

  create_table "connection_types", :force => true do |t|
    t.boolean  "wan_connection"
    t.string   "connection_description"
    t.string   "connection_initialization_command"
    t.string   "connection_verification_command"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connections_on_servers", :id => false, :force => true do |t|
    t.integer "connection_type_id", :null => false
    t.integer "test_server_id",     :null => false
  end

  add_index "connections_on_servers", ["connection_type_id", "test_server_id"], :name => "connections_available_on_server"

  create_table "cte", :id => false, :force => true do |t|
    t.integer "connection_type_id",     :null => false
    t.integer "testing_environment_id", :null => false
  end

  add_index "cte", ["connection_type_id", "testing_environment_id"], :name => "index_cte_on_connection_type_id_and_testing_environment_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "devices", :force => true do |t|
    t.string   "model"
    t.text     "aliases"
    t.text     "possible_usernames"
    t.text     "possible_passwords"
    t.text     "possible_ips"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_server_id"
  end

  create_table "devices_on_servers", :id => false, :force => true do |t|
    t.integer "device_id",      :null => false
    t.integer "test_server_id", :null => false
  end

  add_index "devices_on_servers", ["device_id", "test_server_id"], :name => "devices_attached_to_server"

  create_table "dte", :id => false, :force => true do |t|
    t.integer "device_id",              :null => false
    t.integer "testing_environment_id", :null => false
  end

  add_index "dte", ["device_id", "testing_environment_id"], :name => "index_dte_on_device_id_and_testing_environment_id"

  create_table "service_configurations", :force => true do |t|
    t.text     "server_states"
    t.text     "test_states"
    t.text     "override_states"
    t.integer  "server_fallback_state"
    t.integer  "server_default_state"
    t.boolean  "server_rdns_lookup"
    t.boolean  "server_requires_key"
    t.integer  "testsuite_max_steps"
    t.integer  "testsuite_min_steps"
    t.integer  "testsuite_default_state"
    t.integer  "testsuite_min_steps_server_assignment"
    t.boolean  "testsuite_wait_for_all"
    t.integer  "testcase_default_state"
    t.integer  "testcase_default_suite_state"
    t.boolean  "testcase_auto_push_results"
    t.integer  "timer_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_cases", :force => true do |t|
    t.integer  "testlink_testcase_id"
    t.integer  "testlink_testplan_id"
    t.integer  "testlink_project_id"
    t.string   "test_results"
    t.string   "testlink_build_version"
    t.integer  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_suite_id"
    t.string   "filename"
    t.string   "firmware_version"
    t.string   "device_type"
    t.text     "test_section"
    t.string   "test_log_location"
    t.integer  "step_count"
    t.text     "documentation"
    t.integer  "testlink_user_id"
    t.boolean  "reported",                 :default => false
    t.text     "testlink_report_response"
  end

  create_table "test_servers", :force => true do |t|
    t.string   "hostname"
    t.string   "ip"
    t.text     "system_config"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",           :limit => 32, :null => false
    t.string   "username"
    t.string   "password"
  end

  create_table "test_suites", :force => true do |t|
    t.string   "suite_name",                                :null => false
    t.string   "firmware_version",                          :null => false
    t.string   "device_type",                               :null => false
    t.string   "test_section",                              :null => false
    t.string   "test_log_location"
    t.boolean  "currently_running",      :default => false, :null => false
    t.integer  "result"
    t.boolean  "assigned",               :default => false, :null => false
    t.boolean  "review_required",        :default => false, :null => false
    t.boolean  "manual_override",        :default => false, :null => false
    t.integer  "test_server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "full_step_count"
    t.integer  "testing_environment_id"
  end

  create_table "testing_environments", :force => true do |t|
    t.string   "environment_name"
    t.text     "environment_description"
    t.string   "before_testing"
    t.string   "after_testing"
    t.string   "force_stop_command"
    t.string   "retrieve_results_command"
    t.boolean  "wait_for_test_completion"
    t.string   "start_command"
    t.string   "stop_command"
    t.string   "testsuite_build_command"
    t.string   "remote_working_directory"
    t.text     "environment_variables"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "testlink_projects", :force => true do |t|
    t.string   "project_name",     :null => false
    t.string   "project_id",       :null => false
    t.integer  "testlink_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "testlink_users", :force => true do |t|
    t.string   "username",                            :null => false
    t.string   "apikey",                              :null => false
    t.string   "server_address",                      :null => false
    t.boolean  "default",          :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "testlink_user_id"
  end

  create_table "timer_sets", :force => true do |t|
    t.integer  "test_suite_creation"
    t.integer  "test_server_timeout_state_change"
    t.integer  "test_case_update_interval"
    t.integer  "automatic_result_reporting_interval"
    t.integer  "test_suite_assignment_interval"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
