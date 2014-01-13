#!/usr/bin/env ruby
# Configures a Q1000

$: << File.dirname(__FILE__)

require 'rubygems'
require 'firewatir'

@dut_address = "http://192.168.0.1"

@menu_links = {
    :status => {
        :top => "modemstatus_home",
#        :connection_status => "modemstatus_home",
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
        :wep => "wirelesssetup_security",
        :wep_8021x => "wirelesssetup_wep8021x",
        :wmm => "wirelesssetup_wmm",
        :wps => "wirelesssetup_wps",
        :mac_authentication => "wirelesssetup_wirelessmacauthentication",
        :wireless_mode => "wirelesssetup_radiosetup"
    },
    :utilities => {
        :top => "utilities_reboot",
        :reboot => "utilities_reboot",
        :restore_defaults => "utilities_restoredefaultsettings",
        :upgrade_firmware => "utilities_upgradefirmware",
        :ping_test => "utilities_ipping",
        :traceroute => "utilities_traceroute",
        :speed_test => "advancedutilities_speedtest",
        :diagnostic => "advancedutilities_diagnostictest",
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

def list_select(tag_id, item, tag=:id)
    selection = false
    (@ff.select_list(tag, tag_id).getAllContents).each { |validate| selection = validate if validate.match(/#{item}/i) != nil }
    if selection.length == 0
        return false
    else
        @ff.select_list(tag, tag_id).select(selection)
        return true
    end
end

# New code for new authentication method on Qwest Q1000
def logon(access_url)
    retries = 0
    raise "No username and/or password provided, but a login page is requiring them before continuing configuration. Exiting." unless @dut_user && @dut_pass
    while @ff.text.match(/Enter an admin username and password/i)
        raise "Tried logging in 3 times unsuccessfully. Giving up and exiting." if retries > 3
        @ff.text_field(:id, "admin_user_name").set(@dut_user)
        @ff.text_field(:id, "admin_password").set(@dut_pass)
        @ff.link(:id, "apply_btn").click
        @ff.link(:href, /#{access_url}/).click
    end
end

def start_firefox
    rt_count = 1
    waittime = 10
    begin
        @ff = FireWatir::Firefox.new(:waitTime => waittime)
        @ff.wait
        @ff.goto(@dut_address)
        return true
    rescue => ex
        puts ex.message
        if rt_count < 4

            waittime += 5
            rt_count += 1
            retry
        else
            return false
        end
    end
end

# Please wait loop
def please_wait
    frames = TRUE
    if @ff.frame("realpage").contains_text(/please wait/i)
        sleep 20
        @ff.refresh
    end rescue frames = FALSE
    while @ff.contains_text(/please wait/i)
        sleep 5
        @ff.refresh
    end unless frames
    while @ff.contains_text(/another management entity is currently configuring this unit/i)

        sleep 10
        @ff.refresh
    end if @ff.contains_text(/another management entity is currently configuring this unit/i)
    @log.debug("Wait Loop::Done waiting")
end

def menu(section, sub_section = false)
    stat = true
    if @menu_links[section.to_sym].nil?
        return false
    end
    if @menu_links[section.to_sym][sub_section.to_sym].nil?
        return false
    end if sub_section
    if section.to_sym == :tr69
        @ff.goto("#{@dut_address}/#{@menu_links[section.to_sym][:top]}")
    else
        if @ff.frame("realpage").exists?
            @ff.frame("realpage").link(:href, /#{@menu_links[section.to_sym][:top]}/).click
        else
            @ff.link(:href, /#{@menu_links[section.to_sym][:top]}/).click
            self.logon("#{@menu_links[section.to_sym][:top]}") if @ff.text.match(/Enter an admin username and password/i)
        end
    end
    stat = false unless @ff.url.include?(@menu_links[section.to_sym][:top])
    if sub_section
        @ff.link(:href, /#{@menu_links[section.to_sym][sub_section.to_sym]}/).click
        stat = @ff.url.include?(@menu_links[section.to_sym][sub_section.to_sym]) ? true : false
    end
    return stat
end

def get_data
    data_contents = {}
    @ff.div(:id, "content_right").tables.each do |data_table|
        data_table.rows.each do |row|
            unless row.text.empty?
                puts "Checking #{row.text}"
                data_string = ""
                case row.cells[1].html
                when /type="text"/i
                    data_string = row.cells[1].text_fields[0].value
                when /type="radio"/i
                    data_string = row.cells[1].radios[0].value
                when /<select/i
                    data_string = row.cells[1].select_lists[0].value
                else
                    data_string = row.cells[1].text
                end
                data_contents[row.cells[0].text.delete('^[0-9a-zA-Z]')] = data_string
            end if row.cells.length == 2
        end
    end
    return data_contents
end

begin
    start_firefox
    data = {}
    @menu_links.each_key do |section|
        @menu_links[section].each_key do |sub_section|
            menu(section, sub_section)
            puts "Checking #{section} - #{sub_section}"
            data["#{section}-#{sub_section}"] = get_data
        end
    end
    puts data.inspect
ensure
    @ff.close if defined?(@ff)
end