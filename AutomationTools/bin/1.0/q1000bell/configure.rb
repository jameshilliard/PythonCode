#!/usr/bin/env ruby
# Configures a Q1000H NCS or Bell firmware. See Q1000 for Qwest

$: << File.dirname(__FILE__)

require 'rubygems'
require 'firewatir'
require 'user-choices'
require 'common/ipcheck'
require 'common/log'
require 'configuration/login_menu'
#require 'configuration/status'
require 'configuration/quick_setup'
require 'configuration/wireless_setup'
require 'configuration/utilities'
require 'configuration/advanced_setup'
require 'configuration/tr69'

class Configure < UserChoices::Command
    # Modules that are required
    include TR69
    include UserChoices
    include Log
    include LoginMenu
    #include Status_Menu
    include QuickSetup
    include WirelessSetup
    include Utilities
    include AdvancedSetup

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
                :top => "/html/body/div/div[2]/div[2]/ul/li[2]/a",
                :top_url => "modemstatus_home.html",
                :connection_status => "home",
                :lan_status => "lanstatus",
                :nat_table => "nattable",
                :routing_table => "routingtable",
                :wan_status => "wanstatus",
                :wireless_status => "wirelessstatus",
                :lan_device_list => "activeuserlist",
                :firewall_status => "firewallstatus",
                :modem_utilization => "modemutilization"
            },
            :tr69 => { 
                :top => "tr69.html",
                :top_url => "tr69.html"
            },
            :quick_setup => { 
                :top => "/html/body/div/div[2]/div[2]/ul/li[3]/a",
                :top_url => "quicksetup.html"
            },
            :wireless_setup => {
                :top => "/html/body/div/div[2]/div[2]/ul/li[4]/a",
                :top_url => "wirelesssetup_basicsettings.html",
                :basic_settings => "basicsettings",
                :multiple_ssid => "multiplessid",
                :wep => "wep",
                :wep_8021x => "wep8021x",
                :wpa => "wpa",
                :wmm => "wmm",
                :wps => "wps",
                :ssid_broadcast => "ssidbroadcast",
                :mac_authentication => "wirelessmacauthentication",
                :wireless_mode => "80211n",
                :channel => "channel"
            },
            :utilities => {
                :top => "/html/body/div/div[2]/div[2]/ul/li[5]/a",
                :top_url => "utilities_reboot.html",
                :reboot => "reboot",
                :restore_defaults => "restoredefaultsettings",
                :upgrade_firmware => "upgradefirmware",
                :ping_test => "advancedutilities_ipping",
                :traceroute => "advancedutilities_traceroute",
                :web_activity_log => "webactivitylog",
                :time_zone => "timezone"
            },
            :advanced_setup => {
                :top => "/html/body/div/div[2]/div[2]/ul/li[6]/a",
                :top_url => "advancedsetup_servicesblocking.html",
                :services_blocking => "advancedsetup_servicesblocking",
                :website_blocking => "advancedsetup_websiteblocking",
                :scheduling_access => "advancedsetup_schedulingaccess",
                :broadband_settings => "broadbandsettings",
                :wan_ethernet_settings => "waneth",
                :hpna_lan => "advancedsetup_hpna",
                :dhcp_settings => "advancedsetup_lanipdhcpsettings",
                :dhcp_reservation => "advancedsetup_dhcpreservation",
                :lan_ip_address => "advancedsetup_lanipdhcpsettings",
                :wan_ip_address => "advancedsetup_wanip",
                :vlan_settings => "advancedsetup_wanvlans",
                :dns_host_mapping => "advancedsetup_dnshostmapping",
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
        # misc
        builder.add_choice(:rawhtml, :type=>[:string]) { |command_line| command_line.uses_option("--rawhtml SECTION,SUBECTION", "Returns raw HTML from page section/subsection. Use 'list' to get the list of sections and subsections") }
        builder.add_choice(:acs_url) { |command_line| command_line.uses_option("--acs_url URL", "Changes the TR69 ACS URL") }

        # Script settings
        builder.add_choice(:config_file) { |command_line| command_line.uses_option("-f", "--file FILE", "Config file to use in XML or YAML format") }
        builder.add_choice(:dut, :type=>[:string], :default=>["192.168.0.1"]) { |command_line| command_line.uses_option("--dut_interface ADDRESS,USER,PASS", "IP address, username, and password (if required) for a Q1000 device to configure") }
        builder.add_choice(:debug, :type=>:integer, :default=>3) { |command_line| command_line.uses_option("--debug LEVEL", "Set debug value - default is 3 (highest)") }
        builder.add_choice(:verbose, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--verbose", "Enables/disables console output") }
        builder.add_choice(:log_file) { |command_line| command_line.uses_option("--output FILE", "Set output log file; If not set, no log file is created") }
        builder.add_choice(:firefox_profile) { |command_line| command_line.uses_option("--profile PROFILE", "Sets Firefox profile") }
        builder.add_choice(:apply, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--apply", "Applies settings. This is the default action. Use --no-apply to disable applying settings (for testing the script)") }

        # Quick setup settings
        builder.add_choice(:ppp_username, :type=>:string) { |command_line| command_line.uses_option("--ppp_username USERNAME", "Specifies the PPP username to use for quick setup and advanced setup options") }
        builder.add_choice(:ppp_password, :type=>:string) { |command_line| command_line.uses_option("--ppp_password PASSWORD", "Specifies the PPP password to use for quick setup and advanced setup options") }

        # Wireless settings
        builder.add_choice(:wireless, :type=>:boolean) { |command_line| command_line.uses_switch("--wireless", "Turns wireless on or off") }
        builder.add_choice(:wireless_ssid, :type=>:string) { |command_line| command_line.uses_option("--wireless_ssid SSID", "Specifies the wireless SSID to set or choose for multiple SSID changes") }
        builder.add_choice(:mssid_name) { |command_line| command_line.uses_option("--mssid_name SSID", "Changes the multiple SSID (specified by wireless_ssid) name. Use 'off' or 'disable' to turn off the SSID state") }
        builder.add_choice(:mssid_settings, :type=>[:string]) { |command_line| command_line.uses_option("--mssid_settings DHCP_START,END,GATEWAY,SUBNET", "Enables and changes the multiple SSID (specified by wireless_ssid) settings. Set to 'off' or 'disable' to disable separate subnet") }
        builder.add_choice(:wep_authentication_type) { |command_line| command_line.uses_option("--wep_authentication_type TYPE", "Sets authentcation type to open or shared as specified") }
        builder.add_choice(:wep_key, :type=>[:string]) { |command_line| command_line.uses_option("--wep_key KEY", "Set WEP key to specified. You may use [1-4],KEY to specify the index to use. Set to 'default' to use default") }
        builder.add_choice(:wep_8021x, :type=>[:string]) { |command_line| command_line.uses_option("--wep_8021x SERVER,PORT,SECRET,INTERVAL", "Set SSID specified to use 802.1x with the given server IP address, port, secret, and group key interval. Set to 'off' or 'disable' to disable 802.1x") }
        builder.add_choice(:wpa_key) { |command_line| command_line.uses_option("--wpa_key KEY", "Set WPA key to specified. Use 'default' to set to default key") }
        builder.add_choice(:wpa_type) { |command_line| command_line.uses_option("--wpa_type TYPE", "Set to WPA, WPA2 or BOTH") }
        builder.add_choice(:wpa_cipher) { |command_line| command_line.uses_option("--wpa_cipher TYPE", "Set to AES, TKIP, or BOTH") }
        builder.add_choice(:wpa_enterprise, :type=>[:string]) { |command_line| command_line.uses_option("--wpa_enterprise INTERVAL,SERVER,PORT,SECRET", "Set SSID specified to use enterprise settings with the given server IP address, port, secret, and group key interval. Set to 'off' or 'disable' to disable enterprise settings") }
        builder.add_choice(:wmm, :type=>:boolean) { |command_line| command_line.uses_switch("--wmm", "Turn on or off WMM") }
        builder.add_choice(:wmm_powersave, :type=>:boolean) { |command_line| command_line.uses_switch("--wmm_powersave", "Turn on or off WMM power save mode") }
        builder.add_choice(:wps, :type=>:boolean) { |command_line| command_line.uses_option("--wps", "Set to enable or disable") }
        builder.add_choice(:wps_pbc, :type=>:boolean) { |command_line| command_line.uses_switch("--wps_pbc", "Enable push button configuration") }
        builder.add_choice(:wps_generate_pin, :type=>:boolean) { |command_line| command_line.uses_switch("--wps_generate_pin", "Generate a WPS pin") }
        builder.add_choice(:wps_restore_pin, :type=>:boolean) { |command_line| command_line.uses_switch("--wps_restore_pin", "Restore to default pin") }
        builder.add_choice(:wps_edp, :type=>:string) { |command_line| command_line.uses_option("--wps_edp PIN", "Use end device pin and set pin to specified value") }
        builder.add_choice(:wps_connect, :type=>:boolean) { |command_line| command_line.uses_switch("--wps_connect", "Start a connect section for WPS from within the GUI")}
        builder.add_choice(:ssid_broadcast, :type=>:boolean) { |command_line| command_line.uses_switch("--ssid_broadcast", "Enable or disable SSID broadcast for specific SSID")}
        builder.add_choice(:wireless_mac_authentication, :type=>[:string]) { |command_line| command_line.uses_option("--wireless_mac_authentication STATE,TYPE", "Sets wireless MAC authentication to 'enable' or 'disable' state, and optionally set to 'allow' or 'deny' list type") }
        builder.add_choice(:wireless_mac_authentication_add) { |command_line| command_line.uses_option("--wireless_mac_authentication_add ID", "Add given ID to authentication list") }
        builder.add_choice(:wireless_mac_authentication_remove) { |command_line| command_line.uses_option("--wireless_mac_authentication_remove [ID]", "Specify the MAC ID to remove, or leave blank to remove all from the authentication list") }
        builder.add_choice(:wireless_mode_options, :type=>[:string]) { |command_line| command_line.uses_option("--wireless_mode_options OPTIONS", "Comma separated list of all options for 802.11b/g/n mode") }
        builder.add_choice(:wireless_channel_options, :type=>[:string]) { |command_line| command_line.uses_option("--wireless_channel_options OPTIONS", "Comma separated options for CHANNEL,POWER") }

        # Utilities
        builder.add_choice(:reboot) { |command_line| command_line.uses_switch("--reboot", "Reboots the router") }
        builder.add_choice(:restore_defaults) { |command_line| command_line.uses_option("--restore_defaults EVENT", "Restores one of the following options: username, wireless, firewall, factory") }
        builder.add_choice(:upgrade_firmware) { |command_line| command_line.uses_option("--upgrade_firmware FILE", "Upgrade firmware using the file specified") }
        builder.add_choice(:ping_test, :type=>[:string]) { |command_line| command_line.uses_option("--ping ADDRESS,SIZE", "Run a ping test to the address specified. Specify the packet size if wanted") }
        builder.add_choice(:traceroute) { |command_line| command_line.uses_option("--traceroute ADDRESS", "Run a trace route to the address specified") }
        builder.add_choice(:web_activity_log, :type=>:string) { |command_line| command_line.uses_option("--web_activity_log [OPTION]", "Returns the current log") }
        builder.add_choice(:time_zone) { |command_line| command_line.uses_option("--time_zone ZONE", "Set time zone to specified zone: hawaii, alaska, pacific, mountain, central, or eastern. Add a '+' to turn on Day Light Savings, or a '-' to turn off") }

        # Advanced Setup
        builder.add_choice(:services_blocking_add, :type=>[:string]) { |command_line| command_line.uses_option("--services_blocking_add IP,FLAGS", "Blocks given IP address from services marked by FLAGS. FLAGS are: w=web, f=ftp, n=newsgroups, e=email, i=im... i.e., 'wne' blocks web, news, email")}
        builder.add_choice(:services_blocking_remove, :type=>[:string]) { |command_line| command_line.uses_option("--services_blocking_remove IP,FLAGS", "Remove blocks for given IP address with services marked by FLAGS or set to 'all' to remove every block from list. FLAGS are: w=web, f=ftp, n=newsgroups, e=email, i=im... i.e., 'wne' blocks web, news, email. Leave blank to remove all services for IP")}
        # builder.add_choice(:website_blocking_ip) { |command_line| command_line.uses_option("--website_blocking_ip IP", "Set IP/Device to use for blocking websites")}
        builder.add_choice(:website_blocking_add, :type=>[:string]) { |command_line| command_line.uses_option("--website_blocking_add SITE,SITE,SITE", "List of comma separated sites to block") }
        builder.add_choice(:website_blocking_remove, :type=>[:string]) { |command_line| command_line.uses_option("--website_blocking_remove SITE,SITE,SITE", "List of comma separated sites to remove from block list. Use 'all' to remove all") }
        builder.add_choice(:scheduling_access_add, :type=>[:string]) { |command_line| command_line.uses_option("--scheduling_access_add MAC,DAYS,TIME", "Adds a scheduling access rule with MAC address or device name, days specified like so: 'sunmontuewedthufrisat' and time frame in military format: '14:00-19:00'") }
        builder.add_choice(:scheduling_access_remove) { |command_line| command_line.uses_option("--scheduling_access_remove MAC", "Removes scheduling rules associated with the MAC ID specified. Use 'all' to remove every rule") }
        builder.add_choice(:broadband_settings, :type=>[:string]) { |command_line| command_line.uses_option("--broadband_settings DEVICE,OPTIONS", "Configures broadband settings for DEVICE with OPTIONS. DEVICE can be [ethernet], [hpna], [ptm], or [atm]. Options vary per device. For ETH: [enable] or [disable] to enable/disable VLAN. For HPNA: no options available. For PTM: [vlan:[enable|disable]], [mode:mode_type]. For ATM: [mode:mode_type], [vpi:value], [vci:value], [qos:qos_type], [pcr:value], [scr:value], [mbs:value], [cdvt:value], [encaps:[llc|vcmux]]") }
        # builder.add_choice(:wan_ethernet_settings, :type=>[:string]) { |command_line| command_line.uses_option("--wan_ethernet_settings VLANID,PRIORITY", "Set VLAN ID and PRIORITY for R1000H, or set to 'disable' to disable VLAN") }
        builder.add_choice(:dhcp_settings, :type=>[:string]) { |command_line| command_line.uses_option("--dhcp_settings STARTIP,ENDIP,SUBNETMASK", "Sets DHCP server to use the specified starting IP address, end IP address, and subnet mask. Use 'disable' to turn DHCP off") }
        builder.add_choice(:dhcp_lease_time) { |command_line| command_line.uses_option("--dhcp_lease_time DD:HH:MM", "Set lease time to specified days, hours, minutes") }
        builder.add_choice(:dhcp_dns, :type=>[:string]) { |command_line| command_line.uses_option("--dhcp_dns SERVER1,SERVER2", "Set DNS servers to static and use the specified server addresses. Use 'dynamic' to turn DNS to dynamic (default)") }
        # builder.add_choice(:dhcp_reservation, :type=>[:string]) { |command_line| command_line.uses_option("--dhcp_reservation MAC,IP", "Set DHCP reservation for MAC ID to specified IP. Set IP to 'remove' to remove associated existing rule to the MAC ID. Set MAC ID to 'all' to remove all") }
        # builder.add_choice(:dns_host_mapping, :type=>[:string]) { |command_line| command_line.uses_option("--dns_host_mapping HOSTNAME,IP", "Set DNS host mapping for HOSTNAME to specified IP. Set IP to 'remove' to remove associated existing rule to the HOSTNAME. Set HOSTNAME to 'all' to remove all") }
        builder.add_choice(:lan_ip_address, :type=>[:string]) { |command_line| command_line.uses_option("--lan_ip_address IP,SUBNET", "Set DUT to specified IP address and subnet mask") }
        builder.add_choice(:wan_ip_address, :type=>[:string]) { |command_line| command_line.uses_option("--wan_ip_address PROTOCOL,IP/MASK,ENCAPSULATION", "Sets the WAN IP to the specified protocol: pppoe, pppoa, transparent, dhcp, or static. Add a '+' to the protocol for PPP auto connect when available, or for VIP mode when available. IP/MASK can be 'dynamic', an ip address for single static, or ip/mask format for static ip block. In addition, use IP/MASK for HOST:DOMAIN for DHCP settings, and IP/MASK:GATEWAY for static IP. Encapsulation type can be 'llc' or 'vcmux'") }
        builder.add_choice(:wan_ip_address_dns, :type=>[:string]) { |command_line| command_line.uses_option("--wan_ip_address_dns SERVER1,SERVER2", "Set DNS servers to static and use the specified server addresses. Use 'dynamic' to turn DNS to dynamic (default)") }
        builder.add_choice(:wan_interface) { |command_line| command_line.uses_option("--wan_interface INTERFACE", "Specify the WAN interface. Use '_' instead of spaces as necessary") }
        builder.add_choice(:hpna_lan, :type=>:boolean) { |command_line| command_line.uses_option("--hpna_lan", "Enable or disable HPNA LAN state") }
        builder.add_choice(:qos_upstream, :type=>[:string]) { |command_line| command_line.uses_option("--qos_upstream OPTIONS", "List of comma separated options: [name:string], [priority:high|med|low], [reserve:bandwidth], [protocol:protocol], [tos:bit], [source:ip/netmask:port-range], [destination:ip/netmask:port-range]. Use 'disable' to disable upstream, or 'default' to enable and set to Default QoS") }
        builder.add_choice(:qos_downstream, :type=>[:string]) { |command_line| command_line.uses_option("--qos_downstream OPTIONS", "List of comma separated options: [name:string], [priority:high|med|low], [reserve:bandwidth], [protocol:protocol], [tos:bit], [source:ip/netmask:port-range], [destination:ip/netmask:port-range]. Use 'disable' to disable downstream, or 'default' to enable and set to Default QoS") }
        builder.add_choice(:remote_gui) { |command_line| command_line.uses_option("--remote_gui PORT", "Turns on remote GUI to specified port, or set to 'disable' to turn off. Set to 'enable' just to use the default port (443)") }
        builder.add_choice(:remote_gui_timeout) { |command_line| command_line.uses_option("--remote_gui_timeout TIME", "Sets idle disconnect time for remote management")}
        builder.add_choice(:gui_info, :type=>[:string]) { |command_line| command_line.uses_option("--gui_info USER,PASS", "Set GUI username and password") }
        builder.add_choice(:remote_telnet, :type=>:boolean) { |command_line| command_line.uses_switch("--remote_telnet", "Turns telnet on or off") }
        builder.add_choice(:remote_telnet_timeout) { |command_line| command_line.uses_option("--remote_telnet_timeout TIME", "Sets idle disconnect time for telnet")}
        builder.add_choice(:telnet_info, :type=>[:string]) { |command_line| command_line.uses_option("--telnet_info USER,PASS", "Set telnet username and password") }
        builder.add_choice(:dynamic_routing) { |command_line| command_line.uses_option("--dynamic_routing VERSION", "Set RIP to version 1 or 2, or 'off'") }
        builder.add_choice(:static_routing, :type=>[:string]) { |command_line| command_line.uses_option("--static_routing DESTINATION,SUBNET,GATEWAY,NAME", "Specify a static route with the address information provided. Use 'remove' to remove all routes") }
        builder.add_choice(:admin_password, :type=>[:string]) { |command_line| command_line.uses_option("--admin_password USER,PASS", "Set username and password under advanced->admin password") }
        builder.add_choice(:port_forwarding, :type=>[:string]) { |command_line| command_line.uses_option("--port_forwarding PROTOCOL:START-END,IP", "Forward specified protocol and port range") }
        builder.add_choice(:port_forwarding_remote, :type=>[:string]) { |command_line| command_line.uses_option("--port_forwarding_remote START-END,IP", "Specify remote port range and address to listen from") }
        builder.add_choice(:port_forwarding_remove, :type=>:boolean) { |command_line| command_line.uses_switch("--port_forwarding_remove", "Use to remove all port forwarding rules") }
        builder.add_choice(:applications, :type=>[:string]) { |command_line| command_line.uses_option("--applications IP,CATEGORY:APPLICATION", "Forward specified application rule to the IP address. Note that the CATEGORY is optional") }
        builder.add_choice(:applications_remove, :type=>:boolean) { |command_line| command_line.uses_switch("--applications_remove", "Use to remove all application rules") }
        builder.add_choice(:dmz_hosting) { |command_line| command_line.uses_option("--dmz_hosting IP", "Enable DMZ hosting to the specified IP. Set IP to 'disable' to turn off DMZ hosting") }
        builder.add_choice(:firewall) { |command_line| command_line.uses_option("--firewall LEVEL", "Set firewall to: off, low, med, or high. Use 'disable' to turn stealth mode off") }
        builder.add_choice(:firewall_services, :type=>[:string]) { |command_line| command_line.uses_option("--firewall_services SERVICE,SERVICE,SERVICE", "(Only used when firewall not set to 'NAT only') Format follows: SERVICE_NAME:TRAFFIC_IN:TRAFFIC_OUT. Example: DirectX:on:off, turns DirectX traffic IN on, and traffic out OFF. For services with a space in them, replace spaces with '_' - ICMP_Echo_Request")}
        builder.add_choice(:nat, :type=>:boolean) { |command_line| command_line.uses_switch("--nat", "Turn nat on or off") }
        builder.add_choice(:upnp, :type=>:boolean) { |command_line| command_line.uses_switch("--upnp", "Turn UPnP on or off") }
    end

    # Begin parsing here
    def config
        pp @user_choices
        if @user_choices[:rawhtml][0].match(/list/i)
            @menu_links.each_key { |section| puts "Section name: #{section}"; @menu_links[section].each_key { |sub| puts "\tsubsection: #{sub}" } }
            exit
        end if @user_choices[:rawhtml]
        # Get firefox up
        self.start_firefox
        begin
            # misc
            self.menu(@user_choices[:rawhtml][0], @user_choices[:rawhtml][1] || false) if @user_choices[:rawhtml]

            # quick setup
            self.quick_setup if @user_choices[:ppp_username] || @user_choices[:ppp_password] unless @user_choices[:wan_ip_address]

            # wireless
            self.basic_settings if @user_choices.member?(:wireless)
            self.multiple_ssid if @user_choices[:mssid_name] || @user_choices[:mssid_settings]
            self.wep if @user_choices[:wep_authentication_type] || @user_choices[:wep_key]
            self.wep_8021x if @user_choices[:wep_8021x]
            self.wpa if @user_choices[:wpa_key] || @user_choices[:wpa_type] || @user_choices[:wpa_cipher] || @user_choices[:wpa_enterprise]
            self.wmm if !@user_choices[:wmm].nil? || !@user_choices[:wmm_powersave].nil?
            self.wps if @user_choices[:wps] || !@user_choices[:wps_pbc].nil? || !@user_choices[:wps_generate_pin].nil? || !@user_choices[:wps_restore_pin].nil? || !@user_choices[:wps_connect].nil?
            self.ssid_broadcast if @user_choices[:ssid_broadcast]
            self.mac_authentication if @user_choices[:wireless_mac_authentication] || @user_choices[:wireless_mac_authentication_add] || @user_choices[:wireless_mac_authentication_remove]
            self.wireless_mode if @user_choices[:wireless_mode_options]
            self.channel if @user_choices[:wireless_channel_options]

            # utilities
            self.reboot if @user_choices[:reboot]
            self.restore_defaults if @user_choices[:restore_defaults]
            self.upgrade_firmware if @user_choices[:upgrade_firmware]
            self.ping_test if @user_choices[:ping_test]
            self.traceroute if @user_choices[:traceroute]
            self.web_activity_log if @user_choices.member?(:web_activity_log)
            self.time_zone if @user_choices[:time_zone]

            # advanced
            self.services_blocking if @user_choices[:services_blocking_add] || @user_choices[:services_blocking_remove]
            self.website_blocking if @user_choices[:website_blocking_add] || @user_choices[:website_blocking_remove]
            self.scheduling_access if @user_choices[:scheduling_access_add] || @user_choices[:scheduling_access_remove]
            self.broadband_settings if @user_choices[:broadband_settings]
            self.dhcp_settings if @user_choices[:dhcp_settings] || @user_choices[:dhcp_lease_time] || @user_choices[:dhcp_dns]
            self.lan_ip_address if @user_choices[:lan_ip_address]
            # self.dhcp_reservation if @user_choices[:dhcp_reservation]
            # self.dns_host_mapping if @user_choices[:dns_host_mapping]
            self.wan_ip_address if @user_choices[:wan_ip_address] || @user_choices[:wan_ip_address_dns]
            self.remote_gui if @user_choices[:remote_gui] || @user_choices[:gui_info] || @user_choices[:remote_gui_timeout]
            self.remote_telnet if @user_choices.member?(:remote_telnet) || @user_choices[:telnet_info] || @user_choices[:remote_telnet_timeout]
            self.dynamic_routing if @user_choices[:dynamic_routing]
            self.static_routing if @user_choices[:static_routing]
            self.admin_password if @user_choices[:admin_password]
            self.port_forwarding if @user_choices[:port_forwarding] || !@user_choices[:port_forwarding_remove].nil?
            self.applications if @user_choices[:applications] || !@user_choices[:applications_remove].nil?
            self.dmz_hosting if @user_choices[:dmz_hosting]
            self.firewall if @user_choices[:firewall] || @user_choices[:firewall_services]
            self.nat unless @user_choices[:nat].nil?
            self.upnp unless @user_choices[:upnp].nil?
            self.hpna_lan if @user_choices.member?(:hpna_lan)
            self.wan_ethernet_settings if @user_choices.member?(:wan_ethernet_settings)
            # TR-69
            self.acs_url if @user_choices[:acs_url]

        ensure
            @ff.close if defined?(@ff)
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
Configure.new(config_file).config