# == Schema Information
# Schema version: 20110203190610
#
# Table name: connection_types
#
#  id                                :integer(4)      not null, primary key
#  wan_connection                    :boolean(1)
#  connection_description            :string(255)
#  connection_initialization_command :string(255)
#  connection_verification_command   :string(255)
#  created_at                        :datetime
#  updated_at                        :datetime
#

class ConnectionType < ActiveRecord::Base
  has_and_belongs_to_many :test_server, :join_table => :connections_on_servers
  has_and_belongs_to_many :testing_environments, :join_table => :cte
end
