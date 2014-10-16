# CBTC 004a_Maximum_VoIPCall_Capacity with DHCP IP
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

set src_path [file join $env(VW_MTP_HOME) Benchmarks CapacityCoverage ClientCallCapacity max_VoIPCall_capacity.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks CapacityCoverage ClientCallCapacity CBTC008]

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_a wireless_backgrnd_a}
keylset global_config Destination { ether_group_1 ether_backgrnd}

keylset wireless_group_a Dhcp { Enable }
keylset wireless_backgrnd_a Dhcp  { Enable }
keylset ether_group_1 Dhcp        { Enable }
keylset ether_backgrnd Dhcp       { Enable }

#As per Test Setup(generic)
keylset wireless_group_a Method {None WEP-Open-40  WPA-PSK WPA2-PSK }
keylset wireless_bkgrnd_a Method { None WEP-Open-40 WPA-PSK WPA2-PSK }
#NOTE: Automation attempt to loop on all variations of client group security, so need to Set
# to a single value for both background and voice clients. 
keylset wireless_group_a Method {None }
keylset wireless_backgrnd_a Method { None }



