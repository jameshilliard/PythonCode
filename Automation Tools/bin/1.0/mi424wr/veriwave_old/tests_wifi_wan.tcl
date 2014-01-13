keylset global_config TrialDuration 5
keylset global_config AgingTime 1
#keylset global_config ClientLearningTime 1
#keylset global_config FlowLearningTime 2

keylset global_config ChassisName 192.168.1.99
keylset global_config LogsDir "/home/autolab2/mi424wr/results/"

#catch {source [file join $env(HOME) "vw_licenses.tcl"]}
keylset global_config LicenseKey {mcdas-us41j-fqasd hcdaw-x611r-z960d hcdaw-nuj15-btuqx smda4-sg416-pqas6 smda4-pg419-qqas5 ncdar-ts41k-fqasd scdam-ys41f-fqasd}


keylset global_config Direction { Unidirectional }


# reverse direction
#keylset global_config Source      { wireless_group }
#keylset global_config Destination { ether_group2 }
keylset global_config Source      { ether_group2 }
keylset global_config Destination { wireless_group }

keylset global_config NumTrials     1

#keylset global_config TestList { test_throughput }
keylset global_config TestList { unicast_packet_loss test_throughput unicast_latency }

keylset wireless_group GroupType     802.11abg
keylset wireless_group Ssid          verizontest
keylset wireless_group Dut           dut
keylset wireless_group Channel       { 6 }
keylset wireless_group NumClients    1
keylset wireless_group GratuitousArp True
keylset wireless_group Dhcp          Enable
keylset wireless_group PskAscii      thisisatest
keylset wireless_group PskAscii      8639001415
keylset wireless_group WepKey128Hex  BADC0FFEE123456789CAFEFEED
keylset wireless_group Hops          -1
keylset wireless_group BehindNAT     True
keylset wireless_group Method        { None }

keylset ether_group GroupType     802.3
keylset ether_group NumClients    1
keylset ether_group Dut           dut
keylset ether_group Dhcp          Enable
keylset ether_group GratuitousArp True
keylset ether_group BehindNAT     False
keylset ether_group Hops          0

keylset ether_group2 GroupType     802.3
keylset ether_group2 NumClients    1
keylset ether_group2 Dut           dut2
keylset ether_group2 Dhcp          Enable
keylset ether_group2 GratuitousArp True
keylset ether_group2 BehindNAT     True
keylset ether_group2 Hops          0

keylset test_throughput Test          unicast_unidirectional_throughput
keylset test_throughput Frame Standard
keylset test_throughput FrameSizeList { 64 128 256 512 1024 1400 1518 }
#keylset test_throughput SearchResolution 5
#keylset test_throughput Mode Fps
#keylset test_throughput MinSearchValue Default
#keylset test_throughput MaxSearchValue Default
#keylset test_throughput StartValue Default


#
#  unicast_packet_loss test specific information
#
keylset unicast_packet_loss Test unicast_packet_loss
keylset unicast_packet_loss Frame Standard
keylset unicast_packet_loss FrameSizeList {1023}
keylset unicast_packet_loss ILoadList {128.0}
keylset unicast_packet_loss ILoadMode Custom

#
#  unicast_latency test specific information
#
keylset unicast_latency Test unicast_latency
keylset unicast_latency Frame Custom
keylset unicast_latency FrameSizeList { 88 128 256 512 1024 1280 1518 }
keylset unicast_latency ILoadList { 700.0 600.0 500.0 400.0 300.0 200.0 100.0 }
keylset unicast_latency ILoadMode Custom

# DUT Configuration
keylset dut HardwareType      ap
keylset dut Vendor            generic
keylset dut APModel           generic
keylset dut realAPModel       "Actiontec MI424WR-Gen2 Rev. E"
keylset dut realAPSWVersion   "20.4.1.MoCA-1.56.15.9"

#keylset dut ApSwVersion       "generic"
 
if {[info exists descr]} {
    keylset dut APSWVersion $descr
} else {
   keylset dut APSWVersion       "generic"
}
     
keylset dut Interface.Dot11Radio0.InterfaceType 802.11bg 

# RJS really this has to be slot.port here but that trips a bug
# the slot:port notation works incoreectly but passes traffic
# using that for now until the bug is fixed.
#
keylset dut Interface.Dot11Radio0.WavetestPort  192.168.1.99:2:1
#keylset dut Interface.Dot11Radio0.WavetestPort  192.168.1.99:2.1

keylset dut Interface.BVI1.InterfaceType     802.3 
keylset dut Interface.BVI1.IpAddr            10.10.250.38 
keylset dut Interface.BVI1.IpMask            255.255.0.0 
keylset dut Interface.BVI1.Gateway           10.10.251.1 
# RJS really this has to be slot.port here but that trips a bug
# the slot:port notation works incoreectly but passes traffic
# using that for now until the bug is fixed.
#
#keylset dut Interface.BVI1.WavetestPort      192.168.1.99:1.1
keylset dut Interface.BVI1.WavetestPort      192.168.1.99:1:1

#keylset dut2 HardwareType      ap
#keylset dut2 Vendor            generic
#keylset dut2 APModel           generic
#keylset dut2 realAPModel       "Actiontec MI424WR-Gen2 Rev. E"
#keylset dut2 realAPSWVersion   "20.4.1.MoCA-1.56.15.9"

#keylset dut2 ApSwVersion       "generic"
#keylset dut2 Interface.BVI1.InterfaceType     802.3 
#keylset dut2 Interface.BVI1.IpAddr            10.10.250.38 
#keylset dut2 Interface.BVI1.IpMask            255.255.0.0 
#keylset dut2 Interface.BVI1.Gateway           10.10.251.1 
#keylset dut2 Interface.BVI1.WavetestPort      192.168.1.99:1.2
set dut2 $dut
#keylset dut2 Interface.BVI1.IpAddr            10.10.250.39 
#keylset dut2 Interface.BVI1.WavetestPort      192.168.1.99:1.2
# RJS really this has to be slot.port here but that trips a bug
# the slot:port notation works incoreectly but passes traffic
# using that for now until the bug is fixed.
#
#keylset dut2 Interface.BVI1.WavetestPort      192.168.1.99:1.1
keylset dut2 Interface.BVI1.WavetestPort      192.168.1.99:1:1


