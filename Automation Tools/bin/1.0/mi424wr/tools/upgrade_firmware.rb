#!/usr/bin/env ruby
# Updates BHR firmware using file specified at command line
$: << File.dirname(__FILE__)
$: << File.dirname(__FILE__) + "/../"
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'mechanize'
require 'common/ipcheck'

$debug = 0

options = OpenStruct.new
options.bhr_version = 2
options.ip = "http://192.168.1.1"
options.recoveryurl = "http://192.168.1.1"
options.username = "admin"
options.password = "admin1"
options.firmware_file = FALSE
options.fwver = FALSE


opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Downloads specified firmware version from SengFTP and updates BHR firmware to that version."
    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("-f FIRMWARE", "Sets file for firmware upload.") { |f| options.firmware_file = f }
    opts.on("--debug", "Turns debugging messages on") { $debug = 3 }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

class Debug
	def self.out(message)
		if $debug == 3
			puts "(III) #{message}"
		end
        if $debug == 2 && message.length < 41
            puts "(II) #{message}"
        end
	end

    def err(message)
        puts "(!!!) #{message}"
        exit
    end
end

def login(agent, username, password)
    Debug.out("Logging in.")
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

def get_current_version(agent)
    agent.current_page.forms[0].mimic_button_field = "sidebar: actiontec_topbar_status.."
    agent.submit(agent.current_page.forms[0])
    return agent.current_page.parser.xpath('//tr/td[@class="GRID_NO_LEFT"]')[0].content
end

def firmware_upgrade_web(agent, options)
    raise "No firmware to update with." unless options.firmware_file
    agent.current_page.forms[0].mimic_button_field = "goto: 741.."
    agent.submit(agent.current_page.forms[0])
    agent.current_page.forms[0].mimic_button_field = "submit_button_man_upgrade: .."
    agent.submit(agent.current_page.forms[0])
    Debug.out("Uploading firmware file #{options.firmware_file}.")
    agent.current_page.forms[0].action = 'upgrade.cgi'
    agent.current_page.forms[0].mimic_button_field = "submit_button_upgrade_now: .."
    agent.current_page.forms[0].enctype = "multipart/form-data"
    agent.current_page.forms[0].file_uploads[0].file_name = options.firmware_file
    agent.submit(agent.current_page.forms[0])
    agent.current_page.forms[0].mimic_button_field = "submit_button_submit: .."
    agent.submit(agent.current_page.forms[0])
    Debug.out("Waiting 60 seconds for DUT recovery.")
    sleep 60
end

begin
    opts.parse!(ARGV)
    agent = WWW::Mechanize.new
    dut = IP.new(options.ip)
    options.ip = dut.ip
    options.url = dut.url

    raise "Invalid IP address given" unless dut.valid?
    agent.get(dut.url)

    if agent.current_page.parser.text.match(/login setup/im)
        login_setup(agent, options.username, options.password)
    else
        login(agent, options.username, options.password)
    end

    # Success check - make sure we have a logout option
    raise "Didn't successfully login. Check user/pass." unless agent.current_page.parser.text.match(/logout/im)
    Debug.out("Successful login. Getting current firmware version.")

    firmware_upgrade_web(agent, options)

    Debug.out("Trying to log back in")
    agent.get(dut.url)

    if agent.current_page.parser.text.match(/login setup/im)
        login_setup(agent, options.username, options.password)
    else
        login(agent, options.username, options.password)
    end

    raise "Didn't successfully login. Check user/pass." unless agent.current_page.parser.text.match(/logout/im)
    Debug.out("Successful login. Getting current firmware version.")
    new_version = get_current_version(agent)

    Debug.out("Logging out.")
    # Log out
    agent.current_page.forms[0].mimic_button_field = "logout: ..."
    agent.submit(agent.current_page.forms[0])
    puts "Upgraded to new firmware #{new_version}"
rescue Errno::ENETUNREACH => unreachable
    puts "Unable to log in. Check the DUT IP - it's probably not #{options.ip}."
    puts unreachable.message
rescue Errno::EHOSTUNREACH => unreachable
    puts "Unable to log back in. Chances are the DUT has reset back to 192.168.1.1."
    puts unreachable.message
rescue Errno::ETIMEDOUT => unreachable
    puts "No response from the DUT. Is it even listening? Perhaps it's still resetting?"
    puts unreachable.message
end