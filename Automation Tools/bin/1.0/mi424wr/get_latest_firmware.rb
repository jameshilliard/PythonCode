#!/usr/bin/env ruby

# Ruby file to download the latest firmware - makes 2 copies - bhr#-latest.rmt (or bhr1) and then the actual firmware version - bhr2-20-9-12.rmt
$: << File.dirname(__FILE__)
require 'ostruct'
require 'optparse'
require 'net/ftp'
require 'time'
require 'fileutils'

options = OpenStruct.new
options.bhr_version = "2"
options.ftp_site = "sengftp.actiontec.com"
options.ftp_user = "shanghai"
options.ftp_pass = "software"
options.archive = "./"
options.fwver = FALSE

opts = OptionParser.new do |opts|
	opts.separator("")
	opts.banner = "Get the configuration from the BHR2 via serial port console or telnet."

    opts.on("-s", "--site SITE", "Override default (sengftp.actiontec.com) ftp site to get the releases from.") { |site| options.ftp_site = site }
	opts.on("-u", "--username USERNAME", "Override default (admin) username.") { |user| options.ftp_user = user }
	opts.on("-p", "--password PASSWORD", "Override default (admin1) password.") { |pass| options.ftp_pass = pass }
    opts.on("-d", "--directory DIR", "Override default directory to get new release from. Default is based on sengftp.") { |dir| options.ftp_dir = dir }
    opts.on("--bhr VER", "Sets BHR version to get firmware for. Default is BHR2.") { |ver| options.bhr_version = ver }
    opts.on("-a DIR", "Set directory to save to. Defaults to current directory.") { |a| options.archive = a }
    opts.on("-v FIRMWARE", "Tries to download the specified firmware version - i.e., 20.9.12.") { |v| options.fwver = v }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
	options
end

begin
    opts.parse!(ARGV)

    case options.bhr_version
    when '1'
        ftp_dir = "Release/bhr-release"
        prefix = "*" # Note: Current releases are showing as YYDDMM-firmware.. use array delete_if to match everything not in that format to get latest
        file = "MI424WR.rmt"
        file_format = /\d{6}-\d+?\..*/ # BHR 1 versions kind of suck for regular expressions. 
    when '2'
        ftp_dir = "Release/bhr2-release"
        prefix = "BHR2-Release-*"
        prefix = "BHR2-Release-#{options.fwver.gsub(/\./, '-')}" if options.fwver
        file = "MI424WR-GEN2.rmt"
        file_format = /BHR2-Release-\d+?-\d+?-\d+/ # BHR 2 versions are excellent for regular expressions.
        version_format = /\d+?-\d+?-\d+/
    end
    FileUtils::mkdir_p("#{options.archive}")
    ftp = Net::FTP.new(options.ftp_site)
    ftp.login(options.ftp_user, options.ftp_pass)
    ftp.passive = true

    ftp.chdir(ftp_dir)
    dir_list = ftp.list(prefix)
    dir_list.delete_if { |x| x.match(/\A\./) } if options.bhr_version == 1
    # Dates in the ftp list are always the same amount of characters in
    newest_entry = FALSE
    newest_date = 0
    dir_list.each do |entry|
        current = Time.parse(entry[42..53]).to_i
        if current > newest_date
            newest_date = current 
            newest_entry = dir_list.index(entry)
        end
    end
    latest_dir = dir_list[newest_entry].slice(file_format)
    firmware_version = latest_dir.slice(version_format)
    puts "Getting #{firmware_version}"
    ftp.chdir(latest_dir)
    ftp.getbinaryfile(file, "#{options.archive}/BHR#{options.bhr_version}-latest.rmt")
    ftp.close
    FileUtils::cp("#{options.archive}/BHR#{options.bhr_version}-latest.rmt" , "#{options.archive}/BHR#{options.bhr_version}-#{firmware_version}.rmt")
end