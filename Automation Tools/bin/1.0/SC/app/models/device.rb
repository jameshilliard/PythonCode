# == Schema Information
# Schema version: 20110120230707
#
# Table name: devices
#
#  id                 :integer(4)      not null, primary key
#  model              :string(255)
#  aliases            :text
#  possible_usernames :text
#  possible_passwords :text
#  possible_ips       :text
#  created_at         :datetime
#  updated_at         :datetime
#  server_id          :integer(4)
#

class Device < ActiveRecord::Base
  has_and_belongs_to_many :test_server, :join_table => :devices_on_servers
  has_and_belongs_to_many :testing_environments, :join_table => :dte
  serialize :aliases, Array
  serialize :possible_usernames, Array
  serialize :possible_passwords, Array
  serialize :possible_ips, Array
end
