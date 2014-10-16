#This is basic_security script for STC001_1.TCL . This is Dhcp dis-abled

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification SecurityDHCP STC001_2]


keylset wireless_group_g Dhcp Disabled

keylset wireless_group_g Method { None }
keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe $AssocProbe
keylset wireless_group_g NumClients $NumClients


keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g }
keylset global_config Destination { ether_group_1 }

