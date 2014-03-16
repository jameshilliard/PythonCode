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
require 'optparse'
require 'ostruct'
require 'serialport'
require 'common/ipcheck'

include Net

# Options holder and default values..
options = OpenStruct.new
options.username = "admin"
options.password = "admin1"
options.ip = "192.168.1.1"
options.port = "23"
options.savefile = "current.cfg"
options.serialport = FALSE

opts = OptionParser.new do |opts|
	opts.separator("")
	opts.banner = "Get the configuration from the BHR2 via serial port console or telnet."
	
	opts.on("-u", "--username USERNAME", "Override default (admin) username.") { |user| options.username = user }
	opts.on("-p", "--password PASSWORD", "Override default (admin1) password.") { |pass| options.password = pass }
	opts.on("--port PORT", "Override default (23) port when using telnet.") { |port| options.port = port }
	opts.on("-i", "--ipaddress IP", "Override default (192.168.1.1) IP address for telnet acccess.") { |i| t = IP.new(i); options.ip = t.ip }
	opts.on("--serial DEVICE", "Use serial port instead of telnet. Specify path to device if something other than /dev/ttyUSB0") { |serial| options.serialport = serial }
	opts.on("-o", "--output FILE", "Output file name.") { |file| options.savefile = file }
	opts.on("--no-save", "Don't save, just output to console.") { options.savefile = FALSE }
	options
end

def self.tnet(options)
	# Set the command hash to print the configuration
	commandHash = { "String" => "conf print //", "Match" => /returned/im }
	
	# Open session and login
	session = Telnet.new("Host" => options.ip, "Port" => options.port)
	session.waitfor(/username/im)
	session.puts(options.username)
	session.waitfor(/password/im)
	session.puts(options.password)
	session.waitfor(/Wireless Broadband Router/im)

	# Deliver configuration print command
	config = session.cmd(commandHash)

	# Erase extra output
	config.sub!(/conf print \//, '')
	config.sub!(/Returned 0/, '')
	config.sub!(/Wireless Broadband Router>/, '')

	# Logout and close session
	session.puts "exit"
	session.close 
	return config
end

def self.sc(options)
	record = FALSE
	count = 0
	config = ""
	session = SerialPort.new("#{options.serialport}", 115200)
	session.puts ""
	session.each_char do |r|
		if count == 3
			session.close
			puts "Unable to successfully login to DUT."
			break
		end
		print r
		config << r
		if config.match(/password/im)
			count += 1
			session.puts options.password
			config = ""
		elsif config.match(/username/im)
			config = ""
			session.puts options.username
		elsif config.match(/Wireless Broadband Router/im)
			config = ""
			session.puts "conf print /"
		elsif config.match(/returned/im)
			session.close
			break
		end
	end

	# Erase extra output
	config.sub!(/conf print \//, '')
	config.sub!(/Returned 0/, '')
	config.sub!(/Wireless Broadband Router>/, '')

	return config
end
# parse options
opts.parse!(ARGV)
rt_count = 0
# Get the configuration
begin
    if options.serialport != FALSE
        config = self.sc(options)
    else
        config = self.tnet(options)
    end
    # Save file, or just print it to console as necessary
    if options.savefile==FALSE
        puts config
    else
        f = File.open(options.savefile, 'w')
        f.write(config)
        f.close
    end
rescue
    if rt_count < 3
        rt_count += 1
        puts "Connection timed out... retry #{rt_count}"
        retry
    else
        puts "Error: Unable to establish a connection. Exiting."
        exit
    end
end


