#This is basic_security script for mixed mode STC022_2.TCL . This is Dhcp Enable

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification SecurityDHCP STC024_1]

keylset wireless_group_g Dhcp Enable
keylset wireless_group_b Dhcp Enable

# Set wireless_group_g to be Wep-40
keylset wireless_group_g Method { WEP-Open-40 }

keylset wireless_group_g NumClients $NumClients
keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe $AssocProbe

# Setup wireless_group_b as WEP-Open-40
keylset wireless_group_b Method { WEP-Open-40 }
keylset wireless_group_b BonlyMode True

keylset wireless_group_b NumClients $NumClients
keylset wireless_group_b Channel $Channel
keylset wireless_group_b AssocProbe $AssocProbe


keylset wireless_group_3 Dhcp Enable
keylset wireless_group_4 Dhcp Enable

# Set wireless_group_3 to be WPA2-EAP-TLS
keylset wireless_group_3 Method { WPA2-EAP-TLS }
keylset wireless_group_3 Ssid testwpa2-tls

keylset wireless_group_3 NumClients $NumClients
keylset wireless_group_3 Channel $Channel
keylset wireless_group_3 AssocProbe $AssocProbe

# Setup wireless_group_4 as WPA2-EAP-TLS
keylset wireless_group_4 Method { WPA2-EAP-TLS }
keylset wireless_group_4 Ssid testwpa2-tls
keylset wireless_group_4 BonlyMode True

keylset wireless_group_4 NumClients $NumClients
keylset wireless_group_4 Channel $Channel
keylset wireless_group_4 AssocProbe $AssocProbe




keylset global_config Direction { Unidirectional }
keylset global_config Destination { ether_group_1 ether_group_2 ether_group_3 ether_group_4    }
keylset global_config Source      { wireless_group_g wireless_group_b wireless_group_3 wireless_group_4 }

