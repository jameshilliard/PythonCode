#!/usr/bin/env ruby
require 'rubygems'
require 'rexml/document'
require 'optparse'
require 'socket'

# Default values 
helpArray = []
helpArray[0] = "-h"
initFile = "defaultinit.xml"
serverPort = 13337
serverIP = "192.168.1.2"
tcFile = ""
validDebugLevels = "debug, info, warning, error, fatal, cheesecake"

# Option parser
opts = OptionParser.new do |opts|
	opts.separator ""
	opts.banner = "Found the following flower seeds: "
	opts.on("-i", "--initialization-file XMLFile", "Initialization Sets XML File") { |init| initFile = init }
	opts.on("-t", "--test-cases-file XMLData", "Test Case XML File") { |tc| tcFile = tc }
	opts.on("--serverip IP", "Server IP Address - Default: #{serverIP}") { |ip| serverIP=ip }
	opts.on("--serverport PORT", "Server Port - Default: #{serverPort}") { |port| serverPort = port.to_i }
	opts.on("-d", "--debug [debug, info, warning, error, fatal]", "Change the debug level") { |debugLevel| validDebugLevels.include?(debugLevel.downcase) ? debug=debugLevel : debug=FALSE }
	opts.on("-h", "--help", "Show this message") { puts opts; exit }
end
if ARGV.length < 1
	opts.parse!(helpArray)
else
	opts.parse!(ARGV)
end

# Open and read the files to pass
# Equalizing here because I'm lazy and don't want to type a giant string out twice unless it's specific to non-testing
tcFile = initFile if tcFile ==""

tc = File.read(tcFile)
init = File.read(initFile)

# Remove flags so they stay a single string when passing, or this screws up. 
tc.gsub!(/\t|\r|\n|/,'')
init.gsub!(/\t|\r|\n|/,'')

# Build the string we are sending
serverFlags = "-t #{tc} -i #{init}\n"

# Open socket to the server
client = TCPSocket.open(serverIP, serverPort)

# Write to the server
client.send(serverFlags, 0)

# Data sent back from server
puts "\nPlanting flowers..."
message = client.readline
if message == ""
	puts "\nServer said, \"#{message.chomp.strip}\" Flowers must have bloomed."
	puts "\nFinding nearest jump rope.\n"
else
	puts "\nMust have had unexpected blizzard. Server died.\n"
	exit -2
end

# Close socket
client.close
