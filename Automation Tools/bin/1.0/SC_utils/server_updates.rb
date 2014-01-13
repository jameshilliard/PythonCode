#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'json'
require 'optparse'
require 'resolv'
require 'pp'
options = {}
action = nil

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Communicates with the server controller: Add, update, get and delete server resources."
    opts.on("-k", "--apikey APIKEY", "Set server API key to update or change the server if required") {|v| options[:key] = v}
    opts.on("-a", "--add", "Add server to controller") {action = "add"}
    opts.on("-d", "--delete ID", Integer, "Delete server from controller") {|v| action = "delete"; options[:id] = v}
    opts.on("-u", "--update ID", Integer, "Update server on controller") {|v| action = "update"; options[:id] = v}
    opts.on("-g", "--get ID", Integer, "Get server information from controller") {|v| action = "get"; options[:id] = v}
    opts.on("-s", "--server URI", "Set server URI for the controller") {|v| SERVER_URI = v}
    opts.on("--ip IP", "Set IP address, otherwise this is automatically gotten by using Socket calls") {|v| options[:ip] = v }
    opts.on("--hostname HOST", "Set the hostname, otherwise this is automatically gotten via hostname") {|v| options[:host] = v}
    opts.on("--device DEVICE", "Set the device this machine is connected to") { |v| options[:device_type] = v}
    opts.on("--firmware FIRMWARE", "Firmware version of said device") {|v| options[:firmware_version] = v}
    opts.on("--state STATE", "Set state. One of: Unknown, Available, Busy, Reserved") {|v| options[:state] = v}
    opts.on("--config CONFIG", "Set the config. Not used currently, but here in case it will be") {|v| options[:config] = v}
    opts.on_tail("-h", "--help", "Shows these help options[:") { puts opts; exit }
end

class SCUpdate
  attr_reader :response
  include HTTParty
  headers 'content-type' => 'application/json'

  def initialize(options, server_uri)
    @response = nil
    @opts = options
    @server_uri = server_uri
  end
  def add
    @opts[:ip] ||= get_local_ip(@server_uri)
    @opts[:host] ||= (Resolv.getname(@opts[:ip]) rescue "no_valid_hostname")
    @response = self.class.post("#{@server_uri}/servers.json", :body => "{'server':#{JSON.generate(@opts)}}")
  end
  def delete
    @response = self.class.delete("#{@server_uri}/servers/#{@opts[:id]}.json")
  end
  def update
    @response = self.class.put("#{@server_uri}/servers/#{@opts[:id]}.json", :body => "{'server':#{JSON.generate(@opts)}}")
  end
  def get
    @response = self.class.get("#{@server_uri}/servers/#{@opts[:id]}.json")
  end
  
  private
  def get_local_ip(server_ip)
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
    UDPSocket.open do |s|
      s.connect server_ip, 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end
end

opts.parse!(ARGV)
unless SERVER_URI
  puts opts
  exit
end
serv = SCUpdate.new(options, SERVER_URI)
serv.send(action)
pp serv.response
