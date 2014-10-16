class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :model
      t.text :aliases
      t.text :possible_usernames
      t.text :possible_passwords
      t.text :possible_ips

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
