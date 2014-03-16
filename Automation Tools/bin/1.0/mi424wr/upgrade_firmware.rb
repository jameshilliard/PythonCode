#!/usr/bin/env ruby
# Updates BHR firmware using file specified at command line
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'mechanize'
require 'common/ipcheck'
require 'net/ftp'
require 'net/telnet'

$debug = 0

options = OpenStruct.new
options.bhr_version = 2
options.ip = "http://192.168.1.1"
options.recoveryurl = "http://192.168.1.1"
options.username = "admin"
options.password = "admin1"
options.firmware_file = FALSE
options.ftp_site = "sengftp.actiontec.com"
options.ftp_user = "shanghai"
options.ftp_pass = "software"
options.archive = "./"
options.fwver = FALSE
options.tftp = "tftp://192.168.1.10"
options.port = 23

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Downloads specified firmware version from SengFTP and updates BHR firmware to that version."

    opts.on("--bhr VERSION", "Sets BHR version for getting information (1 or 2)") { |v| options.bhr_version = v.to_f }
    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.1.1") { |v| options.ip = v }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("-f FIRMWARE", "Sets file for firmware upload.") { |f| options.firmware_file = f }
    opts.on("-s", "--site SITE", "Override default (sengftp.actiontec.com) ftp site to get the releases from.") { |site| options.ftp_site = site }
    opts.on("-t", "--tftp SITE", "TFTP URL in the form of tftp://192.168.1.2 or similar. This is needed to downgrade firmwares. Note that this will restore defaults.") { |t| options.tftp = t }
	opts.on("--ftp-user USERNAME", "Override default (admin) username.") { |user| options.ftp_user = user }
	opts.on("--ftp-pass PASSWORD", "Override default (admin1) password.") { |pass| options.ftp_pass = pass }
    opts.on("-d", "--directory DIR", "Override default directory to get new release from. Default is based on sengftp.") { |dir| options.ftp_dir = dir }
    opts.on("-a DIR", "Set directory to save to. Defaults to current directory.") { |a| options.archive = a }
    opts.on("-v FIRMWARE", "Tries to download and upgrade with the specified firmware version - i.e., 20.9.12.") { |v| options.fwver = v }
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

def enable_telnet(agent)
    agent.current_page.forms[0].mimic_button_field = "goto: 9023.."
    agent.submit(agent.current_page.forms[0])
    agent.current_page.forms[0].checkboxes[0].check
    agent.current_page.forms[0].mimic_button_field = "submit_button_submit: .."
    agent.submit(agent.current_page.forms[0])
end

def fw_version_check(first, second)
    return first.gsub(/-/,'').gsub(/\.(?!\d+\z)/,'').to_f > second.gsub(/-/,'').gsub(/\.(?!\d+\z)/,'').to_f ? first : second
end

def download_firmware(options)
    case options.bhr_version
    when 1
        ftp_dir = "Release/bhr-release"
        prefix = "*" # Note: Current releases are showing as YYDDMM-firmware.. use array delete_if to match everything not in that format to get latest
        prefix = "*-#{options.fwver.gsub(/-/, '.')}" if options.fwver
        file = "MI424WR.rmt"
        image_file = "MI424WR.img"
        file_format = /\d{6}-\d+?\..*/ # BHR 1 versions kind of suck for regular expressions.
        version_format = /(\d+?\.){1,}\d+/
    when 2
        ftp_dir = "Release/bhr2-release"
        prefix = "BHR2-Release-*"
        prefix = "BHR2-Release-#{options.fwver.gsub(/\./, '-')}" if options.fwver
        file = "MI424WR-GEN2.rmt"
        image_file = "MI424WR-GEN2.img"
        file_format = /BHR2-Release-\d+?-\d+?-\d+/ # BHR 2 versions are excellent for regular expressions.
        version_format = /\d+?-\d+?-\d+(-\d+)?/
    end
    FileUtils::mkdir_p("#{options.archive}")
    ftp = Net::FTP.new(options.ftp_site)
    ftp.login(options.ftp_user, options.ftp_pass)
    ftp.passive = true

    ftp.chdir(ftp_dir)
    dir_list = ftp.list(prefix)
    dir_list.delete_if { |x| x.match(/\A\./) } if options.bhr_version == 1
    
    unless options.fwver
        latest_dir = dir_list[find_latest(dir_list)].slice(file_format)
    else
        latest_dir = prefix
    end

    firmware_version = latest_dir.slice(version_format)
    Debug.out("Getting #{firmware_version}")
    ftp.chdir(latest_dir)

    ftp.getbinaryfile(file, "#{options.archive}/BHR#{options.bhr_version}-#{firmware_version}.rmt") unless File.exists?("#{options.archive}/BHR#{options.bhr_version}-#{firmware_version}.rmt")
    ftp.getbinaryfile(image_file, "#{options.archive}/BHR#{options.bhr_version}-#{firmware_version}.img") unless File.exists?("#{options.archive}/BHR#{options.bhr_version}-#{firmware_version}.img")
    ftp.close

    return firmware_version # Return value like this so the firmware version compare doesn't break horribly
end

def find_latest(dir_list)
    # Dates in the ftp list are always the same amount of characters, and always in the same location.
    newest_entry = FALSE
    newest_date = 0
    dir_list.each do |entry|
        current = Time.parse(entry[42..53]).to_i
        if current > newest_date
            newest_date = current
            newest_entry = dir_list.index(entry)
        end
    end
    return newest_entry
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

def firmware_upgrade_cli(options)
    #flash load -u options.tftp/options.firmware_file -s 4
	# Open session and login
	session = Net::Telnet.new("Host" => options.ip, "Port" => options.port)
	session.waitfor(/username/im)
	session.puts(options.username)
	session.waitfor(/password/im)
	session.puts(options.password)
	session.waitfor(/Wireless Broadband Router/im)
    Debug.out("Uploading firmware file #{options.tftp}/#{options.firmware_file}.")
	# Deliver configuration print command
	session.puts("flash load -u #{options.tftp}/#{options.firmware_file} -s 4")
    session.waitfor(/loading image/im)
    session.waitfor("Match" => /download completed successfully/im, "Timeout" => 120)
    session.puts("system reboot")
	session.close
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

    # Get to System Information
    old_version = get_current_version(agent)
    file_version = download_firmware(options)
    fwv = file_version
    
    if fwv.scan('-').length > 2
        fwv.gsub!(/-(?!\d+\z)/, '.')
    else
        fwv.gsub!(/-/, '.')
    end if options.bhr_version == 2
    Debug.out("Checking #{old_version} vs #{fwv}")
    vcheck = fw_version_check(old_version, fwv)
    if old_version == vcheck
        raise "This requires a CLI firmware load, needing a TFTP server. No TFTP server was specified." unless options.tftp
        Debug.out("CLI Firmware change required. Enabling telnet.")
        enable_telnet(agent)
        options.firmware_file = "BHR#{options.bhr_version}-#{file_version.gsub(/\./, '-')}.img"
        Debug.out("Downgrading from firmware #{old_version} to #{fwv} ...")
        firmware_upgrade_cli(options)
        options.url.replace(options.recoveryurl)
    elsif fwv == old_version
        puts "Upgrade version and current version are the same. Not updating."
        exit
    else
        Debug.out("Upgrading from firmware #{old_version} to #{fwv} ...")
        options.firmware_file = "#{options.archive.sub(/\/\z/,'')}/BHR#{options.bhr_version}-#{file_version.gsub(/\./, '-')}.rmt"
        firmware_upgrade_web(agent, options)
    end
    
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
    if old_version == fw_version_check(old_version, fwv)
        puts "Downgraded from firmware #{old_version} to older firmware #{new_version}"
    else
        puts "Upgraded from firmware #{old_version} to new firmware #{new_version}"
    end
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