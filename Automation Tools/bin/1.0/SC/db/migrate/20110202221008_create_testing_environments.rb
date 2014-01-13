class CreateTestingEnvironments < ActiveRecord::Migration
  def self.up
    create_table :testing_environments do |t|
      # Common descriptors
      t.string :environment_name # Description name of the environment
      t.text :environment_description # Description of what the environment will try to accomplish

      # Commands to be run (before and after, obviously)
      # Along with special circumstance commands - for instance
      # if we do a forced stop on the server, and items need to be cleaned up before
      # using it again.
      # These should all be single line commands! Use shell scripts to introduce a large set if needed. 
      t.string :before_testing
      t.string :after_testing
      t.string :force_stop_command
      
      # We would hope the framework would return the results when done, or during testing as specified, however
      # if we need to, we will do polling here and retrieve results on a case by case basis, or by
      # the full result at the end if it's demanded to wait for full test suite completion (in which it will run
      # after server state changes.) 
      t.string :retrieve_results_command
      # If we want to control this, we will refuse results until the server state is changed to pending
      t.boolean :wait_for_test_completion
      
      # What to run to create a test suite for the system, run the test, and where to do this from on the remote system.
      # Each system should have a way to start the testing, and a way to stop testing forcefully. This
      # could be something simple like a daemon needing to be called with a "stop" parameter, or something forceful
      # like a kill script.
      # These should all be single line commands! Use shell scripts to introduce a large set if needed. 
      t.string :start_command
      t.string :stop_command
      t.string :testsuite_build_command
      t.string :remote_working_directory

      # Serialized array of environment variables that need to be set for the testing system to actually work.
      # These variables will be set on the shell before executing the "before_testing" command. They can be included in
      # a script instead and executed in the before testing option, or if that functionality does not work, then this is
      # provided. 
      t.text :environment_variables

      t.timestamps
    end
    add_column(:test_suites, :testing_environment_id, :integer)

    # Join table for HABTM on devices
    # This will simplify the association process later
    create_table(:dte, :id => false) do |t|
      t.integer :device_id, :null => false
      t.integer :testing_environment_id, :null => false
    end
    add_index(:dte, [:device_id, :testing_environment_id])
  end

  def self.down
    drop_table :testing_environments
    remove_index :dte
    remove_column(:test_suites, :testing_environment_id)
  end
end
