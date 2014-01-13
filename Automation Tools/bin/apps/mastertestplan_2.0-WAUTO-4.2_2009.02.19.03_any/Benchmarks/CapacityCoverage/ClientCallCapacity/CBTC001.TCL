# CBTC 001 8021g_Maximum_Client_Capacity with Static IP  
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

set src_path [file join $env(VW_MTP_HOME) Benchmarks CapacityCoverage ClientCallCapacity max_client_capacity.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}


keylset global_config LogsDir [file join $LogsDirRoot Benchmarks CapacityCoverage ClientCallCapacity CBTC001]
# NOTE: IF using an external DUT configurator, you will need to divide this test up into
# separate tests per security types.
# Configure the below parameter to support the security methods you want to check 
# Below are the default security methods that are common to must DUTs 
#As per Test Procedure
keylset wireless_group_g Method { WEP-Open-128 WPA-PSK WPA2-PSK WPA-EAP-TLS WPA-PEAP-MSCHAPV2 WPA2-EAP-TLS WPA2-EAP-TTLS-GTC WPA2-PEAP-MSCHAPV2 LEAP WPA2-EAP-FAST }

#As per Test Setup(generic)
keylset wireless_group_g Method {None WEP-Open-40  WPA-PSK WPA2-PSK }


