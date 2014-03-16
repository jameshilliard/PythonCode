keylset global_config ChassisName 192.168.10.246


#License Keys for running tests beyond the basic benchmarking tests

#keylset global_config LicenseKey {#####-#####-##### #####-#####-#####}
keylset global_config Source {WirelessTv}
keylset global_config Destination {HomeLaptop iDevice WorkLaptop VideoCamera}
keylset global_config Channel {6}

#Traffics Global Options

keylset global_config Content None
keylset global_config UserPattern None
keylset global_config PayloadData None
keylset global_config DestinationPort None
keylset global_config SourcePort None

#Learning Global Options

keylset global_config AgingTime 0
keylset global_config ClientLearningTime 2

#Connection Global Options

#TestParameters Global Options

keylset global_config wimixResultSampleVal 10
keylset global_config wimixResultSampleOption 0
keylset global_config SettleTime 1
keylset global_config ReconnectClients 1
keylset global_config LossTolerance 0
keylset global_config RandomSeed 1186422843
keylset global_config overTimeGraphs 0
keylset global_config wimixResultOption 0

#Tests - you may define more than one in a TCL list.
keylset global_config TestList {wimix_script}

#Group HomeLaptop
keylset HomeLaptop GroupType 802.11abg
keylset HomeLaptop Dut generic_dut_0

#Group HomeLaptop - Client Options
keylset HomeLaptop GratuitousArp True
keylset HomeLaptop Dhcp Enable
keylset HomeLaptop Ssid veriwave
keylset HomeLaptop Qos Disable
keylset HomeLaptop Uapsd 0
keylset HomeLaptop ListenInt 1
keylset HomeLaptop phyInterface 802.11ag
keylset HomeLaptop Wlan80211eQoSAC 0
keylset HomeLaptop BaseIp 192.168.1.12
keylset HomeLaptop Gateway 192.168.1.1
keylset HomeLaptop MacAddress None

#Group HomeLaptop - Security Options
keylset HomeLaptop Method {None}

#Group VideoCamera
keylset VideoCamera GroupType 802.11abg
keylset VideoCamera Dut generic_dut_1

#Group VideoCamera - Client Options
keylset VideoCamera GratuitousArp True
keylset VideoCamera Dhcp Enable
keylset VideoCamera Ssid veriwave
keylset VideoCamera Hops 0
keylset VideoCamera Qos Disable
keylset VideoCamera Uapsd 0
keylset VideoCamera ListenInt 1
keylset VideoCamera phyInterface 802.11ag
keylset VideoCamera Wlan80211eQoSAC 0
keylset VideoCamera BaseIp 192.168.1.11
keylset VideoCamera Gateway 192.168.1.1
keylset VideoCamera MacAddress None

#Group VideoCamera - Security Options
keylset VideoCamera Method {None}

#Group WirelessTv
keylset WirelessTv GroupType 802.11abg
keylset WirelessTv Dut generic_dut_0

#Group WirelessTv - Client Options
keylset WirelessTv GratuitousArp True
keylset WirelessTv Dhcp Enable
keylset WirelessTv Ssid veriwave
keylset WirelessTv Hops 2
keylset WirelessTv Qos Disable
keylset WirelessTv Uapsd 0
keylset WirelessTv ListenInt 1
keylset WirelessTv phyInterface 802.11ag
keylset WirelessTv Wlan80211eQoSAC 0
keylset WirelessTv BaseIp 192.168.1.13
keylset WirelessTv Gateway 192.168.1.1
keylset WirelessTv MacAddress None

#Group WirelessTv - Security Options
keylset WirelessTv Method {None}

#Group WorkLaptop
keylset WorkLaptop GroupType 802.11abg
keylset WorkLaptop Dut generic_dut_0

#Group WorkLaptop - Client Options
keylset WorkLaptop GratuitousArp True
keylset WorkLaptop Dhcp Enable
keylset WorkLaptop Ssid veriwave
keylset WorkLaptop Hops -1
keylset WorkLaptop Qos Disable
keylset WorkLaptop Uapsd 0
keylset WorkLaptop ListenInt 1
keylset WorkLaptop phyInterface 802.11ag
keylset WorkLaptop Wlan80211eQoSAC 0
keylset WorkLaptop BaseIp 192.168.1.10
keylset WorkLaptop Gateway 192.168.1.1
keylset WorkLaptop MacAddress None

#Group WorkLaptop - Security Options
keylset WorkLaptop Method {None}

#Group iDevice
keylset iDevice GroupType 802.11abg
keylset iDevice Dut generic_dut_0

#Group iDevice - Client Options
keylset iDevice GratuitousArp True
keylset iDevice Dhcp Enable
keylset iDevice Ssid veriwave
keylset iDevice Hops 3
keylset iDevice Qos Disable
keylset iDevice Uapsd 0
keylset iDevice ListenInt 1
keylset iDevice phyInterface 802.11ag
keylset iDevice Wlan80211eQoSAC 0
keylset iDevice BaseIp 192.168.1.14
keylset iDevice Gateway 192.168.1.1
keylset iDevice MacAddress None

#Group iDevice - Security Options
keylset iDevice Method {None}

#wimix_script Options
keylset wimix_script Test wimix_script

#Wimix Test Settings
keylset wimix_script Test wimix_script
keylset wimix_script wimixMode Client
keylset wimix_script testProfile Residential
keylset wimix_script testProfileImage images/wimix_residential.png
keylset wimix_script staggerStartInt 1
keylset wimix_script staggerStart 0
keylset wimix_script totalClientPer 100
keylset wimix_script loadVal 5
keylset wimix_script totalLoadPer 100
keylset wimix_script loadMode 0
keylset wimix_script loadSweepEnd 20
keylset wimix_script loadSweepStart 10
keylset wimix_script loadSweepStep 1
keylset wimix_script continueFlag 0
keylset wimix_script ClientMix.WirelessTv.TrafficType {VideoStreaming}
keylset wimix_script ClientMix.WirelessTv.Percentage 20
keylset wimix_script ClientMix.WirelessTv.delay 0
keylset wimix_script ClientMix.WirelessTv.endTime END
keylset wimix_script ClientMix.HomeLaptop.TrafficType {InternetRadio InternetVoice PersonalEmail WebBrowsing}
keylset wimix_script ClientMix.HomeLaptop.Percentage 20
keylset wimix_script ClientMix.HomeLaptop.delay 0
keylset wimix_script ClientMix.HomeLaptop.endTime END
keylset wimix_script ClientMix.iDevice.TrafficType {InternetVideo WebBrowsing}
keylset wimix_script ClientMix.iDevice.Percentage 20
keylset wimix_script ClientMix.iDevice.delay 0
keylset wimix_script ClientMix.iDevice.endTime END
keylset wimix_script ClientMix.WorkLaptop.TrafficType {WorkEmail WebBrowsing FileDownloads FileUploads}
keylset wimix_script ClientMix.WorkLaptop.Percentage 20
keylset wimix_script ClientMix.WorkLaptop.delay 0
keylset wimix_script ClientMix.WorkLaptop.endTime END
keylset wimix_script ClientMix.VideoCamera.TrafficType {VideoSurveillance}
keylset wimix_script ClientMix.VideoCamera.Percentage 20
keylset wimix_script ClientMix.VideoCamera.delay 0
keylset wimix_script ClientMix.VideoCamera.endTime END

#Wimix Traffic Profiles


keylset FileDownloads WimixtrafficDirection downlink
keylset FileDownloads WimixtrafficIntendedrate 50
keylset FileDownloads WimixtrafficFramesize 1500
keylset FileDownloads WimixtrafficRateMode 1
keylset FileDownloads WimixtrafficServer MediaServer
keylset FileDownloads WimixtrafficipProtocolNum Auto
keylset FileDownloads WimixtrafficPhyrate 54
keylset FileDownloads WimixtrafficType FTP
keylset FileDownloads Layer4to7UserName anonymous
keylset FileDownloads Layer4to7SrcPort 21863
keylset FileDownloads Layer4to7FileName home.txt
keylset FileDownloads Layer4to7FileSize 10
keylset FileDownloads Layer4to7Operation "ftp get"
keylset FileDownloads Layer4to7Password anonymous
keylset FileDownloads Layer4to7DestPort 31863
keylset FileDownloads Layer3qosenable 0
keylset FileDownloads Layer3qosdscp 0
keylset FileDownloads Layer2qoswlanUp 0
keylset FileDownloads Layer2qosenable 0
keylset FileDownloads Layer2qosethUp 0
keylset FileDownloads SlaperLoad 50


keylset VideoStreaming WimixtrafficDirection downlink
keylset VideoStreaming WimixtrafficIntendedrate 100
keylset VideoStreaming WimixtrafficFramesize 1500
keylset VideoStreaming WimixtrafficRateMode 1
keylset VideoStreaming WimixtrafficServer MediaServer
keylset VideoStreaming WimixtrafficipProtocolNum Auto
keylset VideoStreaming WimixtrafficPhyrate 54
keylset VideoStreaming WimixtrafficType MPEG2
keylset VideoStreaming Layer4to7SrcPort 22291
keylset VideoStreaming Layer4to7DestPort 32291
keylset VideoStreaming Layer3qosenable 0
keylset VideoStreaming Layer3qosdscp 0
keylset VideoStreaming Layer2qoswlanUp 0
keylset VideoStreaming Layer2qosenable 0
keylset VideoStreaming Layer2qosethUp 0
keylset VideoStreaming SlaDf 50
keylset VideoStreaming SlaMlr 1


keylset FileUploads WimixtrafficDirection uplink
keylset FileUploads WimixtrafficIntendedrate 20
keylset FileUploads WimixtrafficFramesize 1500
keylset FileUploads WimixtrafficRateMode 1
keylset FileUploads WimixtrafficServer Internet
keylset FileUploads WimixtrafficipProtocolNum Auto
keylset FileUploads WimixtrafficPhyrate 54
keylset FileUploads WimixtrafficType FTP
keylset FileUploads Layer4to7UserName anonymous
keylset FileUploads Layer4to7SrcPort 22786
keylset FileUploads Layer4to7FileName home.txt
keylset FileUploads Layer4to7FileSize 10
keylset FileUploads Layer4to7Operation "ftp put"
keylset FileUploads Layer4to7Password anonymous
keylset FileUploads Layer4to7DestPort 32786
keylset FileUploads Layer3qosenable 0
keylset FileUploads Layer3qosdscp 0
keylset FileUploads Layer2qoswlanUp 0
keylset FileUploads Layer2qosenable 0
keylset FileUploads Layer2qosethUp 0
keylset FileUploads SlaperLoad 50


keylset WebBrowsing WimixtrafficDirection downlink
keylset WebBrowsing WimixtrafficIntendedrate 10
keylset WebBrowsing WimixtrafficFramesize 470
keylset WebBrowsing WimixtrafficRateMode 1
keylset WebBrowsing WimixtrafficServer Internet
keylset WebBrowsing WimixtrafficipProtocolNum Auto
keylset WebBrowsing WimixtrafficPhyrate 54
keylset WebBrowsing WimixtrafficType HTTP
keylset WebBrowsing Layer4to7Operation "http get"
keylset WebBrowsing Layer4to7SrcPort 21163
keylset WebBrowsing Layer4to7DestPort 31163
keylset WebBrowsing Layer3qosenable 0
keylset WebBrowsing Layer3qosdscp 0
keylset WebBrowsing Layer2qoswlanUp 0
keylset WebBrowsing Layer2qosenable 0
keylset WebBrowsing Layer2qosethUp 0
keylset WebBrowsing SlaperLoad 50


keylset VideoSurveillance WimixtrafficDirection uplink
keylset VideoSurveillance WimixtrafficIntendedrate 100
keylset VideoSurveillance WimixtrafficFramesize 1500
keylset VideoSurveillance WimixtrafficRateMode 1
keylset VideoSurveillance WimixtrafficServer MediaServer
keylset VideoSurveillance WimixtrafficipProtocolNum Auto
keylset VideoSurveillance WimixtrafficPhyrate 54
keylset VideoSurveillance WimixtrafficType MPEG2
keylset VideoSurveillance Layer4to7SrcPort 23556
keylset VideoSurveillance Layer4to7DestPort 33556
keylset VideoSurveillance Layer3qosenable 0
keylset VideoSurveillance Layer3qosdscp 0
keylset VideoSurveillance Layer2qoswlanUp 0
keylset VideoSurveillance Layer2qosenable 0
keylset VideoSurveillance Layer2qosethUp 0
keylset VideoSurveillance SlaDf 50
keylset VideoSurveillance SlaMlr 1


keylset InternetVideo WimixtrafficDirection downlink
keylset InternetVideo WimixtrafficIntendedrate 100
keylset InternetVideo WimixtrafficFramesize 1500
keylset InternetVideo WimixtrafficRateMode 1
keylset InternetVideo WimixtrafficServer Internet
keylset InternetVideo WimixtrafficipProtocolNum Auto
keylset InternetVideo WimixtrafficPhyrate 54
keylset InternetVideo WimixtrafficType UDP
keylset InternetVideo Layer4to7SrcPort 20674
keylset InternetVideo Layer4to7DestPort 30674
keylset InternetVideo Layer3qosenable 0
keylset InternetVideo Layer3qosdscp 0
keylset InternetVideo Layer2qoswlanUp 0
keylset InternetVideo Layer2qosenable 0
keylset InternetVideo Layer2qosethUp 0
keylset InternetVideo SlaLatency 10000
keylset InternetVideo SlaJitter 500
keylset InternetVideo SlaPacketLoss 10


keylset PersonalEmail WimixtrafficDirection downlink
keylset PersonalEmail WimixtrafficIntendedrate 10
keylset PersonalEmail WimixtrafficFramesize 1500
keylset PersonalEmail WimixtrafficRateMode 1
keylset PersonalEmail WimixtrafficServer Internet
keylset PersonalEmail WimixtrafficipProtocolNum Auto
keylset PersonalEmail WimixtrafficPhyrate 54
keylset PersonalEmail WimixtrafficType HTTP
keylset PersonalEmail Layer4to7Operation "http get"
keylset PersonalEmail Layer4to7SrcPort 21508
keylset PersonalEmail Layer4to7DestPort 31508
keylset PersonalEmail Layer3qosenable 0
keylset PersonalEmail Layer3qosdscp 0
keylset PersonalEmail Layer2qoswlanUp 0
keylset PersonalEmail Layer2qosenable 0
keylset PersonalEmail Layer2qosethUp 0
keylset PersonalEmail SlaperLoad 50


keylset InternetVoice WimixtrafficsipSignaling 1
keylset InternetVoice WimixtrafficDirection bidirectional
keylset InternetVoice WimixtrafficIntendedrate 50
keylset InternetVoice WimixtrafficFramesize 236
keylset InternetVoice WimixtrafficRateMode 1
keylset InternetVoice WimixtrafficServer Internet
keylset InternetVoice WimixtrafficipProtocolNum Auto
keylset InternetVoice WimixtrafficPhyrate 54
keylset InternetVoice WimixtrafficType VOIPG711
keylset InternetVoice Layer4to7SrcPort 24069
keylset InternetVoice Layer4to7DestPort 34069
keylset InternetVoice Layer3qosenable 0
keylset InternetVoice Layer3qosdscp 0
keylset InternetVoice Layer2qoswlanUp 0
keylset InternetVoice Layer2qosenable 0
keylset InternetVoice Layer2qosethUp 0
keylset InternetVoice SlaslaMode 0
keylset InternetVoice Slavalue 78


keylset InternetRadio WimixtrafficDirection downlink
keylset InternetRadio WimixtrafficIntendedrate 50
keylset InternetRadio WimixtrafficFramesize 256
keylset InternetRadio WimixtrafficRateMode 1
keylset InternetRadio WimixtrafficServer Internet
keylset InternetRadio WimixtrafficipProtocolNum Auto
keylset InternetRadio WimixtrafficPhyrate 54
keylset InternetRadio WimixtrafficType RTP
keylset InternetRadio Layer4to7SrcPort 21794
keylset InternetRadio Layer4to7DestPort 31794
keylset InternetRadio Layer3qosenable 0
keylset InternetRadio Layer3qosdscp 0
keylset InternetRadio Layer2qoswlanUp 0
keylset InternetRadio Layer2qosenable 0
keylset InternetRadio Layer2qosethUp 0
keylset InternetRadio SlaLatency 10000
keylset InternetRadio SlaJitter 500
keylset InternetRadio SlaPacketLoss 10


keylset WorkEmail WimixtrafficDirection downlink
keylset WorkEmail WimixtrafficIntendedrate 10
keylset WorkEmail WimixtrafficFramesize 300
keylset WorkEmail WimixtrafficRateMode 1
keylset WorkEmail WimixtrafficServer Internet
keylset WorkEmail WimixtrafficipProtocolNum Auto
keylset WorkEmail WimixtrafficPhyrate 54
keylset WorkEmail WimixtrafficType TCP
keylset WorkEmail Layer4to7SrcPort 21155
keylset WorkEmail Layer4to7DestPort 31155
keylset WorkEmail Layer3qosenable 0
keylset WorkEmail Layer3qosdscp 0
keylset WorkEmail Layer2qoswlanUp 0
keylset WorkEmail Layer2qosenable 0
keylset WorkEmail Layer2qosethUp 0
keylset WorkEmail SlaperLoad 50

#Wimix Server Profiles


keylset MediaServer WimixservermacAddress 00:01:02:5F:45:1B
keylset MediaServer WimixserverethPort 192.168.10.246:1
keylset MediaServer WimixserveripMode 0
keylset MediaServer Wimixservernetmask 255.255.255.0
keylset MediaServer WimixservermacMode 1
keylset MediaServer WimixserveripAddress 192.168.1.201
keylset MediaServer Wimixservergateway 192.168.1.1
keylset MediaServer Vlanenable 0
keylset MediaServer Vlanid 0


keylset Internet WimixservermacAddress 00:01:02:BD:1C:B2
keylset Internet WimixserverethPort 192.168.10.246:1
keylset Internet WimixserveripMode 0
keylset Internet Wimixservernetmask 255.255.255.0
keylset Internet WimixservermacMode 1
keylset Internet WimixserveripAddress 192.168.1.202
keylset Internet Wimixservergateway 192.168.1.1
keylset Internet Vlanenable 0
keylset Internet Vlanid 0

#Generic Dut Definitions

#Generic Dut - generic_dut_0
keylset generic_dut_0 Vendor generic
keylset generic_dut_0 APSwVersion unspecified
keylset generic_dut_0 APModel unspecified
keylset generic_dut_0 Interface.802_11b.WavetestPort 192.168.10.246:6
keylset generic_dut_0 Interface.802_11b.InterfaceType 802.11bg

#Generic Dut - generic_dut_1
keylset generic_dut_1 Vendor generic
keylset generic_dut_1 APSwVersion unspecified
keylset generic_dut_1 APModel unspecified
keylset generic_dut_1 Interface.802_11b.WavetestPort 192.168.10.246:9
keylset generic_dut_1 Interface.802_11b.InterfaceType 802.11bg

#Generic Dut - generic_dut_2
keylset generic_dut_2 Vendor generic
keylset generic_dut_2 APSwVersion unspecified
keylset generic_dut_2 APModel unspecified
keylset generic_dut_2 Interface.802_3.WavetestPort 192.168.10.246:1
keylset generic_dut_2 Interface.802_3.InterfaceType 802.3

#Source a file looking for a license key definition
catch {source [file join $env(HOME) "vw_licenses.tcl"]}

