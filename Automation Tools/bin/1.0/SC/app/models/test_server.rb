# == Schema Information
# Schema version: 20110120222820
#
# Table name: servers
#
#  id            :integer(4)      not null, primary key
#  hostname      :string(255)
#  ip            :string(255)
#  system_config :text
#  state         :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  key           :string(32)      not null
#  username      :string(255)
#  password      :string(255)
#

class TestServer < ActiveRecord::Base
  has_one :test_suite, :dependent => :nullify
  has_many :test_cases, :through => :test_suite
  has_and_belongs_to_many :devices, :join_table => :devices_on_servers
  has_and_belongs_to_many :connection_types, :join_table => :connections_on_servers

  validates :ip, :presence => true, :format => { :with => /^(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}$/, :message => "Invalid IP address" }, :uniqueness => true
  validates :key, :presence => true, :uniqueness => true
  
  scope :running, where(:state => 2)
  scope :reserved, where(:state => 3)
  scope :available, where(:state => 1)

  before_validation :create_server_key
  after_validation :get_server_info

  # Virtual attributes
  def skip_setup=(value)
    @skip_setup = (value.to_i == 1 ? true : false)
  end
  def fake_server=(value)
    @fake_server = (value.to_i == 1 ? true : false)
  end
  
  # Returns status of servers to Available if it's stuck on Pending
  def self.server_state_update
    Server.all.each { |serv| serv.update_attribute(:state, SERVER_STATES.index("Available")) if serv.state == SERVER_STATES.index("Pending") && serv.test_suite.nil? }
  end

  # Returns first available server with matching device type and that is currently
  # free (no test suite assigned.) Case insensitive since we convert it to lower case.
  def self.find_free_server(device_type)
    TestServer.available.each do |serv|
      serv.devices.each do |dev|
        # Check model name directly
        return serv if dev.model.downcase == device_type.downcase
        # Check aliases
        return serv unless dev.aliases.select {|d| d.downcase == device_type.downcase}.empty?
      end
    end
    # Return nil if no free server was found
    return nil
  end
  
  private
  def create_server_key
    self.key = Digest::MD5.hexdigest("#{self.ip}#{Time.now}")
  end

  # Gets server information
  # Things here will eventually be pushed to an alternative method outside of the controller for modularity sakes
  def get_server_info
    # No point in running different command sets here as it's just redundant since we do everything
    # in a straight forward fashion. Might change later!
    screwcap_server = TaskManager.new(:silent => true)
    screwcap_server.server :server_setup, :address => self.ip, :user => self.username, :password => self.password
    # Gets misc server info
    screwcap_server.task :get_server_info, :server => :server_setup do
      run "hostname" # Get the server hostname from the server itself
      run "find_devices" # Try to automatically find devices
      run "uname -a" # Get the server system information
      run "ruby -v" # Get the Ruby version
    end
    
    # Check for Ruby God installation
    screwcap_server.task :check_for_god, :server => :server_setup do
      run "which god"
    end
    
    # Install Ruby God
    screwcap_server.task :install_god, :server => :server_setup do
      run "gem install god"
    end
    
    # Update gems, install httparty, and svn update the necessary items
    screwcap_server.task :setup_server, :server => :server_setup do
      run "gem update --system"
      run "gem update"
      run "gem install httparty"
      run "svn update ~/actiontec/automation/bin/1.0/SC_utils"
      run "svn update ~/actiontec/automation/bin/1.0/common/rubykill.sh"
    end
    unless @fake_server
      values = screwcap_server.run!(:get_server_info)
      # Update the hostname if it returned an exit code of 0
      self.hostname = values.first[:stdout].chomp! if values.first[:exit_code] == 0
      self.system_config = (values[2..-1].collect {|x| x[:stdout].chomp}).join("\n")
    else
      self.hostname = "fake_#{self.ip}"
      self.system_config = "Fake server: no configuration available."
    end
    
    unless @skip_setup
      screwcap_server.run!(:setup_server)
      
      # Check for Ruby God (process monitor) and install if missing
      god_check = screwcap_server.run!(:check_for_god).first[:stdout].empty?
      screwcap_server.run!(:install_god) unless god_check
    end
      
    #self.state = SERVER_STATE.index("Setup")      
  end
  
  # Legacy function.. leaving it in just in case I revisit it, but for now host look up will be done
  # on the actual server to avoid badly named servers and non-working DNS
  def do_dns_lookup
    self.host = Socket.getaddrinfo(self.ip, nil)[0][2] if SERVER_REVERSE_DNS_LOOKUP
  end
end