#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'serialport'

options = OpenStruct.new
options.username = "admin"
options.password = "admin1"
options.serialport = false

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Watches for Kernel Panics within the DUT while testing."

    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--serial DEVICE", "Use serial port instead of telnet. DEVICE must be the path to the device, e.g. /dev/ttyS0") { |serial| options.serialport = serial }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

opts.parse!(ARGV)
# Lock for watcher/reporter
lock = Mutex.new
kernel_panic = FALSE
reset_done = FALSE
# KP watch thread
Thread.new do
	session = SerialPort.new(options.serialport, 115200)
    cmdline = ""
	session.puts ""
	session.each_char do |r|
		if count == 3
			session.close
            # No sense in repeating if we can't login.
			raise "Unable to successfully login to DUT."
		end
		cmdline << r
		if cmdline.match(/password/im)
			session.puts options.password
            reset_done = TRUE
            kernel_panic = FALSE
		elsif cmdline.match(/username/im)
			session.puts options.username
        elsif cmdline.match(/Wireless Broadband Router/im)
            # This is just to keep the session active.
            session.puts "system cat /proc/uptime"
        elsif cmdline.match(/kernel panic/im)
            kernel_panic = TRUE
            reset_done = FALSE
		end
	end
end

# Socket thread for communicating kernel panic errors
Thread.new do
    
end