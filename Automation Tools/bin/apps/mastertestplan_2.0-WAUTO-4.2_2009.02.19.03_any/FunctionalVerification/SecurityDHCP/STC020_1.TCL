#This is basic_security script for STC020_1.TCL . This is Dhcp Disabled

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

keylset global_config LogsDir [file join $LogsDirRoot FunctionalVerification SecurityDHCP STC020_2]

keylset wireless_group_g Dhcp Disable

keylset wireless_group_g Method { WPA2-EAP-FAST }
# The security settings should be set from the client_setup
#keylset wireless_group_g Identity anonymous 
#keylset wireless_group_g Password whatever  
#keylset wireless_group_g AnonymousIdentity anonymous
#keylset wireless_group_g EnableValidateCertificate on                            

keylset wireless_group_g Channel $Channel
keylset wireless_group_g AssocProbe $AssocProbe
keylset wireless_group_g NumClients $NumClients



keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_g }
keylset global_config Destination { ether_group_1 }
