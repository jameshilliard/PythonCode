#!/usr/bin/env ruby

# == Synopsis
#
# testDevice.rb: Ruby scripts to configure the Actiontec BHR2 Verizon build.
#
# == Usage
#
# testDevice.rb [OPTIONS]
#
# --json, -j, -f [filename]:
#    Load specified configuration file, overriding loading
#    the configuration file default.json
# --debug, -d [level] (NOT YET COMPLETE):
#    0 run in Xvfb (default)
#    1 run in standard mode (firefox becomes viewable)
#    2 Realtime error, warning and info reports in console 
#    3 verbose mode. Show console output for each action.
# --profile [PROFILE]
#    Run Firefox with specified profile name
#    If specified at [PROFILE] is blank, will run with 
#    [PROFILE] = default
#
# The following options override the configuration file settings: 
#
# --username, -u [user]:
#    Specify the username to login to test device.
# --password, -p [pass]:
#    Specify the password to login to test device.
# --ipaddress, -i [address]:
#    Specify the IP address of the test device.
#    You can also specify - 192.168.1.1:8080
#    Or a URL: http://192.168.1.1
#    Or even the full URL: http://192.168.1.1:8080
#    Or you can just specify the port -  :8080
#
# General options
#
# --no-log: 
#    Don't generate a log file. 
# --output, -o [FILENAME]:
#    Specify output file for config logs
# --generate-test-file, -g [FILENAME]:
#    File to generate a test case config. Default is testsystem.json in current directory
# --version, -v:
#    Outputs the current script system version and exits
# --help, -h:
#    Displays this help text, and exits
#
# == Version
# Build: 0.5.1  ; Distributed on: 03-20-2009
#
# == Copyright
# (c) 2009 Actiontec Electronics, Inc. 
# Confidential. All rights reserved.
# == Author
# Chris Born

# Version construction - X.Y.Z where: 
# X = Prime version number. This indicates feature set release. Right now we are on a feature set of 0. It goes to 1 when a device is fully covered. 
# Y.Z = Subversion number. This indicates how many current device features are integrated by TopMenu.SubMenu options. Right now we are sitting at
# 2.9, being that we have 2 complete sections, and 90% of another finished. 

# installation instructions.

#1. ruby - need at least 1.8.6
#       http://www.ruby-lang.org/en/downloads/
#2. ruby gems
#       http://rubyforge.org/frs/?group_id=126
#3. firefox3
#       install from your Linux distribution
#4. jssh
#       http://wiki.seleniumhq.org/pages/viewpageattachments.action?pageId=13893658
#5. firewatir
#       gem install firewatir
#6. set net.http.phishy-userpass-length to 255
#
#7. json
#       gem install json
#8. Xvfb
#       install from your Linux distribution
#9. WaveAutomation
#       http://www.veriwave.com/
CB_VERSION = "0.7.1 - 04/29/09"
$: << File.dirname(__FILE__)

require 'English'
require 'rubygems'
require 'firewatir'
require 'json'
require 'optparse'
require 'ostruct'
require 'appscript' if RUBY_PLATFORM =~ /darwin/

require 'common/log'
require 'common/ipcheck'
require 'configsystem/top_menu'
require 'configsystem/wireless'
require 'configsystem/my_network'
require 'configsystem/firewall'
require 'configsystem/advanced'
require 'configsystem/sys_mon'
require 'configsystem/parental_control'
require 'configsystem/utils'

options = OpenStruct.new
options.portlistdir = FALSE
options.login = FALSE
options.debug = 0
options.ipaddress = FALSE
options.username = FALSE
options.password = FALSE
options.profile = FALSE
options.output_test_file = FALSE
options.jsonfile = FALSE
options.logfile = FALSE
options.verbose = TRUE
options.use_xvfb = FALSE
options.override = FALSE
options.waittime = 20

opts = OptionParser.new do |opts|
	opts.separator ""
	
	opts.on("-j", "-f", "--json FILENAME", "Load specified configuration file, overriding loading the configuration file default.json") { |file| options.jsonfile = file }
	opts.on("-d", "--debug LEVEL", "Sets the debug level for the session. Default is 0, and runs config in Xvfb.") { |d| options.debug = d.to_i }
	opts.on("-i", "--ipaddress IP", "Sets the IP address of the DUT if different than 192.168.1.1, or not specified in the config file.") { |ip| options.ipaddress = ip }
	opts.on("-u", "--username USERNAME", "Sets the DUT username, overriding the configuration file.") { |user| options.username = user }
	opts.on("-p", "--password PASSWORD", "Sets the DUT password, overriding the configuration file.") { |pass| options.password = pass }
	opts.on("-o", "--output LOG", "Set the log path and file name.") { |log| options.logfile = log }
	opts.on("-g", "--generate-test-file FILE", "Specify the path and file name to generate a json file for testSystem.rb to use.") { |g| options.output_test_file = g }
	opts.on("--override KEY=VALUE", "Override any given key with the specified value. This only works on the first instance of the key from the config.") { |o| options.override = o }

	opts.separator ""
  opts.on("--waittime SECONDS", "Time to wait, in seconds, before checking if Firefox and JSSH are up and running. Defaults to 20.") { |o| options.waittime = o.to_i }
  opts.on("--profile PROFILE", "Starts Firefox with the specified profile name instead of the default.") { |o| options.profile = o }
  opts.on("--use-xvfb", "Turns on the use of the X virtual frame buffer. ") { options.use_xvfb = TRUE }
  opts.on("--verbose-off", "Turns verbose (console) output off.") { options.verbose = FALSE }
	opts.on("--portlistdir DIRECTORY", "Directory where port lists are for generating a test file from the given configuration.") { |dir| options.portlistdir = dir }
	opts.on("-v", "--version", "Shows the version number of this script suite.") { puts CB_VERSION }
	opts.on_tail("-h", "--help", "Shows these help options.") { puts optset; exit }
	options
end

def parse_json(filename)
  begin
    json = JSON.parse!(File.open(filename).read)
  rescue JSON::ParserError => ex
    puts "Error: Cannot parse #{filename}.\n#{ex.message}"
    exit
  end
  return json
end

class ConfigDevice
  include FireWatir
	include Log
	include TopMenu
	include MyNetwork
	include ParentalControl
	include SysMon
	include Wireless
	include Firewall
	include Advanced
	include CleanUp
	include TestBuilder
	include Searcher
	include Utility

  attr_accessor :logged_in

	def initialize(options)
    @logged_in = FALSE
    @dut_remote_admin = ""
    @dutinfo = nil
    @dut_information = {}
		@logged_in = FALSE
		@builder = {}
		# These are variables for automated integration of configuration and testing of port related rules on their respective sides
		@portScanList_lan = { "tcp_ports" => "", "udp_ports" => "" }
		@portScanList_inbound = { "tcp_ports" => "", "udp_ports" => "" }
		@portScanList_outbound = { "tcp_ports" => "", "udp_ports" => "" }
    @output_test_file = options.output_test_file
    @port_lists = options.portlistdir
        
    logs(options.logfile, 4 - options.debug, options.verbose)

    rt_count = 1
		begin
			if options.profile
				@ff = Firefox.new(:waitTime => options.waittime, :profile => options.profile)
			else
				@ff = Firefox.new(:waitTime => options.waittime)
			end
			@ff.wait
		rescue => ex
      if rt_count < 4
        self.msg("New Object Initialization", :debug, "Firefox start", "Firefox didn't start, or no connection to the JSSH server on port 9997 was validated, on attempt #{rt_count}. Trying again.")
        options.waittime += 5
        rt_count += 1
        retry
      else
        self.msg("New Object Initialization", :fatal, "Firefox start", "Giving up. Last error received: #{ex}")
        exit
      end
		end
	end

	# Return current URL and text contents
  def current_page_info
    cpi = []
    cpi[0] = @ff.url
    cpi[1] = @ff.text
    return cpi
  end
	#
  # close the browser window
  #
  def close
    @ff.close
  end

  def do(rule_name, info)
      # FixMe: More items related to old code that needs to be fixed/removed.
      # check for any ruby code to run before doing anything else
      if info['eval'].match(/sleep/i)
        sleep info['eval'].delete('^[0-9]').to_i
      else
        eval(info['eval'])
      end if info.has_key?('eval')
      # check for commands to execute too
      self.command(rule_name, info['command']) if info.has_key?('command')

      case info['section']
      when 'null'
        self.msg(rule_name, :info, 'null', '')
      when /login/i
        self.mainpage(rule_name, info)
      when /wireless/i
        self.wireless_jumper(rule_name, info)
      when /firewall/i
        self.firewall_jumper(rule_name, info)
      when 'pppoe_ether'
        self.pppoe_ether(rule_name, info)
      when 'pppoe_coax'
        self.pppoe_coax(rule_name, info)
      when /parent.*control/i
        self.parental_control(rule_name, info)
      when /igmp/i
        self.igmp(rule_name, info)
      when /cleanup/i
        self.cleanup(rule_name, info)
      when /logout/i
        self.logout(rule_name, info)
      when /info/i
        self.info(rule_name, info)
      when /advanced/i
        self.adv_jumper(rule_name, info)
      when /search/
        self.page_search
      else
        self.msg(rule_name, :error, info['section'], 'undefined')
			end if info.has_key?('section') && info['section'] != ''
      return
    end
    #
    # run the passed in command, returning the return code and a pointer to the output
    # FixMe: This is old code. It's bad. It needs to be fixed or removed.
    def command(rule_name, what)

      STDOUT.sync=true

      begin
        oname = @logs + '/' + rule_name + '.out'
        f = File.open(oname, 'w')
        # redirect stderr to stdout so we see syntax errors from the shell
        IO.popen(what + ' 2>&1') do |pipe|
          pipe.sync = true
          while line = pipe.gets
            puts line
            f.write(line)
          end
        end
        rc = $?.exitstatus
      rescue => ex
        puts 'Error: Command failed for rule ' + rule_name + ' ' + ex.message
        exit
      end

      f.close

      self.msg(rule_name, 'command', 'output', oname)
      self.msg(rule_name, 'command', 'rc', rc.to_s)
    end
  end

  begin
    opts.parse!(ARGV)

    if options.use_xvfb
      xvfb = `which Xvfb`
      raise "Xvfb not found." if xvfb.empty?
      xvfb_cmd = "#{xvfb} :#{Process.pid} -screen 0 1024x768x16 2>/dev/null"
      Xvfb_pid = fork { exec(xvfb_cmd) }
      OLD_DISPLAY = ENV['DISPLAY']
      ENV['DISPLAY'] = ":#{Process.pid}"
    end

    input = parse_json(options.jsonfile)
    options.portlistdir = "#{File.dirname(options.jsonfile)}/portlists" unless options.portlistdir
    dut = ConfigDevice.new(options)
    # iterate over the rules in the input file
    for key in input.sort
      unless key[1].key?('section')
        dut.msg(key, :error, 'n/a', 'No section key found')
      else
        # Command line option overrides for login info. We are injecting for section "login"
        if key[1]['section']=='login'
          key[1]['address'] = options.ipaddress unless options.ipaddress
          key[1]['username'] = options.username unless options.username
          key[1]['password'] = options.password unless options.password
        elsif dut.logged_in == FALSE
          dut.msg("Main", :debug, "Main", "Generating login information...")
          rule = "Generated Login"
          raise "Fatal: The passed JSON file contains no \"login\" section, and no parameters were passed indicating the IP address. Exiting." unless options.ipaddress
          raise "Fatal: The passed JSON file contains no \"login\" section, and no parameters were passed indicating the DUT username. Exiting." unless options.username
          login_info = {}
          login_info['section'] = "login"
          login_info['address'] = options.ipaddress
          login_info['username'] = options.username
          login_info['password'] = options.password
          dut.msg("Main", :debug, "Main", "Logging in...")
          dut.do(rule, login_info)
        end
        if options.override
          options.override.delete!('"')
          dut.msg("Main", :debug, "Main", "Override specified for key #{options.override.split('=')[0]}. Changing key to #{options.override.split('=')[1]}")
          if key[1].has_key?(options.override.split('=')[0])
            key[1][options.override.split('=')[0]] = options.override.split('=')[1]
            dut.msg("Main", :debug, "Main", "Override value \"#{options.override.split('=')[0]}\" now set to: #{key[1][options.override.split('=')[0]]}")
          end
        end
        dut.do(key[0], key[1])
      end
    end
    dut.logout("Generated Logout") if dut.logged_in
  rescue => ex
    if defined?(dut) && dut.nil? == FALSE
      cpi = dut.current_page_info if dut.logged_in
      dut.msg("Main", :fatal, "Script exception hit",  "Current URL is #{cpi[0]}.\nContents:\n#{cpi[1]}") unless cpi.nil? if defined? cpi
    end
    puts ex
    puts ex.backtrace
    exit
  ensure
    dut.close if defined?(dut) && dut.nil? == FALSE
    # OSX needs some special handling to close the browser
    Appscript.app('Firefox').quit if Appscript.app('System Events').processes['Firefox'].exists() if RUBY_PLATFORM =~ /darwin/

    # if we're using the virtual frame buffer, stop it
    if options.use_xvfb
      Process.kill("KILL", Xvfb_pid)
      ENV['DISPLAY'] = OLD_DISPLAY
    end
  end
