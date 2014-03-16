#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
prefix = ARGV[0] || "192.168.1."
url = "http://#{prefix}1"
header = "keylset global_config TrialDuration 5\nkeylset global_config AgingTime 1\nkeylset global_config ChassisName 192.168.11.99\nkeylset global_config LogsDir \"/root/veriwave_cross_logs\"\n# catch {source [file join $env(HOME) \"vw_licenses.tcl\"]}\nkeylset global_config LicenseKey {mcdas-us41j-fqasd hcdaw-x611r-z960d hcdaw-nuj15-btuqx smda4-sg416-pqas6 smda4-pg419-qqas5 ncdar-ts41k-fqasd scdam-ys41f-fqasd}\nkeylset global_config NumTrials     1\nkeylset global_config TestList { unicast_throughput }\nset wireless_group_g {\n    { GroupType         802.11abg                       }\n    { BssidIndex        2                               }\n    "
mid = "{ Dut               dut1                            }\n    { Method            { None }                        }\n    { NumClients        { 1 }                          }\n    { Password\t\t    whatever\t\t\t}\n    { Identity          anonymous                       }\n    { AnonymousIdentity anonymous                       }\n    { PskAscii          1234567890                      }\n    { ClientCertificate\t$VW_TEST_ROOT/etc/cert-clt.pem  }\n    { RootCertificate   $VW_TEST_ROOT/etc/root.pem      }\n    { PrivateKeyFile    $VW_TEST_ROOT/etc/cert-clt.pem  }\n    { EnableValidateCertificate     off                 }\n    { Dhcp              Disable                         }\n    { BaseIp            #{prefix}105  }\n    { IncrIp            0.0.0.1         }\n    { SubnetMask        255.255.255.0   }\n    { Gateway           #{prefix}1    }\n    { AssocProbe    { unicast }         }\n    { AssocRate         2               }\n    { AssocTimeout      20              }\n    { MacAddressMode    Auto            }\n    { KeepAlive\t\t    True\t        }\n    { KeepAliveRate\t20                  }\n    { GratuituousArp\tTrue            }\n}\nset ether_group_1 {\n    { GroupType         802.3               }\n    { NumClients        { 1 }               }\n    { Dut               dut11               }\n    { Dhcp              Disable             }\n    { Gateway           #{prefix}1\t    }\n    { BaseIp            #{prefix}151\t    }\n    { SubnetMask        255.255.255.0       }\n{ IncrIp            0.0.0.1             }\n}\nset chassis_addr [vw_keylget ::global_config ChassisName]\nkeylset dut1 HardwareType                         generic\nkeylset dut1 Vendor                               generic\nkeylset dut1 APModel                              MI424e_208\nkeylset dut1 Interface.bg_radio.InterfaceType     802.11bg \nkeylset dut1 Interface.bg_radio.WavetestPort      $chassis_addr:2:1\nkeylset dut11 HardwareType                         generic\nkeylset dut11 Vendor                               generic\nkeylset dut11 APModel                              MI424e_208\nkeylset dut11 Interface.ethernet.InterfaceType     802.3 \nkeylset dut11 Interface.ethernet.WavetestPort      $chassis_addr:1:1\nkeylset unicast_throughput Benchmark unicast_unidirectional_throughput\nkeylset unicast_throughput Frame Standard\nkeylset unicast_throughput FrameSizeList { 1518 }\nkeylset unicast_throughput SearchResolution 10\nkeylset unicast_throughput Mode Fps\nkeylset unicast_throughput MinSearchValue Default\nkeylset unicast_throughput MaxSearchValue Default\nkeylset unicast_throughput StartValue Default\n"
group_method = "keylset wireless_group_g Method { WEP-Open-128 }\n"
tail = "keylset dut APSWVersion       \"generic\"\nkeylset global_config Direction { Bidirectional }\nkeylset global_config Source      { wireless_group_g }\nkeylset global_config Destination { ether_group_1 }\n"

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

def gen_hex_code(c_length)
    valid_characters = ("A".."F").to_a + ("0".."9").to_a
    length = valid_characters.size

    hex_code = ""
    1.upto(c_length) { |i| hex_code << valid_characters[rand(length-1)] }

    return hex_code
end

def gen_ssid
    valid_characters = ("A".."Z").to_a + ("0".."9").to_a + ("a".."z").to_a
    length = valid_characters.size

    ssid = ""
    1.upto(rand(12)+8) { |i| ssid << valid_characters[rand(length-1)] }

    return ssid
end

def wep_128(agent)
    agent.current_page.forms[0].radiobuttons[2].check
    agent.current_page.forms[0]["pref_conn_set_8021x_key_len"] = "104"
    agent.current_page.forms[0]["pref_conn_set_8021x_key_mode"] = "0"
    wkey = gen_hex_code(26)
    agent.current_page.forms[0]["actiontec_default_wep_key_128"] = wkey
    agent.current_page.forms[0]["actiontec_default_wep_key"] = ""
    agent.current_page.forms[0]["actiontec_default_wep_key_ascii"] = ""
    agent.current_page.forms[0]["actiontec_default_wep_key_ascii_128"] = ""
    return "{ WepKey128Hex\t#{wkey}\t}\n\t"
end

def wep_64(agent)
    agent.current_page.forms[0].radiobuttons[2].check
    agent.current_page.forms[0]["pref_conn_set_8021x_key_len"] = "40"
    agent.current_page.forms[0]["pref_conn_set_8021x_key_mode"] = "0"
    wkey = gen_hex_code(10)
    agent.current_page.forms[0]["actiontec_default_wep_key_128"] = ""
    agent.current_page.forms[0]["actiontec_default_wep_key_ascii"] = ""
    agent.current_page.forms[0]["actiontec_default_wep_key_ascii_128"] = ""
    agent.current_page.forms[0]["actiontec_default_wep_key"] = wkey
    return "{ WepKey40Hex\t#{wkey}\t}\n\t"
end

def ssid(agent)
    generated_ssid = gen_ssid
    agent.current_page.forms[0].ssid = generated_ssid
    return "{ Ssid              \"#{generated_ssid}\"                   }\n    "
end

def channel(agent)
    wireless_channel = rand(11)+1
    agent.current_page.forms[0]["channel"] = wireless_channel.to_s
    return "keylset wireless_group_g Channel { #{wireless_channel} }\n"
end

agent = WWW::Mechanize.new
agent.get(url)

if agent.current_page.parser.text.match(/login setup/im)
    login_setup(agent, "admin", "admin1")
else
    login(agent, "admin", "admin1")
end

agent.current_page.forms[0].mimic_button_field = "goto: 9120.."
agent.submit(agent.current_page.forms[0])

srand
rand(10) > 5 ? group_method = "keylset wireless_group_g Method { WEP-Open-128 }\n" : group_method = "keylset wireless_group_g Method { WEP-Open-40 }\n"
group_method.match(/40/) ? wep_key = wep_64(agent) : wep_key = wep_128(agent)
c_ssid = ssid(agent)
chan = channel(agent)

agent.current_page.forms[0].mimic_button_field = "submit_button_submit: .."
agent.submit(agent.current_page.forms[0])
agent.current_page.forms[0].mimic_button_field = "submit_button_confirm_submit: .."
agent.submit(agent.current_page.forms[0])
sleep 15
agent.current_page.forms[0].mimic_button_field = "logout: ..."
agent.submit(agent.current_page.forms[0])

File.new("veriwave_random_wifi_lan_eth.tcl", File::CREAT|File::TRUNC)
veriwave_file = open("veriwave_random_wifi_lan_eth.tcl", "w+")
veriwave_file.write(header)
veriwave_file.write(c_ssid)
veriwave_file.write(wep_key)
veriwave_file.write(mid)
veriwave_file.write(group_method)
veriwave_file.write(chan)
veriwave_file.write(tail)
veriwave_file.close