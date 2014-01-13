#!/usr/bin/env ruby
# Enables telnet, gets DUT config, and disables telnet in one shot.
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
options.file = "dut_config.cfg"
options.serialport = false
options.telnet_enabled = false

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Enables telnet, gets DUT config, and disables telnet in one shot."

    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("-o FILE", "--output", "Sets filename for saving the config file to.") { |v| options.file = v }
    opts.on("--serial DEVICE", "Use serial port instead of telnet. DEVICE must be the path to the device, e.g. /dev/ttyS0") { |serial| options.serialport = serial }
    opts.on("--telnet-enabled", "Indicates that telnet is already enabled and won't try to enable it first.") { options.telnet_enabled = true }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

def via_serial(options)
	count = 0
	config = ""
	session = SerialPort.new(options.serialport, 115200)
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

def get_config(options)
	# Set the command hash to print the configuration
	command_hash = { "String" => "conf print //", "Match" => /returned/im }

	# Open session and login
	session = Net::Telnet::new("Host" => options.ip, "Port" => options.port)
	session.waitfor(/username/im)
	session.puts(options.username)
	session.waitfor(/password/im)
	session.puts(options.password)
	session.waitfor(/Wireless Broadband Router/im)

	# Deliver configuration print command
	config = session.cmd(command_hash)

	# Erase extra output
	config.sub!(/conf print \//, '')
    config.sub!(/\A\/\r\n/, '')
	config.sub!(/\r\n\r\nReturned 0\r\nWireless Broadband Router> \z/, '')
    
	# Logout and close session
	session.puts "exit"
	session.close
	return config
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
            configuration = get_config(options)
            disable_telnet(agent)
            telnet_on = FALSE
            logout(agent)
        else
            configuration = get_config(options)
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
    configuration = via_telnet(options)
else
    configuration = via_serial(options)
end
output = File.new(options.file, "w+")
output.write(configuration)
output.close