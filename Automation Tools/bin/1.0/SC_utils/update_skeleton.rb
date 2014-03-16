require 'rubygems'
require 'httparty'
require 'json'
require 'optparse'
require 'pp'

options = {}
action = nil

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Communicates with the server controller: Add, update, get and delete server resources."
    opts.on("-k", "--apikey APIKEY", "Set server API key to update or change items assigned to server (if needed.)") {|v| options[:key] = v}
    opts.on("-a", "--add", "") {action = "add"}
    opts.on("-d", "--delete ID", Integer, "") {|v| action = "delete"; options[:id] = v}
    opts.on("-u", "--update ID", Integer, "") {|v| action = "update"; options[:id] = v}
    opts.on("-g", "--get ID", Integer, "") {|v| action = "get"; options[:id] = v}
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

  # Basic POST to add an item to a declared resource
  def add
    @response = self.class.post("#{@server_uri}/resources_name.json", :body => "{'resource_form_name':#{JSON.generate(@opts)}}")
  end
  # Basic DELETE to delete an item from a declared resource
  def delete
    @response = self.class.delete("#{@server_uri}/resource_name/#{@opts[:id]}.json")
  end
  # Basic PUT to update an item in a declared resource
  def update
    @response = self.class.put("#{@server_uri}/resource_name/#{@opts[:id]}.json", :body => "{'resource_form_name':#{JSON.generate(@opts)}}")
  end
  # Basic GET to get an item from a declared resource
  def get
    @response = self.class.get("#{@server_uri}/resource_name/#{@opts[:id]}.json")
  end
end

opts.parse!(ARGV)
unless SERVER_URI
  puts opts
  exit
end
resource_name = SCUpdate.new(options, SERVER_URI)
resource_name.send(action)
pp resource_name.response # or do something with it