#!/usr/bin/env ruby
# Updates BHR firmware using file specified at command line
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'mechanize'
require 'common/ipcheck'

options = OpenStruct.new
options.bhr_version = 2
options.ip = "192.168.1.1"
options.username = "admin"
options.password = "admin1"

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Enables or disables telnet on DUT."

    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("--disable", "Disables telnet. Default is enabling.") { options.disable = true }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
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
    puts("Logging in.")
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

begin
    opts.parse!(ARGV)
    dut = IP.new(options.ip)
    agent = WWW::Mechanize.new
    raise "Invalid IP address given" unless dut.is_valid?
    agent.get(dut.url)

    if agent.current_page.parser.text.match(/login setup/im)
        login_setup(agent, options.username, options.password)
    else
        login(agent, options.username, options.password)
    end
    if options.disable
        disable_telnet(agent)
        puts "Telnet disabled"
    else
        enable_telnet(agent)
        puts "Telnet enabled"
    end
end