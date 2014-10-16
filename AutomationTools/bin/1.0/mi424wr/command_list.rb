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
options.savefile = "help_commands.txt"

def self.tnet(options)
    more_commands = false
    commands = ["help conf", "help upnp", "help qos", "help wmm", "help cwmp", "help bridge", "help bridge", "help firewall", "help connection", "help inet_connection", "help misc", "help firmware_update", "help log", "help dev", "help kernel", "help system", "help flash", "help net"]
    finished_commands = []
    rebuild = ""
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
        rebuild = ""
        current = commands.pop
        helpcmd = { "String" => "#{current}" }
        temp = session.cmd(helpcmd)
        temp.sub!(/conf print \//, '')
        temp.sub!(/Returned 0/, '')
        temp.sub!(/Wireless Broadband Router>/, '')
        more_commands = false
        temp.split("\n").each do |check|
            check.chomp!
            if check.length < 1
                # Ignore it, it's a pointless line we don't need
            else
                more_commands = true if check.match(/category|categories/i)
                if more_commands
                    commands << current+" "+check.slice(/\A\w* /).strip unless check.match(/help|exit/i)
                else
                    if finished_commands.last.nil?
                        finished_commands << current
                    else
                        current.include?(finished_commands.last) ? finished_commands[finished_commands.index(finished_commands.last)] = current : finished_commands << current
                    end
                end unless check.match(/\Acommand\Aavail|category|categories|error|\A\s/i)
            end
        end
        finished_commands.store(current, rebuild) unless rebuild.empty?
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