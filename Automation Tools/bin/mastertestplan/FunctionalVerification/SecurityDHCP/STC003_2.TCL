#This is basic_security script for STC003_2.TCL . This is Dhcp enabled

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification SecurityDHCP STC003_1]

keylset wireless_group_g Dhcp Enable

keylset wireless_group_g Method { WEP-Open-128 }
# The wepkey should be set from the client setup. 
#keylset wireless_group_g WepKey128Hex 30313233343536373839303132
keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe $AssocProbe
keylset wireless_group_g NumClients $NumClients

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g }
keylset global_config Destination { ether_group_1 }

