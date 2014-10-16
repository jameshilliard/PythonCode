class CreateConnectionTypes < ActiveRecord::Migration
  def self.up
    create_table :connection_types do |t|
      # True if this connection is a WAN connection, otherwise it is considered LAN
      t.boolean :wan_connection
      # This is a simple description string, like COAX, or Ethernet, or 802.11g
      t.string :connection_description
      
      # Initialization options, these are not required, but are nice to have.
      # Both commands should return a positive - Verification should run first, and only
      # when a connection is not available should the initialization command be run (saves times)
      t.string :connection_initialization_command
      t.string :connection_verification_command
      # These will run *after* the "before_testing" command within the test environment this is attached to
      t.timestamps
    end

    # join table for HABTM for servers and connection types
    create_table(:connections_on_servers, :id => false) do |t|
      t.integer :connection_type_id, :null => false
      t.integer :server_id, :null => false
    end
    add_index(:connections_on_servers, [:connection_type_id, :server_id])
    # Join table for HABTM with testing environments
    create_table(:cte, :id => false) do |t|
      t.integer :connection_type_id, :null => false
      t.integer :testing_environment_id, :null => false
    end
    add_index(:cte, [:connection_type_id, :testing_environment_id])
  end

  def self.down
    drop_table :connections_on_servers
    drop_table :connection_types
    remove_index :cte
    remove_index :connections_on_servers
  end
end