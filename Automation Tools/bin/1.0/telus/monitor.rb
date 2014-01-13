#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Monitors TELUS V1000H stress test units

#Every 6 hours,
#1. go to console, catch and save following infomation:
#  -- cpu loadavg
#  -- meminfo
#  -- uptime
#  -- adsl info --show
#  -- top under shell
#
#2. go to GUI, make sure following GUI is alive and showing correct info:
#  --WAN status GUI
#  --HPNA status GUI
#  --LAN ethernet status
$: << File.dirname(__FILE__)

require 'rubygems'
require 'mechanize'
require 'optparse'
require 'ostruct'
require 'common/telnet_mod'
require 'common/ip_utils'

options = OpenStruct.new
options.dut = ["http://192.168.0.1"]
options.username = "admin"
options.password = "admin1"
options.interval = 360
options.output = ""
options.top_cycles = 1
options.overwrite = true
options.testserver_ip = "10.206.4.200"
$debug = FALSE

opts = OptionParser.new do |opts|
    opts.separator("")
    opts.banner = "Information gatherer for Telus V1000H devices"
    opts.on("-i IP", "IP for accessing DUT. Defaults to 192.168.0.1. Separate with a comma to check multiple devices (192.168.0.1,192.168.1.1,192.168.2.1, etc)") { |v| options.dut = v.split(",") }
    opts.on("-u USERNAME", "--username", "Sets username for logging into the DUT") { |v| options.username = v }
    opts.on("-p PASSWORD", "--password", "Sets password for logging into the DUT") { |v| options.password = v }
    opts.on("-o OUTFILE", "--output", "Sets the prefix for the logging file(s). Each prefix will be appended with the device IP.log - e.g. --output device_ will create device_192_168_0_1.log") { |v| options.output = v }
    opts.on("-n", "--no-overwrite", "By default log files that exist already are overwritten, using this will append new information to the existing log file instead") { options.overwrite = false }
    opts.on("--top_cycles COUNT", "Logs COUNT amount of top cycles. Defaults to 1") { |v| options.top_cycles = v.to_i }
    opts.on("--interval TIME", "Sets the interval timer in minutes to check the DUT; defaults to 360 (6 hours). Set to 0 to run only one time") { |v| options.interval = v.to_i }
    opts.on("--testserver IP", "Changes test server IP for pinging (default is 10.206.4.200)") { |v| options.testserver_ip = v }
    opts.on("--debug", "Turns debugging information on. Off by default") { $debug = TRUE }
    opts.on_tail("-h", "--help", "Shows these help options.") { puts opts; exit }
end

class DeviceInfo
    include Net
    
    attr_accessor :ip, :results

    def initialize(dut, user, pass, cycles)
        @options = OpenStruct.new
        @options.dut = IP.new(dut)
        @options.user = user
        @options.pass = pass
        @ip = @options.dut.ip
        @wan_ip = ""
        @results = ""
        @top_cycles = cycles
        @connection_type = 0
        @available_console_prefixes = []
        @telnet_enabled = false
    end

    # Runs ping
    def ping(ip)
        results = []
        ping_results = `ping -c 4 #{ip}`
        stats = ping_results.slice(/\d+ packets transmitted, \d+ received.*/)
        sent = stats.slice(/\A\d+/).to_i
        rcvd = stats.slice(/\d+/).to_i
        results[0] = sent-rcvd
        results[1] = ping_results
        return results
    end

    # Enables telnet and sets telnet user/pass to the passed values
    def enable_telnet
        begin
            b = Mechanize.new
            b.get("#{@options.dut.url}/login.cgi?inputUserName=root&inputPassword=m3di\@r00m\!&nothankyou=1")
            sleep 5
            b.get("#{@options.dut.url}/advancedsetup_remotetelnet.cgi?serCtlTelnet=2&remTelUser=#{@options.user}&remTelPass=#{@options.pass}&remTelTimeout=0&remTelPassChanged=1&nothankyou=1")
            @telnet_enabled = true
            sleep 5
        rescue Exception => e
            if $debug
                puts "Debug information: "
                puts @gui.current_page ? @gui.current_page.parser.content : "Mechanize class not initiated on this round."
                puts e.message
                puts e.backtrace
            end
            puts "[#{@ip}] Unable to access GUI on attempt to enable telnet. Aborting for this attempt."
        end
    end

    # Cleans telnet responses so they can be parsed correctly
    def clean_up(unformatted, command)
        formatted_results = []
        unformatted.gsub!(/\A.*>.*#{command}/, '')
        unformatted.gsub!(/>/, '')
        unformatted.gsub!(/\A > /i, '')
        unformatted.gsub!(/\r/, '')
        unformatted.gsub!(/#/, '')
        unformatted.split("\n").each { |formatting| formatted_results << formatting.strip.chomp if formatting.strip.chomp.length > 0 unless formatting.strip.chomp.match(/\A#{command}\z/) }
        formatted_results
    end

    # Sets GUI login password as necessary
    def set_gui_login
        @gui.get("#{@options.dut.url}/login.cgi?inputUserName=admin&inputPassword=telus&nothankyou=1")
        sleep 5
        @gui.get("#{@options.dut.url}/advancedsetup_admin.cgi?inputUserName=#{@options.user}&inputPassword=#{@options.pass}&usrPassword=telus&nothankyou=1")
        sleep 5
    end

    # Gets information from the GUI
    def gui_info
        retried = false
        begin
            # LAN: url/modemstatus_lanstatus.html
            # HPNA: same as LAN
            # WAN: ethernet - url/modemstatus_wanethstatus.html
            # WAN: dsl - url/modemstatus_wanstatus.html
            wan_results = ""
            hpna_status_verbs = { :Up => "CONNECTED", :Initializing => "CONNECTING", :Error => "ERROR", :Disabled => "Disabled", :NoSignal => "NO SIGNAL" }
            ethernet_status_verbs = { :Up => "CONNECTED", :Connecting => "Connecting", :Disabled => "DISCONNECTED", :Connected => "CONNECTED" }
            dsl_state = { :Up => "Showtime", :EstablishingLink => "Training", :default => "Idle" }
            dsl_modes = { :adslgdmt => "ADSL G.dmt", :adslansit1413 => "T1.413", :adslgdmtbis => "ADSL2", :adslglite => "G.Lite", :adsl2plus => "ADSL2+", :default => "MULTIMODE", :nt => "Not Trained" }
            @gui = Mechanize.new
            @gui.get("#{@options.dut.url}/login.cgi?inputUserName=#{@options.user}&inputPassword=#{@options.pass}&nothankyou=1")
            sleep 5
            @gui.get("#{@options.dut.url}/modemstatus_home.html")
            value_sift = @gui.current_page.parser.content.select { |x| x.match(/var\s*glbWanL2IfName/i) }
            @connection_type = 1 if value_sift[0].match(/ewan/i) # connection is ethernet
            @connection_type = 2 if value_sift[0].match(/atm/i) # connection is dsl atm
            @connection_type = 3 if value_sift[0].match(/ptm/i) # connection is dsl ptm

            # Gets information WAN DSL if that is the connection type
            if @connection_type > 1
                order = %w{ Broadband Internet_Service_Provider MAC_Address IP_Address Subnet_Mask Gateway DNS Connection_Status VPI VCI Broadband_Mode_Setting Broadband_Negotiated_Mode Upstream Downstream SNR_Downstream SNR_Upstream Attenuation_Downstream Attenuation_Upstream
                Power_Downstream Power_Upstream Retrains ATM_QoS_Class PTM_VLAN_QoS Retrain_Timer Near_End_CRC_Errors_Interleave Near_End_CRC_Errors_Fastpath Far_End_CRC_Errors_Interleave Far_End_CRC_Errors_Fastpath
                HalfHour_Near_End_CRC_Errors_Interleave HalfHour_Near_End_CRC_Errors_Fastpath HalfHour_Far_End_CRC_Errors_Interleave HalfHour_Far_End_CRC_Errors_Fastpath Near_End_RS_FEC_Interleave Near_End_RS_FEC_Fastpath
                Far_End_RS_FEC_Interleave Far_End_RS_FEC_Fastpath HalfHour_Near_End_RS_FEC_Interleave HalfHour_Near_End_RS_FEC_Fastpath HalfHour_Far_End_RS_FEC_Interleave HalfHour_Far_End_RS_FEC_Fastpath
                HalfHour_Discarded_Packets_Upstream HalfHour_Discarded_Packets_Downstream }
                something = "N/A"
                @gui.get("#{@options.dut.url}/modemstatus_wanstatus.html")
                dslstatus = @gui.current_page.parser.content.slice(/var\s*dslstatus.*;/i).slice(/'.*'/).delete("';").split("|")
                l2atm = @gui.current_page.parser.content.slice(/var\s*layer2Infoatm.*;/i).slice(/'.*'/).delete("';").split("|")
                # Set to NT for Not Trained if the negotiated mode doesn't match anything it should
                l2atm[13] = "nt" unless l2atm[13].match(/adsl|\A\d/i)
                l2ptm = @gui.current_page.parser.content.slice(/var\s*layer2Infoptm.*;/i).slice(/'.*'/).delete("';").split("|")
                interface_info = @gui.current_page.parser.content.slice(/var\s*wanInfNames.*;/i).slice(/'.*'/).delete("'|").split(";")
                timespan = dslstatus[7].to_i
                dsl_status = {
                    :Broadband => ethernet_status_verbs[dslstatus[0].to_sym],
                    :Internet_Service_Provider => ethernet_status_verbs[interface_info[7].to_sym],
                    :MAC_Address => interface_info[8].gsub('-', ':'),
                    :IP_Address => interface_info[1],
                    :Subnet_Mask => interface_info[2],
                    :Gateway => interface_info[3],
                    :DNS => interface_info[10],
                    :Connection_Status => dsl_state[dslstatus[0].to_sym].nil? ? dsl_state[:default] : dsl_state[dslstatus[0].to_sym],
                    :VPI => (@connection_type == 2 ? l2atm[2] : something),
                    :VCI => (@connection_type == 2 ? l2atm[3] : something),
                    :Broadband_Mode_Setting => (@connection_type == 2 ? (l2atm[11].match(/\A\d/) ? l2atm[11].insert(0, "VDSL2 - ") : (dsl_modes[l2atm[11].downcase.delete('^[0-9a-z]').to_sym].nil? ? dsl_modes[:default] : dsl_modes[l2atm[11].downcase.delete('^[0-9a-z]').to_sym])) : (l2ptm[7].match(/\A\d/) ? l2ptm[7].insert(0, "VDSL2 - ") : (dsl_modes[l2ptm[7].downcase.delete('^[0-9a-z]').to_sym].nil? ? dsl_modes[:default] : dsl_modes[l2ptm[7].downcase.delete('^[0-9a-z]').to_sym]))),
                    :Broadband_Negotiated_Mode => (@connection_type == 2 ? (l2atm[13].match(/vdsl/i) ? l2atm[11].insert(0, "VDSL2 - ") : (dsl_modes[l2atm[13].downcase.delete('^[0-9a-z]').to_sym].nil? ? dsl_modes[:default] : dsl_modes[l2atm[13].downcase.delete('^[0-9a-z]').to_sym])) : (l2ptm[10].match(/vdsl/i) ? l2ptm[7].insert(0, "VDSL2 - ") : (dsl_modes[l2ptm[10].downcase.delete('^[0-9a-z]').to_sym].nil? ? dsl_modes[:default] : dsl_modes[l2ptm[10].downcase.delete('^[0-9a-z]').to_sym]))),
                    :Upstream => @gui.current_page.parser.content.slice(/var\s*uprate.*;/i).delete('^[0-9]') + " Kbps",
                    :Downstream => @gui.current_page.parser.content.slice(/var\s*downrate.*;/i).delete('^[0-9]') + " Kbps",
                    :SNR_Downstream => dslstatus[4].split("/")[0] + " dB",
                    :SNR_Upstream => dslstatus[4].split("/")[1] + " dB",
                    :Attenuation_Downstream => dslstatus[5].split("/")[0] + " dB",
                    :Attenuation_Upstream => dslstatus[5].split("/")[1] + " dB",
                    :Power_Downstream => (dslstatus[17].split("/")[0].to_i > 0 ? dslstatus[17].split("/")[0].to_i/10 : 0).to_s + " dBm",
                    :Power_Upstream => (dslstatus[17].split("/")[1].to_i > 0 ? dslstatus[17].split("/")[1].to_i/10 : 0).to_s + " dBm",
                    :Retrains => dslstatus[6],
                    :ATM_QoS_Class => (@connection_type == 2 ? l2atm[4] : something),
                    :PTM_VLAN_QoS => (@connection_type == 2 ? something : l2ptm[9]),
                    :Retrain_Timer => ([timespan/86400, timespan%86400 / 3600, timespan/60 % 60, timespan % 60].map{|t| t.to_s.rjust(2, "0")}.join(":")),
                    :Near_End_CRC_Errors_Interleave => dslstatus[8].split('/')[0],
                    :Near_End_CRC_Errors_Fastpath => something,
                    :Far_End_CRC_Errors_Interleave => dslstatus[9].split('/')[0],
                    :Far_End_CRC_Errors_FastPpath => something,
                    :HalfHour_Near_End_CRC_Errors_Interleave => dslstatus[10].split('/')[0],
                    :HalfHour_Near_End_CRC_Errors_Fastpath => something,
                    :HalfHour_Far_End_CRC_Errors_Interleave => dslstatus[11].split('/')[0],
                    :HalfHour_Far_End_CRC_Errors_FastPpath => something,
                    :Near_End_RS_FEC_Interleave => dslstatus[12].split('/')[0],
                    :Near_End_RS_FEC_Fastpath => something,
                    :Far_End_RS_FEC_Interleave => dslstatus[13].split('/')[0],
                    :Far_End_RS_FEC_Fastpath => something,
                    :HalfHour_Near_End_RS_FEC_Interleave => dslstatus[14].split('/')[0],
                    :HalfHour_Near_End_RS_FEC_Fastpath => something,
                    :HalfHour_Far_End_RS_FEC_Interleave => dslstatus[15].split('/')[0],
                    :HalfHour_Far_End_RS_FEC_Fastpath => something,
                    :HalfHour_Discarded_Packets_Upstream => dslstatus[16].split('/')[0],
                    :HalfHour_Discarded_Packets_Downstream => dslstatus[16].split('/')[1]
                }
                @wan_ip = dsl_status[:IP_Address]
                order.each { |x| wan_results << "#{x.gsub('_', ' ').gsub("HalfHour", "30 Minute")}: #{dsl_status[x.to_sym]}\n" }
                wan_results.strip!
            end

            # Gets information from WAN ethernet if that is the connection type
            if @connection_type == 1
                @gui.get("#{@options.dut.url}/modemstatus_wanethstatus.html")
                order = %w{ Broadband Internet_Service_Provider MAC_Address IP_Address Subnet_Mask Gateway DNS Received_Packets Sent_Packets Uptime }
                # Status information from modemstatus_home.html

                # Mechanize doesn't interpret javascript actions, and because it's all stored there we need to get the variables straight
                # from the javascripting, and then interpret here in Ruby

                # Order for WAN Eth status is: Broadband, ISP, MAC, IP, Subnet, Gateway, DNS, Protocol, Received Packets, Sent Packets, Time Span (in seconds)
                value_sift = @gui.current_page.parser.content.select { |x| x.match(/var\s*wanEthStatus/i) }
                value_sift.each_index { |x| value_sift[x].strip!.delete!(" ';") }
                value_sift[1].sub!('=', '=Disabled') if value_sift[1].split('=')[1].nil?
                timespan = value_sift[9].split("=")[1].to_i
                wan_ethernet_status = {
                    :Broadband => ethernet_status_verbs[value_sift[0].split("=")[1].to_sym],
                    :Internet_Service_Provider => ethernet_status_verbs[value_sift[1].split("=")[1].to_sym],
                    :MAC_Address => value_sift[2].split("=")[1],
                    :IP_Address => (value_sift[3].split("=")[1] || "N/A"),
                    :Subnet_Mask => (value_sift[4].split("=")[1] || "N/A"),
                    :Gateway => (value_sift[5].split("=")[1] || "N/A"),
                    :DNS => (value_sift[6].split("=")[1] || "N/A"),
                    :Received_Packets => (value_sift[8].split("=")[1] || "0"),
                    :Sent_Packets => (value_sift[9].split("=")[1] || "0"),
                    :Uptime => [timespan/86400, timespan%86400 / 3600, timespan/60 % 60, timespan % 60].map{|t| t.to_s.rjust(2, "0")}.join(":")
                }
                @wan_ip = wan_ethernet_status[:IP_Address]
                order.each { |x| wan_results << "#{x.gsub('_', ' ')}: #{wan_ethernet_status[x.to_sym]}\n" }
                wan_results.strip!
            end

            # Order for LAN ethernet: Port, Speed, Sent, Received
            @gui.get("#{@options.dut.url}/modemstatus_lanstatus.html")
            value_sift = @gui.current_page.parser.content.select { |x| x.match(/eth\d_status/i) }
            value_sift.each_index { |x| value_sift[x].strip!.delete!(" ';") }

            lan_ethernet_status = {
                :Ethernet1 => "Status: #{value_sift[0].split("=")[1].split("/")[0]}; Speed: #{value_sift[0].split("=")[1].split("/")[2]}; Packets Sent: #{value_sift[0].split("=")[1].split("/")[3]}; Packets Received: #{value_sift[0].split("=")[1].split("/")[4]}",
                :Ethernet2 => "Status: #{value_sift[1].split("=")[1].split("/")[0]}; Speed: #{value_sift[1].split("=")[1].split("/")[2]}; Packets Sent: #{value_sift[1].split("=")[1].split("/")[3]}; Packets Received: #{value_sift[1].split("=")[1].split("/")[4]}",
                :Ethernet3 => "Status: #{value_sift[2].split("=")[1].split("/")[0]}; Speed: #{value_sift[2].split("=")[1].split("/")[2]}; Packets Sent: #{value_sift[2].split("=")[1].split("/")[3]}; Packets Received: #{value_sift[2].split("=")[1].split("/")[4]}",
                :Ethernet4 => "Status: #{value_sift[3].split("=")[1].split("/")[0]}; Speed: #{value_sift[3].split("=")[1].split("/")[2]}; Packets Sent: #{value_sift[3].split("=")[1].split("/")[3]}; Packets Received: #{value_sift[3].split("=")[1].split("/")[4]}"
            }

            # order for HPNA: Link Status, Sent, Received
            value_sift = @gui.current_page.parser.content.select { |x| x.match(/\s*var\s*hpna/i) }
            value_sift.each_index { |x| value_sift[x].strip!.delete!(" ';") }
            hpna_status = { :HPNALinkStatus => hpna_status_verbs[value_sift[0].split("=")[1].split("|")[0].to_sym], :PacketsSent => value_sift[0].split("=")[1].split(",")[1], :PacketsReceived => value_sift[0].split("=")[1].split(",")[2] }

            return "\nInformation from GUI\n#{wan_results}\n\nEthernet 1: #{lan_ethernet_status[:Ethernet1]}\nEthernet 2: #{lan_ethernet_status[:Ethernet2]}\nEthernet 3: #{lan_ethernet_status[:Ethernet3]}\nEthernet 4: #{lan_ethernet_status[:Ethernet4]}\n\nHPNA Status: #{hpna_status[:HPNALinkStatus]}\nPackets Sent: #{hpna_status[:PacketsSent]}\nPackets Received: #{hpna_status[:PacketsReceived]}"
        rescue Exception => e
            if retried
                if $debug
                    puts "Debug information: "
                    puts @gui.current_page.parser.content
                    puts e.message
                    puts e.backtrace
                end
                puts "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
                return "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
            elsif @gui.current_page
                if @gui.current_page.parser.content.match(/invalid user/i)
                    retried = true
                    set_gui_login
                    retry
                else
                    if $debug
                        puts "Debug information: "
                        puts @gui.current_page.parser.content
                        puts e.message
                        puts e.backtrace
                    end
                    puts "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
                    return "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
                end
            else
                if $debug
                    puts "Debug information: "
                    puts e.message
                    puts e.backtrace
                end
                puts "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
                return "[#{@ip}] Failed: Unable to successfully login to GUI even after trying default username and password"
            end
        end
    end

    def console_info
        retries = 0
        begin
            results = []
            swversion = { "String" => "swversion", "Match" => />/ }
            sysinfo = { "String" => "sysinfo", "Match" => />/ }
            meminfo = { "String" => "cat /proc/meminfo", "Match" => />/ }
            adslinfo = { "String" => "adsl info --show", "Match" => />/ }
            devinf = { "String" => "devinf -i br0 -v", "Match" => /#/ }
            # Open session and login
            session = Telnet.new("Host" => @options.dut.ip, "Port" => 23, :Timeout => 30)
            session.login(@options.user, @options.pass) { |x| raise "Connection closed" if x.nil? }

            # Console commands
            swver = clean_up(session.cmd(swversion), swversion["String"])
            results << clean_up(session.cmd(sysinfo), sysinfo["String"])
            results << clean_up(session.cmd(meminfo), meminfo["String"])
            results << clean_up(session.cmd(adslinfo), adslinfo["String"])


            # Shell commands
            session.puts("sh")
            session.waitfor(/#/)
            devinfo = clean_up(session.cmd(devinf), swversion["String"])

            session.puts("top")
            # Each default top cycle is 5 seconds long
            sleep @top_cycles * 5
            # Stops top
            session.print("\003")
            # Log top data
            top = (session.readpartial(1048576)).split("\e[H\e[J")[1..-1]
            0.upto(@top_cycles-1) do |x|
                results << clean_up(top[x], "top")
            end
            
            # Logout
            session.puts("exit")
            session.waitfor(/>/)
            session.puts("exit")
            session.close
            return "\nInformation from console\n\nTelnet Retries: #{retries}\nSoftware Version: #{swver}\n\nSystem info:\nDevice Uptime: #{results[0][1].split("up")[1].strip.sub(/,\z/, "")}\n#{results[0][0]+"\n"+results[0][2..-1].join("\n")}\n\nMemory info:\n#{results[1].join("\n")}\n\nProcess info: \n#{results[3..-1].join("\n")}\n\nxDSL Status:\n#{results[2].join("\n")}\n\nHPNA Status:\n#{devinfo[1..-1].join("\n")}"
        rescue Exception => e
            if retries < 6
                if $debug
                    puts "Debug information: "
                    puts e.message
                    puts e.backtrace
                end
                retries += 1
                enable_telnet unless @telnet_enabled
                sleep 10
                retry
            else
                puts "[#{@ip}] Failed: Unable to successfully login to console (telnet) even after trying to enable telnet access via GUI"
                return "[#{@ip}] Failed: Unable to successfully login to console (telnet) even after trying to enable telnet access via GUI"
            end
        end
    end

    def info_cycle
        @results = ""
        pr = ping(@ip)
        if pr[0] > 3
            @results << "LAN Ping failed: #{pr[1]}"
            @results << "Unable to contact DUT"
            puts "LAN Ping failed: #{pr[1]}"
            puts "Unable to contact DUT"
        else
            gi = gui_info
            ci = console_info
            @wan_ip = "" if @wan_ip.nil?
            @wan_ip = "" if @wan_ip.match(/n.a/i)
            if gi && ci
                @results << gi.gsub("\n", "\n- ").sub("\n- Information from", "\n[#{@ip}] Information from").strip
                @results << "\n[#{@ip}] End of Information from GUI\n"
                @results << "-"*80
                @results << "\n"
                @results << ci.gsub("\n", "\n- ").sub("\n- Information from", "\n[#{@ip}] Information from").strip
                @results << "\n[#{@ip}] End of Information from Telnet\n"
                @results << "-"*80
                @results << "\n[#{@ip}] Ping information\n- "
                @results << "\nLAN - \n#{pr[1]}".gsub("\n", "\n- ")
                @results << "\nWAN - \n#{@wan_ip.empty? ? "No WAN IP address found" : ping(@wan_ip)[1]}".gsub("\n", "\n- ")
            end
        end
    end
end

def log(device, prefix, ts)
    if prefix.empty?
        puts "="*80
        puts "[Timestamp: #{Time.now}]\n"
        puts device.results
        puts ts.strip
        puts "[#{device.ip}] End ping information"
        puts "="*80
    else
        logfile = "#{prefix}#{device.ip.gsub(".", "_")}.log"
        out = File.open(logfile, "a")
        out.puts "="*80
        out.puts("[Timestamp: #{Time.now}]\n")
        out.puts(device.results)
        out.puts(ts.strip)
        out.puts("[#{device.ip}] End ping information")
        out.puts "="*80
        out.close
    end
end

opts.parse!(ARGV)
devices = []
options.dut.each { |d| devices << DeviceInfo.new(d, options.username, options.password, options.top_cycles) }
threads = []

# Create log files
devices.each { |device| File.new("#{options.output}#{device.ip.gsub(".", "_")}.log", "w+") if options.overwrite } unless options.output.empty?

while true
    puts "Getting device information..."
    ts = "\nTest Server - #{`ping -c 4 #{options.testserver_ip}`}".gsub("\n", "\n- ")
    devices.each { |device| threads << Thread.new { device.info_cycle } }
    sleep 20
    threads.each { |t| t.join }
    devices.each do |device| 
        log(device, options.output, ts)
    end
    puts "Finished."
    break if options.interval == 0
    puts options.interval == 1 ? "Sleeping for #{options.interval} minute..." : "Sleeping for #{options.interval} minutes..."
    sleep options.interval*60
end