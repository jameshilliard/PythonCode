#!/usr/bin/env ruby
# Garner AP information from BHR1 and 2 and plug into client configuration for Veriwave.
# Doesn't support https yet.
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'mechanize'
require 'common/ipcheck'

options = OpenStruct.new
options.bhr = 2
options.ip = "http://192.168.1.1"
options.username = "admin"
options.password = "admin1"

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Gets DUT firmware version."

    opts.on("--bhr VERSION", "Sets BHR version for getting information (1 or 2)") { |v| options.bhr = v.to_i }
    opts.on("-i URL", "URL for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

begin
    opts.parse!(ARGV)
    dut = IP.new(options.ip)
    browser_agent = WWW::Mechanize.new
    login_page = browser_agent.get(dut.url)
    # Set login information and create the MD5 hash
    login_page.forms[0].user_name = options.username
    pwmask, auth_key = "", ""
    login_page.forms[0].fields.each { |t| pwmask = t.name if t.name.match(/passwordmask_\d+/); auth_key = t.value if t.name.match(/auth_key/) }
    login_page.forms[0]["#{pwmask}"] = options.password
    login_page.forms[0].md5_pass = Digest::MD5.hexdigest("#{options.password}#{auth_key}")
    login_page.forms[0].mimic_button_field = "submit_button_login_submit%3a+.."
    browser_agent.submit(login_page.forms[0])

    # Success check - make sure we have a logout option
    raise "Didn't successfully login. Check user/pass." unless browser_agent.current_page.parser.text.match(/logout/im)

    # Get to System Information
    browser_agent.current_page.forms[0].mimic_button_field = "sidebar: actiontec_topbar_status.."
    browser_agent.submit(browser_agent.current_page.forms[0])

    # Get the information
    info = browser_agent.current_page.parser.xpath('//tr/td[@class="GRID_NO_LEFT"]')
    # Log out
    browser_agent.current_page.forms[0].mimic_button_field = "logout: ..."
    browser_agent.submit(browser_agent.current_page.forms[0])
    # Print out model, hardware revision, and firmware version
    puts "#{info[1].content}_#{info[2].content}_#{info[0].content}_#{info[3].content}"
end