keylset global_config TrialDuration 5
keylset global_config AgingTime 1
#keylset global_config ClientLearningTime 1
#keylset global_config FlowLearningTime 2

keylset global_config ChassisName 192.168.1.99
keylset global_config LogsDir '/home/celab/mi424wr/results/'

#catch {source [file join $env(HOME) "vw_licenses.tcl"]}
keylset global_config LicenseKey {mcdas-us41j-fqasd hcdaw-x611r-z960d hcdaw-nuj15-btuqx smda4-sg416-pqas6 smda4-pg419-qqas5 ncdar-ts41k-fqasd}


keylset global_config Direction { Unidirectional }

keylset global_config Source      { wireless_group }
keylset global_config Destination { ether_group    }

keylset global_config NumTrials     1

keylset global_config TestList { test_throughput }

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

keylset test_throughput Test          unicast_unidirectional_throughput
keylset test_throughput Frame Standard
keylset test_throughput FrameSizeList { 1024 }
#keylset test_throughput SearchResolution 5
#keylset test_throughput Mode Fps
#keylset test_throughput MinSearchValue Default
#keylset test_throughput MaxSearchValue Default
#keylset test_throughput StartValue Default

# DUT Configuration
keylset dut HardwareType      ap
keylset dut Vendor            generic
keylset dut APModel           generic
keylset dut realAPModel       "Actiontec MI424WR-Gen2 Rev. E"
keylset dut realAPSWVersion   "20.4.1.MoCA-1.56.15.9"

keylset dut ApSwVersion       "generic"
      
keylset dut Interface.Dot11Radio0.InterfaceType 802.11bg 
keylset dut Interface.Dot11Radio0.WavetestPort  192.168.1.99:2:1

keylset dut Interface.BVI1.InterfaceType     802.3 
keylset dut Interface.BVI1.IpAddr            10.10.250.38 
keylset dut Interface.BVI1.IpMask            255.255.0.0 
keylset dut Interface.BVI1.Gateway           10.10.251.1 
keylset dut Interface.BVI1.WavetestPort      192.168.1.99:1:1

