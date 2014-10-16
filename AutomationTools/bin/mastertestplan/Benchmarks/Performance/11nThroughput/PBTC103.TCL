#PBTC 103 Upstream_HT-AMPDU_20MHz_Throughput 
#Title 
#Measure upstream HT AMPDU Throughput 
#Purpose
#Measure the upstream AMPDU throughput that can be achieved on the SUT supporting HT clients 
#SUT Feature(s)
#Maximum reliable data forwarding capacity, basic performance
#Requirement(s)
#* WaveApps application running on host PC,WT-90 or WT-20 chassis with 1x 802.11n WiFi Waveblade (WBW2000) and 1xEthernet Waveblade,SUT set up to operate in the 2.4GHz or 5GHz band,SUT set up to support AMPDU aggregation w/ BlockAck operation,SUT set up to support UDP traffic,DHCP enabled
#Test Setup
#* Connect antenna ports on the 802.11n Wi-Fi WaveBlade to SUT via RF cables. This will vary depending on the SUT,Use 2 Ports A and B on WiFi WaveBlade if SUT supports just 2 antenna ports,Use 3 Ports A, B and C on WiFi WaveBlade if SUT supports 3 antenna ports,Configure the SUT to open authentication mode,Set Basic Rate Set on SUT to 1Mbps, 2Mbps, 5.5Mbps, 6Mbps, 11Mbps, 12Mbps, 24Mbps,Set client PHY rate to MCS = 15,Set client Guard Interval to LGI,Set client Channel bandwidth to 20MHz,Set client HT mode to "HT mixed",Set client Channel Model to "Bypass",Run test with no encryption and WPA2-AES,Run test with UDP frame sizes: 88, 128, 256, 512, 1024,and 1518 bytes,Run test with 1, 10, 20 and 50 clients
#Procedure
#1. Launch the WaveApps application,Select the Throughput Test under the IEEE 802.11.2 Benchmark Test Suite,Select the test port(s) (i.e., APs) to use for the test,Select SSID and configure the clients to open authentication with no encryption and obtain IP addresses via DHCP,Create an Ethernet client group on the correct port(s) with the initial number of Ethernet clients set to 1,Set the initial number of Wi-Fi clients to 1,Select frame sizes of 88, 128, 256, 512, 1024 and 1518 bytes and UDP traffic type,Select Wireless to Ethernet (one-to-one, upstream) mapping,Run the test,Wait until test completes,Collect report and results data,Repeat steps 5 to 11 with 10, 20 and 30 clients configured on both Ethernet and Wi-Fi sides (one-to-one),Repeat steps 5 to 12 with WPA2-AES encryption mode,Repeat steps 5 to 13 with Channel Models A and C
#Test Priority
#Mandatory
#Test Type
#Performance
#Pass/Fail Criteria
#An Enterprise Class/Carrier Grade SUT should achieve the following minimum upstream throughput:
#
#
#1518 bytes
#1024 bytes
#512 bytes
#256 bytes
#128 bytes
#88 bytes
#
#20MHz
#118 Mbps
#116 Mbps
#112 Mbps
#103 Mbps
#90 Mbps
#130 Mbps


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

set src_path [file join $env(VW_MTP_HOME) Benchmarks Performance 11nThroughput 11nThroughput.tcl]

if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot Benchmarks Performance Throughput11n PBTC103]

keylset global_config Direction { Unidirectional }
keylset global_config Source {wireless_group_n }
keylset global_config Destination { ether_group_1 }

keylset wireless_group_n Dhcp Enable
keylset ether_group_1 Dhcp Enable

keylset wireless_group_n EnableAMPDUaggregation True

keylset wireless_group_n DataMcsIndex  { 15 }
keylset wireless_group_n GuardInterval  { standard }
keylset wireless_group_n ChannelBandwidth  {20 }

keylset ether_group_2 NumClients { 1 10 20 30}
keylset wireless_group_n ChannelModel {Bypass A C}
keylset wireless_group_n Method { None WPA2-PSK }


