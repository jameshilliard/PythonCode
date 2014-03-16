class CreateServers < ActiveRecord::Migration
    def self.up
        create_table :servers do |t|
            t.string :host, :ip, :connected_to
            t.text :system_config
            t.boolean :idle
            t.timestamps
        end
    end

    def self.down
        drop_table :servers
    end
end
