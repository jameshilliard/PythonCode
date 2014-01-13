#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# TR 69 server end. Communicates with Motive
# Activation URL: http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt
# Authenticated URL: https://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt
# Management Console URL: https://xatechdm.xdev.motive.com/hdm
# Test serial CVJA0471000018
# Test parameter InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID
$: << File.dirname(__FILE__)
require 'rubygems'
require 'optparse'
require 'thread'
require 'socket'
require 'eventmachine'
require 'motive_interface'
require 'communication_interface'
require 'logging'
include Logging.globally

TR69SERVER_VERSION = [1,0,0]
LOGGING_LEVEL = [:fatal, :error, :warn, :info, :debug]
# Logging is wrapped here, so method, file, and line number will always be the same. Removing them from the format.
# Simplifying for better reading on Win32 machines (bad term support)
LOGGING_FORMAT = Logging.layouts.pattern.new(:pattern => "[%d %l] %m\n", :date_pattern => "%Y/%m/%d %H:%M:%S")

# Global logging fixes a problem with syswrite on Win32 systems
Logging.logger.root.add_appenders(Logging.appenders.stdout(:layout => LOGGING_FORMAT))
Logging.logger.root.level = :info

class Hash
  def diff(h2)
    differences = {"Removed" => [], "Added" => []}
    self.each_pair do |k,v|
      unless h2.has_key?(k)
        differences["Removed"] << "#{k}=#{v}"
      end
    end
    h2.each_pair do |k,v|
      unless self.has_key?(k)
        differences["Added"] << "#{k}=#{v}"
      end
    end
    return differences
  end
end

class TR69Server
  attr_accessor :connections, :motive_info, :server_running

  def initialize(mi)
    @server_running = false
    @motive_info = mi
    @connections = []
    @motive_sessions = {}
    @maximum_sessions = motive_info[:max_motive_sessions] || 1
  end

  def get_motive_session(client_id, rl)
    if @motive_sessions.has_key?(client_id)
      return @motive_sessions[client_id]
    else
      add_motive_session(client_id, rl)
      return @motive_sessions[client_id]
    end
  end

  def add_motive_session(client_id, rl)
    @motive_sessions[client_id] = MotiveInterface.new(motive_info[:username], motive_info[:password], rl, (motive_info.has_key?(:debug) ? motive_info[:debug] : false))
  end

  def remove_motive_session(client_id)
    if @motive_sessions.has_key?(client_id)
      @motive_sessions[client_id].close_session = true
      @motive_sessions.delete(client_id)
    end
  end

  def start(interface, port)
    @server_control = EventMachine.start_server(interface, port, CommunicationInterface) do |con|
      con.server = self
      EventMachine::add_periodic_timer(60) { con.keep_alive }
    end
  end

  def stop
    EventMachine.stop_server(@server_control) if @server_running
    @server_running = false
    exit
  end

  def shutdown
    @motive_sessions.each { |m| m.terminate }
    stop
  end
end

server_port = 5031
server_ip = "127.0.0.1"
motive_info = {:username => "ps_training", :password => "premax0615", :auto_restart => false}

ARGV.options do |opts|
  opts.banner = "TR69 Server: An interface to Motive. Usage: #{File.basename($0)} [OPTIONS]"
  opts.separator ""
  opts.on("-i", "--interface INTERFACE", "Interface name or IP address to listen on and the port. i.e. 127.0.0.1:6001") do |o|
    server_ip = o.split(":")[0]
    server_port = o.split(":")[1].to_i unless o.split(":")[1].nil?
  end
  opts.on("-u", "--username USER", "TR-69 Username. Default is #{motive_info[:username]}") { |o| motive_info[:username] = o }
  opts.on("-p", "--password PASS", "TR-69 Password. Default is #{motive_info[:password]}") { |o| motive_info[:password] = o }
  opts.on("-d", "--debug", "Enable debug mode") { motive_info[:debug] = true }
  opts.on("-r", "--restart", "Restarts automatically if the server portion crashes for some reason") { motive_info[:auto_restart] = true }
  opts.on("-l", "--log FILE", "Stores logging to file") { |o| Logging.logger.root.add_appenders(Logging.appenders.file(o, :layout => LOGGING_FORMAT)) }
  opts.on("-x", "--debug LEVEL", "Specifies the debug level (0-4, where 4 is the most verbosity)") {|o| Logging.logger.root.level = LOGGING_LEVEL[o.to_i] }
  opts.on("-h", "--help", "Shows these help options") { puts opts; exit }
end.parse!

begin
  if motive_info[:auto_restart]
    loop do
      EventMachine::run do
        logger.info "Starting"
        @tr69_server = TR69Server.new motive_info
        @tr69_server.start server_ip, server_port
        @tr69_server.server_running = true
        logger.info "Server listening on #{server_ip}:#{server_port}"
      end
      sleep 5
    end
  else
    EventMachine::run do
      logger.info "Starting"
      @tr69_server = TR69Server.new motive_info
      @tr69_server.start server_ip, server_port
      @tr69_server.server_running = true
      logger.info "Server listening on #{server_ip}:#{server_port}"
    end
  end
rescue => e
  logger.error e.message
  logger.error e.backtrace
  logger.info "Recovering"
  retry if motive_info[:auto_restart]
ensure
  logger.info "Stopping"
  @tr69_server.shutdown
end
