#!/usr/bin/env ruby
# == Copyright
# (c) 2009 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Grabs the config file from the BHR unit
# Since this is simple, we are not doing much error checking, I leave that in the hands of those who use this.
$: << File.dirname(__FILE__)

require 'rubygems'
require 'net/telnet'
require 'ostruct'

include Net

# Options holder and default values..
options = OpenStruct.new
options.username = "admin"
options.password = "password1"
options.ip = "192.168.1.1"
options.port = "23"
options.savefile = "help_commands2.txt"
options.readfile = "help_commands.txt"
def self.tnet(options)
    rebuild = []
    commands = File.open(options.readfile).readlines
    finished_commands = []
	# Set the command hash to print the configuration
	helpcmd = { "String" => "", "Match" => /returned/im }
	# Open session and login
	session = Telnet.new("Host" => options.ip, "Port" => options.port)
	session.waitfor(/username/im)
	session.puts(options.username)
	session.waitfor(/password/im)
	session.puts(options.password)
	session.waitfor(/Wireless Broadband Router/im)

    while commands.length > 0
        current = commands.pop
        helpcmd = { "String" => "#{current}" }
        temp = session.cmd(helpcmd)
        temp.gsub!(/Returned 0/, '')
        temp.gsub!(/Wireless Broadband Router>/, '')
        temp.split("\n").each do |v|
            v.chomp!
            rebuild << v.strip unless v.empty?
        end
        finished_commands << rebuild.join("\n")+"\n"
    end

	# Logout and close session
	session.puts "exit"
	session.close
	return finished_commands
end

config = self.tnet(options)

f = File.open(options.savefile, 'w')
f.write(config.join("\n"))
f.close