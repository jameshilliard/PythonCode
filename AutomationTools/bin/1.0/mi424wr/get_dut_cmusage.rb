#!/usr/bin/env ruby
# Uses telnet or serial port to get CPU and Memory usage stats from the DUT - will enable telnet if necessary via web interface
# Returns information directly to command line - no file writing contained so it can be used actively in other scripts
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'mechanize'
require 'serialport'

require 'common/telnet_mod'
require 'common/ipcheck'

options = OpenStruct.new
options.bhr_version = 2
options.ip = "192.168.1.1"
options.username = "admin"
options.password = "admin1"
options.port = 23
options.file = "dut_"
options.serialport = false
options.telnet_enabled = false

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Enables telnet, gets DUT config, and disables telnet in one shot."

    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--serial DEVICE", "Use serial port instead of telnet. DEVICE must be the path to the device, e.g. /dev/ttyS0") { |serial| options.serialport = serial }
    opts.on("--telnet-enabled", "Indicates that telnet is already enabled and won't try to enable it first.") { options.telnet_enabled = true }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

def clean_output(cpu_mem_info)
    info = []
    # Erase extra output
	cpu_mem_info.gsub!(/system .*/, '')
	cpu_mem_info.gsub!(/Returned 0|Wireless Broadband Router>.*/, '')
    cpu_mem_info.split("\r\n").each do |l|
        l.strip!
        l.chomp!
        l.gsub!(/# name.*\n/, "\n/proc/slabinfo - \n")
        l.gsub!(/slabinfo - version.*\n/, '')
        proc_uptime = l.slice(/^\d+\.\d+ \d+\.\d+$/)
        current_cpu = l.slice(/^(\d+\.\d+ ){3}\d+\/\d+ \d+$/)
        current_memfree = l.slice(/MemFree:.*\d+.../)
        l = "Current free memory: #{current_memfree.slice(/\d+.../)}" if l.match(/MemFree:/)
        l = "Router uptime: #{proc_uptime}" unless proc_uptime.nil?
        l = "Router CPU Load: #{current_cpu}" unless current_cpu.nil?
        info << l unless l.length == 0
    end
	return info.join("\n")
end

def via_serial(options)
    commands = [ "system date", "system cat /proc/uptime", "system http_intercept_status", "system cat /proc/meminfo", "system cat /proc/loadavg", "system cat /proc/slabinfo" ]
	login_count = 0
	cpu_mem_info = ""
    match_count = 0
	session = SerialPort.new(options.serialport, 115200)
	session.puts ""
	session.each_char do |r|
		if count == 3
			session.close
			raise "Unable to successfully login to DUT."
		end
		cpu_mem_info << r
		if cpu_mem_info.match(/password/im)
			login_count += 1
			session.puts options.password
            # Reset string so we don't copy password
			cpu_mem_info = ""
		elsif cpu_mem_info.match(/username/im)
			session.puts options.username
            # Reset string so we don't copy username
            cpu_mem_info = ""
		elsif cpu_mem_info.match(/Wireless Broadband Router/im)
			session.puts commands[match_count]
            match_count += 1
		elsif match_count == commands.length
            session.close
            break
		end
	end
    return clean_output(cpu_mem_info)
end

def enable_telnet(agent)
    agent.current_page.forms[0].mimic_button_field = "goto: 9023.."
    agent.submit(agent.current_page.forms[0])
    agent.current_page.forms[0].checkboxes[0].check
    agent.current_page.forms[0].mimic_button_field = "submit_button_submit: .."
    agent.submit(agent.current_page.forms[0])
end

def disable_telnet(agent)
    agent.current_page.forms[0].mimic_button_field = "goto: 9023.."
    agent.submit(agent.current_page.forms[0])
    agent.current_page.forms[0].checkboxes[0].uncheck
    agent.current_page.forms[0].mimic_button_field = "submit_button_submit: .."
    agent.submit(agent.current_page.forms[0])
end

def login(agent, username, password)
    pwmask, auth_key = "", ""
    agent.current_page.forms[0].fields.each { |t| pwmask = t.name if t.name.match(/passwordmask_\d+/); auth_key = t.value if t.name.match(/auth_key/) }
    # Set login information and create the MD5 hash
    agent.current_page.forms[0].user_name = username
    agent.current_page.forms[0][pwmask] = password
    agent.current_page.forms[0].md5_pass = Digest::MD5.hexdigest("#{password}#{auth_key}")
    agent.current_page.forms[0].mimic_button_field = "submit_button_login_submit: .."
    agent.submit(agent.current_page.forms[0])
end

def login_setup(agent, username, password)
    pwmask, time_zone = "", ""

    offset = Time.now.gmt_offset / 3600
    offset -= 1 if Time.now.zone.match(/MDT|PDT|EDT|CDT|AKDT|NDT|ADT|HADT/)
    zone = sprintf("%+05d", offset*100).insert(3,':')

    agent.current_page.forms[0].fields.each { |t| pwmask = t.name.delete('^[0-9]') if t.name.match(/password_\d+/) }
    agent.current_page.forms[0]["password_#{pwmask}"] = password
    agent.current_page.forms[0]["rt_password_#{pwmask}"] = password
    agent.current_page.forms[0]["username"] = username

    tz = agent.current_page.forms[0].elements.last
    tz.options.each { |t| time_zone = t.value if t.text.include?(zone) }
    time_zone = "Other" if time_zone.empty?
    agent.current_page.forms[0]["time_zone"] = time_zone
    agent.current_page.forms[0]["gmt_offset"] = Time.now.gmt_offset / 60 if time_zone == "Other"
    agent.current_page.forms[0]["mimic_button_field"] = "submit_button_login_submit: .."

    agent.submit(agent.current_page.forms[0])
end

def logout(agent)
    agent.current_page.forms[0].mimic_button_field = "logout: ..."
    agent.submit(agent.current_page.forms[0])
end

def get_info(options)
	# Set the command hash to print the configuration
    commands = []
    commands << { "String" => "system date", "Match" => /returned/im }
    commands << { "String" => "system cat /proc/uptime", "Match" => /returned/im }
    commands << { "String" => "system http_intercept_status", "Match" => /wireless broadband router/im }
	commands << { "String" => "system cat /proc/meminfo", "Match" => /returned/im }
    commands << { "String" => "system cat /proc/loadavg", "Match" => /returned/im }
    commands << { "String" => "system cat /proc/slabinfo", "Match" => /returned/im }
    cpu_mem_info = ""

	# Open session and login
	session = Net::Telnet::new("Host" => options.ip, "Port" => options.port)
	session.waitfor(/username/im)
	session.puts(options.username)
	session.waitfor(/password/im)
	session.puts(options.password)
	session.waitfor(/Wireless Broadband Router/im)

	# Deliver cpu_mem_info print command
    commands.each { |command_hash| cpu_mem_info << session.cmd(command_hash) }

	# Logout and close session
	session.puts "exit"
	session.close

	return clean_output(cpu_mem_info)
end

def via_telnet(options)
    begin
        dut = IP.new(options.ip)
        options.ip.replace(dut.ip)
        raise "Invalid IP address given" unless dut.is_valid?
        unless options.telnet_enabled
            agent = WWW::Mechanize.new
            agent.get(dut.url)
            if agent.current_page.parser.text.match(/login setup/im)
                login_setup(agent, options.username, options.password)
            else
                login(agent, options.username, options.password)
            end
            raise "Maximum allowed sessions reached on DUT." if agent.current_page.parser.text.match(/Please wait until open sessions expire/im)
            enable_telnet(agent)
            telnet_on = TRUE
            configuration = get_info(options)
            disable_telnet(agent)
            telnet_on = FALSE
            logout(agent)
        else
            configuration = get_info(options)
        end
        return configuration
    rescue => exerr
        puts exerr
        if telnet_on
            disable_telnet(agent)
            logout(agent)
        end
    end
end

opts.parse!(ARGV)
unless options.serialport
    info = via_telnet(options)
else
    info = via_serial(options)
end
puts info