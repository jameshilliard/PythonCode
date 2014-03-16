#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'json'
require 'optparse'
require 'pp'
options = {}
action = nil
silent = false
TEST_STATES = ["Failed", "Passed"]
opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Communicates with the server controller: Update, and get test case resources."
    opts.on("-k", "--apikey APIKEY", "Set server API key to update or change the server if required") {|v| options[:key] = v}
    opts.on("-u", "--update ID", Integer, "Update server on controller") {|v| action = "update"; options[:id] = v}
    opts.on("-g", "--get ID", Integer, "Get server information from controller") {|v| action = "get"; options[:id] = v}
    opts.on("-s", "--server URI", "Set server URI for the controller") {|v| SERVER_URI = v}
    opts.on("-r", "--result RESULT", TEST_STATES, "Set state. One of: #{TEST_STATES.join ', '}") {|v| options[:result] = v}
    opts.on("--silent", "Turns off output") {silent = true}
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
  def update
    @response = self.class.put("#{@server_uri}/test_cases/#{@opts[:id]}.json", :body => "{'test_case':#{JSON.generate(@opts)}}")
  end
  def get
    @response = self.class.get("#{@server_uri}/test_cases/#{@opts[:id]}.json")
  end
end

opts.parse!(ARGV)
unless SERVER_URI
  puts opts
  exit
end
serv = SCUpdate.new(options, SERVER_URI)
serv.send(action)
pp serv.response unless silent
