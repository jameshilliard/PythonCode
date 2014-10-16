#!/usr/bin/env ruby
# Gets information from a Q1000H and passes it into whichever test tool is required.
# This setup allows to do cross configuration scenarios with more ease. 

$: << File.dirname(__FILE__)

require 'rubygems'
require 'firewatir'
require 'user-choices'
require 'common/ipcheck'
require 'common/log'
require 'configuration/login_menu'

class Testing < UserChoices::Command
    # Modules that are required
    include UserChoices
    include Log
    include LoginMenu

    def initialize(file="")
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        logs(@user_choices[:log_file], 4-@user_choices[:debug], @user_choices[:verbose])
        @menu_links = {
            :status => {
                :top => "modemstatus_home",
                :connection_status => "modemstatus_home",
                :lan_status => "modemstatus_lanstatus",
                :nat_table => "modemstatus_nattable",
                :routing_table => "modemstatus_routingtable",
                :wan_status => "modemstatus_wanstatus",
                :wireless_status => "modemstatus_wirelessstatus",
                :lan_device_list => "modemstatus_activeuserlist",
                :firewall_status => "modemstatus_firewallstatus",
                :modem_utilization => "modemstatus_modemutilization"
            },
            :tr69 => { :top => "tr69.html" },
            :quick_setup => { :top => "quicksetup" },
            :wireless_setup => {
                :top => "wirelesssetup_basicsettings",
                :basic_settings => "wirelesssetup_basicsettings",
                :multiple_ssid => "wirelesssetup_multiplessid",
                :wep => "wirelesssetup_wep",
                :wep_8021x => "wirelesssetup_wep8021x",
                :wpa => "wirelesssetup_wpa",
                :wmm => "wirelesssetup_wmm",
                :wps => "wirelesssetup_wps",
                :ssid_broadcast => "wirelesssetup_ssidbroadcast",
                :mac_authentication => "wirelesssetup_wirelessmacauthentication",
                :wireless_mode => "wirelesssetup_80211n",
                :channel => "wirelesssetup_channel"
            },
            :utilities => {
                :top => "utilities_reboot",
                :reboot => "utilities_reboot",
                :restore_defaults => "utilities_restoredefaultsettings",
                :upgrade_firmware => "utilities_upgradefirmware",
                :ping_test => "utilities_ipping",
                :traceroute => "utilities_traceroute",
                :web_activity_log => "utilities_webactivitylog",
                :time_zone => "utilities_timezone"
            },
            :advanced_setup => {
                :top => "advancedsetup_schedulingaccess",
                :services_blocking => "advancedsetup_servicesblocking",
                :website_blocking => "advancedsetup_websiteblocking",
                :scheduling_access => "advancedsetup_schedulingaccess",
                :broadband_settings => "advancedsetup_broadbandsettings",
                :dhcp_settings => "advancedsetup_dhcpsettings",
                :dhcp_reservation => "advancedsetup_dhcpreservation",
                :lan_ip_address => "advancedsetup_lanipaddress",
                :wan_ip_address => "advancedsetup_wanipaddress",
                :dns_host_mapping => "advancedsetup_dnshostmapping",
                :dynamic_dns => "advancedsetup_dynamicdns",
                :qos_upstream => "advancedsetup_upstream",
                :qos_downstream => "advancedsetup_downstream",
                :remote_gui => "advancedsetup_remotegui",
                :remote_telnet => "advancedsetup_remotetelnet",
                :dynamic_routing => "advancedsetup_dynamicrouting",
                :static_routing => "advancedsetup_staticrouting",
                :admin_password => "advancedsetup_admin",
                :port_forwarding => "advancedsetup_advancedportforwarding",
                :applications => "advancedsetup_applications",
                :dmz_hosting => "advancedsetup_dmzhosting",
                :firewall => "advancedsetup_firewallsettings",
                :nat => "advancedsetup_nat",
                :upnp => "advancedsetup_upnp"
            }
        }
    end

    # Set up sources for getting the intended configuration via user choices
    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options]")
        builder.add_source(YamlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/yml|yaml/i)
        builder.add_source(XmlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/xml/i)
        builder.add_source(EnvironmentSource, :with_prefix, "q1000_")
    end

    # Define choices
    def add_choices(builder)
        # Script settings
        builder.add_choice(:config_file) { |command_line| command_line.uses_option("-f", "--file FILE", "Config file to use in XML or YAML format") }
        builder.add_choice(:dut, :type=>[:string], :default=>["192.168.0.1"]) { |command_line| command_line.uses_option("--dut_interface ADDRESS,USER,PASS", "IP address, username, and password (if required) for a Q1000 device to configure") }
        builder.add_choice(:debug, :type=>:integer, :default=>3) { |command_line| command_line.uses_option("--debug LEVEL", "Set debug value - default is 3 (highest)") }
        builder.add_choice(:verbose, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--verbose", "Enables/disables console output") }
        builder.add_choice(:log_file) { |command_line| command_line.uses_option("--output FILE", "Set output log file; If not set, no log file is created") }
        builder.add_choice(:firefox_profile) { |command_line| command_line.uses_option("--profile PROFILE", "Sets Firefox profile") }
        builder.add_choice(:after_test_file) { |command_line| command_line.uses_option("--after_test_file FILE", "Set file to record command line options to read back in later as a post test option") }
        builder.add_choice(:after_test) { |command_line| command_line.uses_option("--after_test FILE", "Run an 'after test' from the specified file") }
        builder.add_choice(:check) { |command_line| command_line.uses_option("--check STATE", "Check state for 'after tests'") }

        # Supported test scenarios
        builder.add_choice(:port_forwarding, :type=>:boolean) { |command_line| command_line.uses_switch("--port_forwarding", "Tests port forwarding") }
        builder.add_choice(:firewall, :type=>:boolean) { |command_line| command_line.uses_switch("--firewall", "Tests firewall") }
        builder.add_choice(:iperf, :type=>:boolean) { |command_line| command_line.uses_switch("--iperf", "Adds iperf testing to certain tests - like port forwarding") }
        builder.add_choice(:iperf_interval, :type=>:integer, :default=>2) { |command_line| command_line.uses_option("--iperf_interval INT", "In case of a range, it will test the range in intervals of INT. By default this is 2") }
        builder.add_choice(:nat, :type=>:boolean) { |command_line| command_line.uses_switch("--nat", "Tests NAT") }
        builder.add_choice(:applications, :type=>:boolean) { |command_line| command_line.uses_switch("--applications", "Tests applications") }
    end

    # Method to get items from Firewall
    def firewall
        return unless self.menu(:advanced_setup, :firewall)
        in_scan_rules = []
        out_scan_rules = []
        scan_threads = []
        scan_results = []
        ports = {
            :directx => "2300-2400,47624;2300-2400,6073",
            :stb1 => "27161-27163",
            :stb2 => "27171-27173",
            :stb3 => "27181-27183",
            :dns => "53",
            :ftp => "20-21",
            :ftps => "990",
            :h323 => "1720",
            :http => "80",
            :https => "443",
            :imap => "143",
            :imaps => "993",
            :ipp => "631",
            :ipsec => "50;51-500",
            :irc => "113,194,1024-1034,6661-7000",
            :l2tp => ";1701",
            :msn_gaming => "28800-29100;28800-29100",
            :mysql => "3306",
            :nntp => "119",
            :ntp => "123",
            :oracle => "66,1525",
            :pcanywhere => "66,5631-5632;66,5631-5632",
            :pptp => "1723",
            :pop3 => "110",
            :pop3s => "995",
            :ps23 => "4658-4659;4658-4659",
            :rip => ";520",
            :real_av => "7070",
            :realserver => "7070;6970-7170",
            :sftp => "22,115",
            :sip => "5060",
            :sling => "5001",
            :smtp => "25",
            :sql => "1433",
            :ssh => "22",
            :t120 => "1503",
            :telnet => "23",
            :vnc => "5500,5800-5801,5900-5901",
            :gmail => "995",
            :wm => "1024-1030",
            :ws => "135-139,445,1434",
            :xbox => "53,3074;53,88,3074",
            :yahoo => "500-5010,5050,5100,6600-6699"
        }
        # VMC = VNC. The developers can't spell "VNC" correctly. Amazing.

        scan_target_in = "--target #{@modem_ip_address}"
        scan_target_out = "--target 10.10.10.1 --local"

        # See if firewall is on NAT only, in which case there's nothing to really test here
        if @ff.radio(:id, "stealth_mode_disable").checked?
            @log.info("Firewall::Firewall is currently set to NAT only. Everything should be opened. Skipping check.")
            return
        end

        ports.each_key do |key|
            tcp_ports,udp_ports = ports[key].split(';')
            if @ff.checkbox(:id, "#{key.to_s}_in").checked?
                in_scan_rules << "--check open --protocol TCP --port #{tcp_ports} #{scan_target_in}" unless tcp_ports.empty?
                in_scan_rules << "--check open --protocol UDP --port #{udp_ports} #{scan_target_in}" unless udp_ports.nil?
            else
                in_scan_rules << "--check filtered --protocol TCP --port #{tcp_ports} #{scan_target_in}" unless tcp_ports.empty?
                in_scan_rules << "--check filtered --protocol UDP --port #{udp_ports} #{scan_target_in}" unless udp_ports.nil?
            end
            
            # Work around needed here for realav_out since there is no consistency in this tag
            if @ff.checkbox(:id, "#{key == :real_av ? key.to_s.delete('_') : key.to_s}_out").checked?
                out_scan_rules << "--check open --protocol TCP --port #{tcp_ports} #{scan_target_out}" unless tcp_ports.empty?
                out_scan_rules << "--check open --protocol UDP --port #{udp_ports} #{scan_target_out}" unless udp_ports.nil?
            else
                out_scan_rules << "--check filtered --protocol TCP --port #{tcp_ports} #{scan_target_out}" unless tcp_ports.empty?
                out_scan_rules << "--check filtered --protocol UDP --port #{udp_ports} #{scan_target_out}" unless udp_ports.nil?
            end
        end
        
        @log.debug("Beginning inbound scan")

        scan_results << "Results from inbound port scan"
        in_scan_rules.each_index do |i|
            if scan_threads.length > 5
                @log.debug("Joining threads")
                scan_threads.each {|t| t.join }
                @log.debug("Clearing threads")
                scan_threads.clear
            end
            scan_threads << Thread.new { @log.debug("Scanning: [#{i}] #{in_scan_rules[i]}"); scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/portscan.rb #{in_scan_rules[i]}`; @log.debug("Finished: [#{i}] #{in_scan_rules[i]}") }
        end

        # Join/reset threads before doing outbound scan
        scan_threads.each {|t| t.join }
        scan_threads.clear

        scan_results << "Results from outbound port scan"
        @log.debug("Beginning outbound scan")
        out_scan_rules.each_index do |i|
            if scan_threads.length > 5
                @log.debug("Joining threads")
                scan_threads.each {|t| t.join }
                @log.debug("Clearing threads")
                scan_threads.clear
            end
            scan_threads << Thread.new { @log.debug("Scanning: [#{i}] #{out_scan_rules[i]}"); scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/portscan.rb #{out_scan_rules[i]}`; @log.debug("Finished: [#{i}] #{out_scan_rules[i]}") }
        end
        
        scan_threads.each {|t| t.join }

        scan_results.each { |x| @log.info(x) }
        if @user_choices.key?(:after_test_file)
            @log.info("Creating parameter file #{@user_choices[:after_test_file]}")
            after_test = File.open(@user_choices[:after_test_file], "w+")
            all_rules = ["Begin inbound tests (nmap) (firewall)"]+in_scan_rules+["Begin outbound tests (nmap) (firewall)"]+out_scan_rules
            all_rules.each { |rule| after_test.write(rule.sub(/--check filtered |--check open /, "")+"\n") }
            after_test.close
        end
    end

    # Method to get items from port forwarding
    def port_forwarding
        return unless self.menu(:advanced_setup, :port_forwarding)
        # Get the rules row by row first
        table_count = 2
        all_rules = []

        # Hash to store all the sorted rules
        sorted_rules = {}

        while @ff.element_by_xpath("/html/body/div/div[3]/div/form/div[11]/table/tbody/tr[#{table_count}]/td").exists?
            all_rules << @ff.elements_by_xpath("/html/body/div/div[3]/div/form/div[11]/table/tbody/tr[#{table_count}]/td").join(";")
            table_count += 1
        end

        # Now that we have all the rules, sort them out by IP address with options
        # Format here is: start/end ports, protocol, lan IP address, start/end remote port, remote IP address
        all_rules.each do |rule|
            current_ip = rule.split(";")[2].strip
            current_protocol = rule.split(";")[1].strip
            current_ports = rule.split(";")[0].strip.sub('/', '-')
            current_ports = current_ports.split("-")[0] if current_ports.split("-")[0] == current_ports.split("-")[1]
            remote_ip = rule.split(";")[4].strip
            remote_ports = rule.split(";")[3].strip.sub('/', '-')
            remote_ports = remote_ports.split("-")[0] if remote_ports.split("-")[0] == remote_ports.split("-")[1]
            remote_ports = "0000" if current_ports == remote_ports
            sorted_rules[current_ip] = {} unless sorted_rules.member?(current_ip)
            sorted_rules[current_ip][current_protocol] = {} unless sorted_rules[current_ip].member?(current_protocol)
            sorted_rules[current_ip][current_protocol][remote_ip] = {} unless sorted_rules[current_ip][current_protocol].member?(remote_ip)
            sorted_rules[current_ip][current_protocol][remote_ip][remote_ports] = "" unless sorted_rules[current_ip][current_protocol][remote_ip].member?(remote_ports)
            sorted_rules[current_ip][current_protocol][remote_ip][remote_ports] << "," unless sorted_rules[current_ip][current_protocol][remote_ip][remote_ports].empty?
            sorted_rules[current_ip][current_protocol][remote_ip][remote_ports] << "#{current_ports}"
        end
        
        return sorted_rules
    end

    # This method creates an interface between the port forwarding rules in the GUI, and the command line of tools/portscan.rb to get results
    def port_forwarding_test(rules)
        scan_rules = []
        scan_results = []
        scan_threads = []
        iperf_rules = []
        
        rules.each_key do |destination_ip|
            scan_target = "--target #{@modem_ip_address}"
            # Port forwarding is all incoming, so the server will always be local. Defaults in the iperf test so we don't have to do it here; Destination IP is used for iperf server bind IP
            iperf_test = "--target #{@modem_ip_address} --server_bind_ip #{destination_ip}"
            # First parse out the protocol to each system
            rules[destination_ip].each_key do |protocol|
                scan_protocol = "--protocol #{protocol}"
                iperf_test << " --protocol #{protocol}"
                # Get the remote IP we are using. This is the bind ip of the remote system to use during the scan
                rules[destination_ip][protocol].each_key do |remote_ip|
                    IPCommon::ip_int(remote_ip) == 0 ? scan_remote_ip = "" : scan_remote_ip = "--bind_ip #{remote_ip}" && iperf_test << " --client_bind_ip #{remote_ip}"
                    rules[destination_ip][protocol][remote_ip].each_key do |remote_ports|
                        # Remote ports aren't explained correctly.
                        # These are the WAN ports that we will be scanning and NOT source ports as the GUI indicates by it's reference to the remote side
                        # To counter this really badly worded design, we will use these ports as the primary port to scan if it's not equal to 0
                        # and use the LAN side ports as the proper port to scan.
                        # This is done above during sorting of the rules.
                        remote_ports.to_i == 0 ? scan_remote_ports = rules[destination_ip][protocol][remote_ip][remote_ports] : scan_remote_ports = remote_ports
                        scan_rules << "--check open #{scan_target} #{scan_protocol} #{scan_remote_ip} --port #{scan_remote_ports}".squeeze(" ")

                        # Setup for iperf tests here as we're done setting up for nmap above
                        rules[destination_ip][protocol][remote_ip][remote_ports].split(',').each do |server_port|
                            if server_port.include?("-")
                                ((server_port.split('-')[0].to_i)..(server_port.split('-')[1].to_i)).step(@user_choices[:iperf_interval]) do |x|
                                    if remote_ports.include?("-")
                                        ((remote_ports.split('-')[0].to_i)..(remote_ports.split('-')[1].to_i)).step(@user_choices[:iperf_interval]) { |y| iperf_rules << iperf_test + " --server_port #{x} --port #{y}" }
                                    elsif remote_ports.to_i == 0
                                        iperf_rules << iperf_test + " --port #{x}"
                                    else
                                        iperf_rules << iperf_test + " --server_port #{x} --port #{remote_ports}"
                                    end
                                end
                            else
                                if remote_ports.include?("-")
                                    ((remote_ports.split('-')[0].to_i)..(remote_ports.split('-')[1].to_i)).step(@user_choices[:iperf_interval]) { |y| iperf_rules << iperf_test + " --server_port #{server_port} --port #{y}" }
                                elsif remote_ports.to_i == 0
                                    iperf_rules << iperf_test + " --port #{server_port}"
                                else
                                    iperf_rules << iperf_test + " --port #{remote_ports} --server_port #{server_port}"
                                end
                            end
                        end
                    end
                end
            end
        end

        @log.debug("Running nmap scan")
        scan_rules.each do |port_scan|
            scan_threads << Thread.new { scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/portscan.rb #{port_scan}` }
        end

        @log.debug("Joining threads")
        scan_threads.each {|t| t.join }
        @log.debug("Clearing threads")
        scan_threads.clear

        if @user_choices[:iperf]
            @log.debug("Starting iperf tests")
            iperf_rules.each_index do |i|
                scan_threads << Thread.new { @log.debug("Testing: [#{i}] #{iperf_rules[i]}"); scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb #{iperf_rules[i]}`; @log.debug("Finished: [#{i}] #{iperf_rules[i]}") }
            end

            @log.debug("Joining threads")
            scan_threads.each {|t| t.join }
            @log.debug("Clearing threads")
            scan_threads.clear
        end
        scan_results.each { |x| @log.info(x) }
        if @user_choices.key?(:after_test_file)
            @log.info("Creating parameter file #{@user_choices[:after_test_file]}")
            after_test = File.open(@user_choices[:after_test_file], "w+")
            all_rules = ["Begin inbound tests (nmap) (port forwarding)"]+scan_rules+["Begin inbound tests (iperf) (port forwarding)"]+iperf_rules
            all_rules.each { |rule| after_test.write(rule.sub(/--check filtered |--check open /, "")+"\n") }
            after_test.close
        end
    end

    def after_test
        scan_results = []
        scan_threads = []
        current_command = "ruby $SQAROOT/bin/1.0/q1000/tools/portscan.rb"
        rules = File.open(@user_choices[:after_test]).readlines
        rules.each_index do |i|
            if rules[i].match(/\A--/)
                scan_threads << Thread.new { @log.debug("Scanning: [#{i}] #{rules[i].chomp} --check #{@user_choices[:check]}"); scan_results << `#{current_command} #{rules[i].chomp} #{current_command.match(/iperf/i) ? "--no-data" : "--check #{@user_choices[:check]}"}`; @log.debug("Finished: [#{i}] #{rules[i].chomp} --check #{@user_choices[:check]}") }
                if scan_threads.length > 5
                    @log.debug("Joining threads")
                    scan_threads.each {|t| t.join }
                    @log.debug("Clearing threads")
                    scan_threads.clear
                end
            else
                puts rules[i].chomp
                case rules[i]
                when /iperf/i
                    # Clear threads so it doesn't call the wrong command
                    if scan_threads.length > 0
                        @log.debug("Joining threads to start IPERF testing")
                        scan_threads.each {|t| t.join }
                        @log.debug("Clearing threads")
                        scan_threads.clear
                    end
                    current_command = "ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb"
                when /nmap/i
                    # Clear threads so it doesn't call the wrong command
                    if scan_threads.length > 0
                        @log.debug("Joining threads to start NMAP testing")
                        scan_threads.each {|t| t.join }
                        @log.debug("Clearing threads")
                        scan_threads.clear
                    end
                    current_command = "ruby $SQAROOT/bin/1.0/q1000/tools/portscan.rb"
                end
            end
        end
        scan_threads.each {|t| t.join }

        scan_results.each { |x| @log.info(x) }
    end

    # NAT test
    def nat
        return unless self.menu(:advanced_setup, :nat)
        scan_results = []
        if @ff.radio(:id, "nat_on").checked?
            # Test if on
            @log.debug("Testing: [1] --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1")
            scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1`
            @log.debug("Finished: [1] [1] --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1")
            @log.debug("Testing: [1] --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1")
            scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1`
            @log.debug("Finished: [1] [1] --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1")
        else
            # Test if off
            @log.debug("Testing: [1] --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data")
            scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data`
            @log.debug("Finished: [1] [1] --protocol TCP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data")
            @log.debug("Testing: [1] --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data")
            scan_results << `ruby $SQAROOT/bin/1.0/q1000/tools/iperf_test.rb --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data`
            @log.debug("Finished: [1] [1] --protocol UDP --port 6000 --local_client --no-local_server --target 10.10.10.1 --no-data")
        end
        scan_results.each { |x| @log.info(x) }
    end

    # Applications Test
    def applications
        ports = {}
        return unless self.menu(:advanced_setup, :applications)
        app_count = 2
        @log.debug("Gathering port information")
        while @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/div/table[4]/tbody/tr[#{app_count}]/td[2]").length > 0
            info = @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/div/table[4]/tbody/tr[#{app_count}]/td[2]")[2..3].join(",")
            mem = info.split(",")[1].gsub(' ', '_').to_sym
            ports[mem] = { :TCP => "", :UDP => "", :IP => info.split(",")[0] }
            @ff.select_list(:id, "application").select(app.innerHTML)
            @ff.link(:id, "viewrule_btn").click
            count = 2
            port_temp = []
            while @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/div[2]/table/tbody/tr[#{count}]/td").length > 0
                port_temp << @ff.elements_by_xpath("/html/body/div/div[4]/div[2]/form/div[2]/table/tbody/tr[#{count}]/td").join(",")
                count += 1
            end
            port_temp.each do |x|
                case x.split(',')[1]
                when /udp/i
                    ports[mem][:UDP] << "#{x.split(',')[2]}#{x.split(',')[3] == x.split(',')[2] ? '' : "-#{x.split(',')[3]}"},"
                when /tcp or udp/i
                    ports[mem][:UDP] << "#{x.split(',')[2]}#{x.split(',')[3] == x.split(',')[2] ? '' : "-#{x.split(',')[3]}"},"
                    ports[mem][:TCP] << "#{x.split(',')[2]}#{x.split(',')[3] == x.split(',')[2] ? '' : "-#{x.split(',')[3]}"},"
                when /tcp/i
                    ports[mem][:TCP] << "#{x.split(',')[2]}#{x.split(',')[3] == x.split(',')[2] ? '' : "-#{x.split(',')[3]}"},"
                end
            end
            @ff.link(:id, "back_btn").click
            ports[mem][:TCP].sub(/,\z/, '')
            ports[mem][:UDP].sub(/,\z/, '')
            app_count += 1
        end
        pp ports
    end

    # Begin parsing here
    def test_dut
        begin
            if @user_choices.key?(:after_test)
                self.after_test
            else
                # Get firefox up
                self.start_firefox
                ff_started = TRUE
                # Get modem IP information
                self.menu(:status)
                # /html/body/div/div[3]/div/div[5]/table/tbody/tr[11]/td[2]/div/span/font/strong
                @modem_ip_address = @ff.elements_by_xpath("/html/body/div/div[3]/div/div[5]/table/tbody/tr[11]/td[2]/div/span/font/strong")[0].innerHTML
                if @user_choices[:port_forwarding]
                    port_forwarding_rules = self.port_forwarding
                    @ff.close
                    ff_started = FALSE
                    port_forwarding_test(port_forwarding_rules)
                end

                self.firewall if @user_choices[:firewall]
                self.nat if @user_choices[:nat]
                self.applications if @user_choices[:nat]
            end
        ensure
            @ff.close if defined?(@ff) && ff_started
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
Testing.new(config_file).test_dut