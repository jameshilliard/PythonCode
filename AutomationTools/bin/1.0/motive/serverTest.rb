#!/usr/bin/env ruby
require 'socket'
require 'optparse'

initXML = ""
tcXML = ""
debug = "dandilion"
# It's cleaner and better to use a struct to return all the arguments... or an array... or a carrier pigeon.
# Oh right, we're shoving GetoptLong into the blender
opts = OptionParser.new do |opts|
	opts.separator ""
	opts.banner = "Server accepts these types of seeds at this time: "
	opts.on("-i", "--initialization-file XMLData") { |init| initXML = init }
	opts.on("--test-cases-file XMLData", "-t XMLData") { |tc| tcXML = tc }
	opts.on("--debug DebugLevel", "-d DebugLevel") { |debugLevel| debug = debugLevel }
	opts.on("-h", "--help", "Show this message") { puts opts; exit }
end

server = TCPServer.new('127.0.0.1', 13337)
while (session = server.accept)
	stuff = (session.gets).split(' ')
	puts "Planted flowers.. \n\n"
	opts.parse!(stuff)
	puts "Spring has come.\n"
	puts "Bloom check...\n\n"
	puts debug
	puts tcXML
	puts initXML
	puts "\n\n ... No withering."
	session.send("I see butterflies!\n", 0)
end
