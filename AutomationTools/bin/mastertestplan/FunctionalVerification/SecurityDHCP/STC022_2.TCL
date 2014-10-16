#This is basic_security script for mixed mode STC022_2.TCL . This is Dhcp Enabled

if { ![info exists env(VW_MTP_HOME)] } {
    puts "Error: Environment variable VW_MTP_HOME not set.\n"
    exit -1
}
set src_path [file join $env(VW_MTP_HOME) global_configs.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}
set src_path [file join $env(VW_MTP_HOME) client_setup.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

set src_path [file join $env(VW_MTP_HOME) FunctionalVerification SecurityDHCP Security.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification SecurityDHCP STC022_1]

keylset wireless_group_g Dhcp Enable
keylset wireless_group_b Dhcp Enable

keylset wireless_group_g Method { WPA-PSK }
keylset wireless_group_g PskAscii whatever

keylset wireless_group_g NumClients $NumClients
keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe $AssocProbe

# Setup wireless_group_b as WPA2-PSK
keylset wireless_group_b Method { WPA2-PSK }
keylset wireless_group_b PskAscii notwhatever
keylset wireless_group_b BonlyMode False
keylset wireless_group_b Ssid testwpa2-psk

keylset wireless_group_b NumClients $NumClients
keylset wireless_group_b Channel $Channel
keylset wireless_group_b AssocProbe $AssocProbe



keylset global_config Direction { Unidirectional }
keylset global_config Destination { ether_group_1 ether_group_2    }
keylset global_config Source      { wireless_group_g wireless_group_b }
