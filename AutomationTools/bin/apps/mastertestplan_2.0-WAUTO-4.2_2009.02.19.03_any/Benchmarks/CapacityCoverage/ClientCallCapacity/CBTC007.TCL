# CBTC 003 8021a_Maximum_VoIPCall_Capacity with Static IP
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

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks CapacityCoverage ClientCallCapacity CBTC007]

keylset global_config Direction { Unidirectional }
keylset global_config Source { wireless_group_a wireless_backgrnd_a }
keylset global_config Destination { ether_group_1 ether_backgrnd }

keylset wireless_group_a Dhcp     { Disable }
keylset wireless_backgrnd_a Dhcp  { Disable }
keylset ether_group_1 Dhcp        { Disable }
keylset ether_backgrnd Dhcp       { Disable }

#As per Test Procedure
keylset wireless_group_a Method { WEP-Open-128 WPA-PSK WPA2-PSK WPA-EAP-TLS WPA-PEAP-MSCHAPV2 WPA2-EAP-TLS WPA2-EAP-TTLS-GTC WPA2-PEAP-MSCHAPV2 LEAP WPA2-EAP-FAST }

#As per Test Setup(generic)
keylset wireless_group_a Method {None WEP-Open-40  WPA-PSK WPA2-PSK }
keylset wireless_bkgrnd_a Method { None WEP-Open-40 WPA-PSK WPA2-PSK }
#NOTE: Automation attempt to loop on all variations of client group security, so need to Set
# to a single value for both background and voice clients. 
keylset wireless_group_a Method {None }
keylset wireless_backgrnd_a Method { None }

