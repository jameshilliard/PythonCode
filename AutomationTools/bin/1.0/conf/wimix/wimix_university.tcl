keylset global_config ChassisName 192.168.10.246


#License Keys for running tests beyond the basic benchmarking tests

#keylset global_config LicenseKey {#####-#####-##### #####-#####-#####}
keylset global_config Source {Handset}
keylset global_config Destination {Laptop PDA VideoCamera}
keylset global_config Channel {6}

#Traffics Global Options

keylset global_config Content None
keylset global_config UserPattern None
keylset global_config PayloadData None
keylset global_config DestinationPort None
keylset global_config SourcePort None

#Learning Global Options

keylset global_config ClientLearningTime 2

#Connection Global Options

#TestParameters Global Options

keylset global_config wimixResultSampleVal 10
keylset global_config wimixResultSampleOption 0
keylset global_config ReconnectClients 1
keylset global_config LossTolerance 0
keylset global_config RandomSeed 1186004294
keylset global_config overTimeGraphs 0
keylset global_config wimixResultOption 0

#Tests - you may define more than one in a TCL list.
keylset global_config TestList {wimix_script}

#Group Handset
keylset Handset GroupType 802.11abg
keylset Handset Dut generic_dut_0

#Group Handset - Client Options
keylset Handset GratuitousArp True
keylset Handset Dhcp Enable
keylset Handset Ssid veriwave
keylset Handset Qos Disable
keylset Handset Uapsd 0
keylset Handset ListenInt 1
keylset Handset phyInterface 802.11ag
keylset Handset Wlan80211eQoSAC 0
keylset Handset SubnetMask 255.255.0.0
keylset Handset BaseIp 192.168.3.10
keylset Handset Gateway 192.168.1.1
keylset Handset MacAddress None

#Group Handset - Security Options
keylset Handset Method {None}

#Group Laptop
keylset Laptop GroupType 802.11abg
keylset Laptop Dut generic_dut_1

#Group Laptop - Client Options
keylset Laptop GratuitousArp True
keylset Laptop Dhcp Enable
keylset Laptop Ssid veriwave
keylset Laptop Hops -1
keylset Laptop Qos Disable
keylset Laptop Uapsd 0
keylset Laptop ListenInt 1
keylset Laptop phyInterface 802.11ag
keylset Laptop Wlan80211eQoSAC 0
keylset Laptop SubnetMask 255.255.0.0
keylset Laptop BaseIp 192.168.1.10
keylset Laptop Gateway 192.168.1.1
keylset Laptop MacAddress None

#Group Laptop - Security Options
keylset Laptop Method {None}

#Group PDA
keylset PDA GroupType 802.11abg
keylset PDA Dut generic_dut_0

#Group PDA - Client Options
keylset PDA GratuitousArp True
keylset PDA Dhcp Enable
keylset PDA Ssid veriwave
keylset PDA Hops 0
keylset PDA Qos Disable
keylset PDA Uapsd 0
keylset PDA ListenInt 1
keylset PDA phyInterface 802.11ag
keylset PDA Wlan80211eQoSAC 0
keylset PDA SubnetMask 255.255.0.0
keylset PDA BaseIp 192.168.2.10
keylset PDA Gateway 192.168.1.1
keylset PDA MacAddress None

#Group PDA - Security Options
keylset PDA Method {None}

#Group VideoCamera
keylset VideoCamera GroupType 802.11abg
keylset VideoCamera Dut generic_dut_0

#Group VideoCamera - Client Options
keylset VideoCamera GratuitousArp True
keylset VideoCamera Dhcp Enable
keylset VideoCamera Ssid veriwave
keylset VideoCamera Hops 2
keylset VideoCamera Qos Disable
keylset VideoCamera Uapsd 0
keylset VideoCamera ListenInt 1
keylset VideoCamera phyInterface 802.11ag
keylset VideoCamera Wlan80211eQoSAC 0
keylset VideoCamera SubnetMask 255.255.0.0
keylset VideoCamera BaseIp 192.168.4.10
keylset VideoCamera Gateway 192.168.1.1
keylset VideoCamera MacAddress None

#Group VideoCamera - Security Options
keylset VideoCamera Method {None}

#wimix_script Options
keylset wimix_script Test wimix_script
keylset wimix_script wimixMode 0

#Wimix Test Settings
keylset wimix_script Test wimix_script
keylset wimix_script wimixMode Traffic
keylset wimix_script testProfile University
keylset wimix_script testProfileImage images/wimix_university.png
keylset wimix_script staggerStart 0
keylset wimix_script staggerStartInt 1
keylset wimix_script loadVal 20000
keylset wimix_script totalLoadPer 100.0
keylset wimix_script loadSweepStart 1000
keylset wimix_script loadMode 0
keylset wimix_script continueFlag 0
keylset wimix_script loadSweepEnd 30000
keylset wimix_script totalTrafficPer 100.0
keylset wimix_script loadSweepStep 5000
keylset wimix_script TrafficMix.VOIPG711.ClientType {Handset}
keylset wimix_script TrafficMix.VOIPG711.Percentage 7.0
keylset wimix_script TrafficMix.VOIPG711.delay 0
keylset wimix_script TrafficMix.VOIPG711.endTime END
keylset wimix_script TrafficMix.VOIPG729.ClientType {Handset}
keylset wimix_script TrafficMix.VOIPG729.Percentage 4.0
keylset wimix_script TrafficMix.VOIPG729.delay 0
keylset wimix_script TrafficMix.VOIPG729.endTime END
keylset wimix_script TrafficMix.Telnet.ClientType {Laptop}
keylset wimix_script TrafficMix.Telnet.Percentage 2.0
keylset wimix_script TrafficMix.Telnet.delay 0
keylset wimix_script TrafficMix.Telnet.endTime END
keylset wimix_script TrafficMix.HttpGet.ClientType {Laptop}
keylset wimix_script TrafficMix.HttpGet.Percentage 12.0
keylset wimix_script TrafficMix.HttpGet.delay 0
keylset wimix_script TrafficMix.HttpGet.endTime END
keylset wimix_script TrafficMix.HttpPost.ClientType {Laptop}
keylset wimix_script TrafficMix.HttpPost.Percentage 4.0
keylset wimix_script TrafficMix.HttpPost.delay 0
keylset wimix_script TrafficMix.HttpPost.endTime END
keylset wimix_script TrafficMix.FtpGet.ClientType {Laptop}
keylset wimix_script TrafficMix.FtpGet.Percentage 6.0
keylset wimix_script TrafficMix.FtpGet.delay 0
keylset wimix_script TrafficMix.FtpGet.endTime END
keylset wimix_script TrafficMix.FtpPut.ClientType {Laptop}
keylset wimix_script TrafficMix.FtpPut.Percentage 7.0
keylset wimix_script TrafficMix.FtpPut.delay 0
keylset wimix_script TrafficMix.FtpPut.endTime END
keylset wimix_script TrafficMix.WinBrowserAnnouncement.ClientType {Laptop}
keylset wimix_script TrafficMix.WinBrowserAnnouncement.Percentage 5.0
keylset wimix_script TrafficMix.WinBrowserAnnouncement.delay 0
keylset wimix_script TrafficMix.WinBrowserAnnouncement.endTime END
keylset wimix_script TrafficMix.NetBios.ClientType {Laptop}
keylset wimix_script TrafficMix.NetBios.Percentage 2.0
keylset wimix_script TrafficMix.NetBios.delay 0
keylset wimix_script TrafficMix.NetBios.endTime END
keylset wimix_script TrafficMix.SMB.ClientType {Laptop}
keylset wimix_script TrafficMix.SMB.Percentage 3.0
keylset wimix_script TrafficMix.SMB.delay 0
keylset wimix_script TrafficMix.SMB.endTime END
keylset wimix_script TrafficMix.SMTP.ClientType {PDA}
keylset wimix_script TrafficMix.SMTP.Percentage 10.0
keylset wimix_script TrafficMix.SMTP.delay 0
keylset wimix_script TrafficMix.SMTP.endTime END
keylset wimix_script TrafficMix.Mpeg-2Video.ClientType {VideoCamera}
keylset wimix_script TrafficMix.Mpeg-2Video.Percentage 10.0
keylset wimix_script TrafficMix.Mpeg-2Video.delay 0
keylset wimix_script TrafficMix.Mpeg-2Video.endTime END
keylset wimix_script TrafficMix.Mpeg-2Webcast.ClientType {PDA}
keylset wimix_script TrafficMix.Mpeg-2Webcast.Percentage 10.0
keylset wimix_script TrafficMix.Mpeg-2Webcast.delay 0
keylset wimix_script TrafficMix.Mpeg-2Webcast.endTime END
keylset wimix_script TrafficMix.UnclassifiedUdpTraffic.ClientType {Laptop}
keylset wimix_script TrafficMix.UnclassifiedUdpTraffic.Percentage 8.0
keylset wimix_script TrafficMix.UnclassifiedUdpTraffic.delay 0
keylset wimix_script TrafficMix.UnclassifiedUdpTraffic.endTime END
keylset wimix_script TrafficMix.RealaudioStream.ClientType {Laptop}
keylset wimix_script TrafficMix.RealaudioStream.Percentage 3.0
keylset wimix_script TrafficMix.RealaudioStream.delay 0
keylset wimix_script TrafficMix.RealaudioStream.endTime END
keylset wimix_script TrafficMix.RealvideoStream.ClientType {Laptop}
keylset wimix_script TrafficMix.RealvideoStream.Percentage 5.0
keylset wimix_script TrafficMix.RealvideoStream.delay 0
keylset wimix_script TrafficMix.RealvideoStream.endTime END
keylset wimix_script TrafficMix.WindowsMediaPlayer.ClientType {PDA}
keylset wimix_script TrafficMix.WindowsMediaPlayer.Percentage 2.0
keylset wimix_script TrafficMix.WindowsMediaPlayer.delay 0
keylset wimix_script TrafficMix.WindowsMediaPlayer.endTime END

#Wimix Traffic Profiles


keylset CrmApp WimixtrafficDirection downlink
keylset CrmApp WimixtrafficIntendedrate 10
keylset CrmApp WimixtrafficFramesize 428
keylset CrmApp WimixtrafficRateMode 1
keylset CrmApp WimixtrafficServer GPserver
keylset CrmApp WimixtrafficipProtocolNum Auto
keylset CrmApp WimixtrafficPhyrate 54
keylset CrmApp WimixtrafficType TCP
keylset CrmApp Layer4to7SrcPort 40001
keylset CrmApp Layer4to7DestPort 50001
keylset CrmApp Layer3qosenable 0
keylset CrmApp Layer3qosdscp 0
keylset CrmApp Layer2qoswlanUp 0
keylset CrmApp Layer2qosenable 0
keylset CrmApp Layer2qosethUp 0
keylset CrmApp SlaperLoad 50


keylset RTSP WimixtrafficDirection downlink
keylset RTSP WimixtrafficIntendedrate 20
keylset RTSP WimixtrafficFramesize 108
keylset RTSP WimixtrafficRateMode 1
keylset RTSP WimixtrafficServer GPserver
keylset RTSP WimixtrafficipProtocolNum Auto
keylset RTSP WimixtrafficPhyrate 54
keylset RTSP WimixtrafficType RTP
keylset RTSP Layer4to7SrcPort 20001
keylset RTSP Layer4to7DestPort 30001
keylset RTSP Layer3qosenable 0
keylset RTSP Layer3qosdscp 0
keylset RTSP Layer2qoswlanUp 0
keylset RTSP Layer2qosenable 0
keylset RTSP Layer2qosethUp 0
keylset RTSP SlaLatency 10000
keylset RTSP SlaJitter 500
keylset RTSP SlaPacketLoss 10


keylset RealaudioStream WimixtrafficDirection downlink
keylset RealaudioStream WimixtrafficIntendedrate 50
keylset RealaudioStream WimixtrafficFramesize 146
keylset RealaudioStream WimixtrafficRateMode 1
keylset RealaudioStream WimixtrafficServer GPserver
keylset RealaudioStream WimixtrafficipProtocolNum Auto
keylset RealaudioStream WimixtrafficPhyrate 54
keylset RealaudioStream WimixtrafficType RTP
keylset RealaudioStream Layer4to7SrcPort 20004
keylset RealaudioStream Layer4to7DestPort 30004
keylset RealaudioStream Layer3qosenable 0
keylset RealaudioStream Layer3qosdscp 0
keylset RealaudioStream Layer2qoswlanUp 0
keylset RealaudioStream Layer2qosenable 0
keylset RealaudioStream Layer2qosethUp 0
keylset RealaudioStream SlaLatency 10000
keylset RealaudioStream SlaJitter 500
keylset RealaudioStream SlaPacketLoss 10


keylset Telnet WimixtrafficDirection downlink
keylset Telnet WimixtrafficIntendedrate 10
keylset Telnet WimixtrafficFramesize 132
keylset Telnet WimixtrafficRateMode 1
keylset Telnet WimixtrafficServer DNSserver
keylset Telnet WimixtrafficipProtocolNum Auto
keylset Telnet WimixtrafficPhyrate 54
keylset Telnet WimixtrafficType TCP
keylset Telnet Layer4to7SrcPort 23
keylset Telnet Layer4to7DestPort 23
keylset Telnet Layer3qosenable 0
keylset Telnet Layer3qosdscp 0
keylset Telnet Layer2qoswlanUp 0
keylset Telnet Layer2qosenable 0
keylset Telnet Layer2qosethUp 0
keylset Telnet SlaperLoad 50


keylset Mpeg-2Video WimixtrafficDirection downlink
keylset Mpeg-2Video WimixtrafficIntendedrate 180
keylset Mpeg-2Video WimixtrafficFramesize 1368
keylset Mpeg-2Video WimixtrafficRateMode 1
keylset Mpeg-2Video WimixtrafficServer VIDEOserver
keylset Mpeg-2Video WimixtrafficipProtocolNum Auto
keylset Mpeg-2Video WimixtrafficPhyrate 54
keylset Mpeg-2Video WimixtrafficType MPEG2
keylset Mpeg-2Video Layer4to7SrcPort 3155
keylset Mpeg-2Video Layer4to7DestPort 3155
keylset Mpeg-2Video Layer3qosenable 0
keylset Mpeg-2Video Layer3qosdscp 0
keylset Mpeg-2Video Layer2qoswlanUp 0
keylset Mpeg-2Video Layer2qosenable 0
keylset Mpeg-2Video Layer2qosethUp 0
keylset Mpeg-2Video SlaDf 150
keylset Mpeg-2Video SlaMlr 10


keylset FtpGet WimixtrafficDirection downlink
keylset FtpGet WimixtrafficIntendedrate 80
keylset FtpGet WimixtrafficFramesize 594
keylset FtpGet WimixtrafficRateMode 1
keylset FtpGet WimixtrafficServer FTPserver
keylset FtpGet WimixtrafficipProtocolNum Auto
keylset FtpGet WimixtrafficPhyrate 54
keylset FtpGet WimixtrafficType FTP
keylset FtpGet Layer4to7UserName anonymous
keylset FtpGet Layer4to7SrcPort 21000
keylset FtpGet Layer4to7FileName veriwave.txt
keylset FtpGet Layer4to7FileSize 10
keylset FtpGet Layer4to7Operation "ftp get"
keylset FtpGet Layer4to7Password anonymous
keylset FtpGet Layer4to7DestPort 22000
keylset FtpGet Layer3qosenable 0
keylset FtpGet Layer3qosdscp 0
keylset FtpGet Layer2qoswlanUp 0
keylset FtpGet Layer2qosenable 0
keylset FtpGet Layer2qosethUp 0
keylset FtpGet SlaperLoad 50


keylset BarcodeApp WimixtrafficDirection downlink
keylset BarcodeApp WimixtrafficIntendedrate 5
keylset BarcodeApp WimixtrafficFramesize 98
keylset BarcodeApp WimixtrafficRateMode 1
keylset BarcodeApp WimixtrafficServer HTTPserver
keylset BarcodeApp WimixtrafficipProtocolNum Auto
keylset BarcodeApp WimixtrafficPhyrate 54
keylset BarcodeApp WimixtrafficType UDP
keylset BarcodeApp WimixtrafficFrameSize 98
keylset BarcodeApp Layer4to7SrcPort 20002
keylset BarcodeApp Layer4to7DestPort 30002
keylset BarcodeApp Layer3qosenable 0
keylset BarcodeApp Layer3qosdscp 0
keylset BarcodeApp Layer2qoswlanUp 0
keylset BarcodeApp Layer2qosenable 0
keylset BarcodeApp Layer2qosethUp 0
keylset BarcodeApp SlaLatency 10000
keylset BarcodeApp SlaJitter 500
keylset BarcodeApp SlaPacketLoss 10


keylset NetBios WimixtrafficDirection downlink
keylset NetBios WimixtrafficIntendedrate 5
keylset NetBios WimixtrafficFramesize 96
keylset NetBios WimixtrafficRateMode 1
keylset NetBios WimixtrafficServer GPserver
keylset NetBios WimixtrafficipProtocolNum Auto
keylset NetBios WimixtrafficPhyrate 54
keylset NetBios WimixtrafficType TCP
keylset NetBios Layer4to7SrcPort 139
keylset NetBios Layer4to7DestPort 139
keylset NetBios Layer3qosenable 0
keylset NetBios Layer3qosdscp 0
keylset NetBios Layer2qoswlanUp 0
keylset NetBios Layer2qosenable 0
keylset NetBios Layer2qosethUp 0
keylset NetBios SlaperLoad 50


keylset VOIPG711 WimixtrafficipProtocolNum Auto
keylset VOIPG711 WimixtrafficDirection bidirectional
keylset VOIPG711 WimixtrafficServer VOIPserver
keylset VOIPG711 WimixtrafficsipSignaling 0
keylset VOIPG711 WimixtrafficPhyrate 11
keylset VOIPG711 WimixtrafficType VOIPG711
keylset VOIPG711 Layer4to7SrcPort 5004
keylset VOIPG711 Layer4to7DestPort 5003
keylset VOIPG711 Layer3qosenable 0
keylset VOIPG711 Layer3qosdscp 0
keylset VOIPG711 Layer2qoswlanUp 0
keylset VOIPG711 Layer2qosenable 0
keylset VOIPG711 Layer2qosethUp 0
keylset VOIPG711 SlaslaMode 0
keylset VOIPG711 Slavalue 78


keylset PatientMonitorInfo WimixtrafficDirection downlink
keylset PatientMonitorInfo WimixtrafficIntendedrate 10
keylset PatientMonitorInfo WimixtrafficFramesize 274
keylset PatientMonitorInfo WimixtrafficRateMode 1
keylset PatientMonitorInfo WimixtrafficServer DNSserver
keylset PatientMonitorInfo WimixtrafficipProtocolNum Auto
keylset PatientMonitorInfo WimixtrafficPhyrate 54
keylset PatientMonitorInfo WimixtrafficType TCP
keylset PatientMonitorInfo Layer4to7SrcPort 60009
keylset PatientMonitorInfo Layer4to7DestPort 70009
keylset PatientMonitorInfo Layer3qosenable 0
keylset PatientMonitorInfo Layer3qosdscp 0
keylset PatientMonitorInfo Layer2qoswlanUp 0
keylset PatientMonitorInfo Layer2qosenable 0
keylset PatientMonitorInfo Layer2qosethUp 0
keylset PatientMonitorInfo SlaperLoad 50


keylset DnsReq WimixtrafficDirection uplink
keylset DnsReq WimixtrafficIntendedrate 5
keylset DnsReq WimixtrafficFramesize 99
keylset DnsReq WimixtrafficRateMode 1
keylset DnsReq WimixtrafficServer DNSserver
keylset DnsReq WimixtrafficipProtocolNum Auto
keylset DnsReq WimixtrafficPhyrate 54
keylset DnsReq WimixtrafficType TCP
keylset DnsReq Layer4to7SrcPort 40007
keylset DnsReq Layer4to7DestPort 50007
keylset DnsReq Layer3qosenable 0
keylset DnsReq Layer3qosdscp 0
keylset DnsReq Layer2qoswlanUp 0
keylset DnsReq Layer2qosenable 0
keylset DnsReq Layer2qosethUp 0
keylset DnsReq SlaperLoad 50


keylset SMB WimixtrafficDirection downlink
keylset SMB WimixtrafficIntendedrate 10
keylset SMB WimixtrafficFramesize 530
keylset SMB WimixtrafficRateMode 1
keylset SMB WimixtrafficServer DNSserver
keylset SMB WimixtrafficipProtocolNum Auto
keylset SMB WimixtrafficPhyrate 54
keylset SMB WimixtrafficType TCP
keylset SMB Layer4to7SrcPort 445
keylset SMB Layer4to7DestPort 445
keylset SMB Layer3qosenable 0
keylset SMB Layer3qosdscp 0
keylset SMB Layer2qoswlanUp 0
keylset SMB Layer2qosenable 0
keylset SMB Layer2qosethUp 0
keylset SMB SlaperLoad 50


keylset WinBrowserAnnouncement WimixtrafficDirection uplink
keylset WinBrowserAnnouncement WimixtrafficIntendedrate 5
keylset WinBrowserAnnouncement WimixtrafficFramesize 220
keylset WinBrowserAnnouncement WimixtrafficRateMode 1
keylset WinBrowserAnnouncement WimixtrafficServer GPserver
keylset WinBrowserAnnouncement WimixtrafficipProtocolNum Auto
keylset WinBrowserAnnouncement WimixtrafficPhyrate 54
keylset WinBrowserAnnouncement WimixtrafficType TCP
keylset WinBrowserAnnouncement Layer4to7SrcPort 40002
keylset WinBrowserAnnouncement Layer4to7DestPort 50002
keylset WinBrowserAnnouncement Layer3qosenable 0
keylset WinBrowserAnnouncement Layer3qosdscp 0
keylset WinBrowserAnnouncement Layer2qoswlanUp 0
keylset WinBrowserAnnouncement Layer2qosenable 0
keylset WinBrowserAnnouncement Layer2qosethUp 0
keylset WinBrowserAnnouncement SlaperLoad 50


keylset DnsResp WimixtrafficDirection downlink
keylset DnsResp WimixtrafficIntendedrate 5
keylset DnsResp WimixtrafficFramesize 270
keylset DnsResp WimixtrafficRateMode 1
keylset DnsResp WimixtrafficServer DNSserver
keylset DnsResp WimixtrafficipProtocolNum Auto
keylset DnsResp WimixtrafficPhyrate 54
keylset DnsResp WimixtrafficType TCP
keylset DnsResp Layer4to7SrcPort 40009
keylset DnsResp Layer4to7DestPort 50009
keylset DnsResp Layer3qosenable 0
keylset DnsResp Layer3qosdscp 0
keylset DnsResp Layer2qoswlanUp 0
keylset DnsResp Layer2qosenable 0
keylset DnsResp Layer2qosethUp 0
keylset DnsResp SlaperLoad 50


keylset UnclassifiedUdpTraffic WimixtrafficDirection bidirectional
keylset UnclassifiedUdpTraffic WimixtrafficIntendedrate 20
keylset UnclassifiedUdpTraffic WimixtrafficFramesize 470
keylset UnclassifiedUdpTraffic WimixtrafficRateMode 1
keylset UnclassifiedUdpTraffic WimixtrafficServer GPserver
keylset UnclassifiedUdpTraffic WimixtrafficipProtocolNum Auto
keylset UnclassifiedUdpTraffic WimixtrafficPhyrate 54
keylset UnclassifiedUdpTraffic WimixtrafficType UDP
keylset UnclassifiedUdpTraffic Layer4to7SrcPort 20002
keylset UnclassifiedUdpTraffic Layer4to7DestPort 30002
keylset UnclassifiedUdpTraffic Layer3qosenable 0
keylset UnclassifiedUdpTraffic Layer3qosdscp 0
keylset UnclassifiedUdpTraffic Layer2qoswlanUp 0
keylset UnclassifiedUdpTraffic Layer2qosenable 0
keylset UnclassifiedUdpTraffic Layer2qosethUp 0
keylset UnclassifiedUdpTraffic SlaLatency 10000
keylset UnclassifiedUdpTraffic SlaJitter 500
keylset UnclassifiedUdpTraffic SlaPacketLoss 10


keylset FtpPut WimixtrafficDirection uplink
keylset FtpPut WimixtrafficIntendedrate 60
keylset FtpPut WimixtrafficFramesize 530
keylset FtpPut WimixtrafficRateMode 1
keylset FtpPut WimixtrafficServer FTPserver
keylset FtpPut WimixtrafficipProtocolNum Auto
keylset FtpPut WimixtrafficPhyrate 54
keylset FtpPut WimixtrafficType FTP
keylset FtpPut Layer4to7UserName anonymous
keylset FtpPut Layer4to7SrcPort 23000
keylset FtpPut Layer4to7FileName veriwave.txt
keylset FtpPut Layer4to7FileSize 10
keylset FtpPut Layer4to7Operation "ftp put"
keylset FtpPut Layer4to7Password anonymous
keylset FtpPut Layer4to7DestPort 24000
keylset FtpPut Layer3qosenable 0
keylset FtpPut Layer3qosdscp 0
keylset FtpPut Layer2qoswlanUp 0
keylset FtpPut Layer2qosenable 0
keylset FtpPut Layer2qosethUp 0
keylset FtpPut SlaperLoad 50


keylset SMTP WimixtrafficDirection uplink
keylset SMTP WimixtrafficIntendedrate 30
keylset SMTP WimixtrafficFramesize 119
keylset SMTP WimixtrafficRateMode 1
keylset SMTP WimixtrafficServer MAILserver
keylset SMTP WimixtrafficipProtocolNum Auto
keylset SMTP WimixtrafficPhyrate 54
keylset SMTP WimixtrafficType TCP
keylset SMTP Layer4to7SrcPort 40005
keylset SMTP Layer4to7DestPort 50005
keylset SMTP Layer3qosenable 0
keylset SMTP Layer3qosdscp 0
keylset SMTP Layer2qoswlanUp 0
keylset SMTP Layer2qosenable 0
keylset SMTP Layer2qosethUp 0
keylset SMTP SlaperLoad 50


keylset UnclassifiedTcp WimixtrafficDirection downlink
keylset UnclassifiedTcp WimixtrafficIntendedrate 5
keylset UnclassifiedTcp WimixtrafficFramesize 274
keylset UnclassifiedTcp WimixtrafficRateMode 1
keylset UnclassifiedTcp WimixtrafficServer DNSserver
keylset UnclassifiedTcp WimixtrafficipProtocolNum Auto
keylset UnclassifiedTcp WimixtrafficPhyrate 54
keylset UnclassifiedTcp WimixtrafficType TCP
keylset UnclassifiedTcp Layer4to7SrcPort 60001
keylset UnclassifiedTcp Layer4to7DestPort 70001
keylset UnclassifiedTcp Layer3qosenable 0
keylset UnclassifiedTcp Layer3qosdscp 0
keylset UnclassifiedTcp Layer2qoswlanUp 0
keylset UnclassifiedTcp Layer2qosenable 0
keylset UnclassifiedTcp Layer2qosethUp 0
keylset UnclassifiedTcp SlaperLoad 50


keylset VOIPG729 WimixtrafficsipSignaling 1
keylset VOIPG729 WimixtrafficDirection bidirectional
keylset VOIPG729 WimixtrafficServer VOIPserver
keylset VOIPG729 WimixtrafficipProtocolNum Auto
keylset VOIPG729 WimixtrafficPhyrate 54
keylset VOIPG729 WimixtrafficType VOIPG729
keylset VOIPG729 Layer4to7SrcPort 5004
keylset VOIPG729 Layer4to7DestPort 5003
keylset VOIPG729 Layer3qosenable 0
keylset VOIPG729 Layer3qosdscp 0
keylset VOIPG729 Layer2qoswlanUp 0
keylset VOIPG729 Layer2qosenable 0
keylset VOIPG729 Layer2qosethUp 0
keylset VOIPG729 SlaslaMode 0
keylset VOIPG729 Slavalue 70


keylset RealvideoStream WimixtrafficDirection downlink
keylset RealvideoStream WimixtrafficIntendedrate 60
keylset RealvideoStream WimixtrafficFramesize 232
keylset RealvideoStream WimixtrafficRateMode 1
keylset RealvideoStream WimixtrafficServer GPserver
keylset RealvideoStream WimixtrafficipProtocolNum Auto
keylset RealvideoStream WimixtrafficPhyrate 54
keylset RealvideoStream WimixtrafficType RTP
keylset RealvideoStream Layer4to7SrcPort 20005
keylset RealvideoStream Layer4to7DestPort 30005
keylset RealvideoStream Layer3qosenable 0
keylset RealvideoStream Layer3qosdscp 0
keylset RealvideoStream Layer2qoswlanUp 0
keylset RealvideoStream Layer2qosenable 0
keylset RealvideoStream Layer2qosethUp 0
keylset RealvideoStream SlaLatency 10000
keylset RealvideoStream SlaJitter 500
keylset RealvideoStream SlaPacketLoss 10


keylset VOIPG723 WimixtrafficipProtocolNum Auto
keylset VOIPG723 WimixtrafficDirection bidirectional
keylset VOIPG723 WimixtrafficServer VOIPserver
keylset VOIPG723 WimixtrafficsipSignaling 0
keylset VOIPG723 WimixtrafficPhyrate 54
keylset VOIPG723 WimixtrafficType VOIPG723
keylset VOIPG723 Layer4to7SrcPort 5004
keylset VOIPG723 Layer4to7DestPort 5003
keylset VOIPG723 Layer3qosenable 0
keylset VOIPG723 Layer3qosdscp 0
keylset VOIPG723 Layer2qoswlanUp 0
keylset VOIPG723 Layer2qosenable 0
keylset VOIPG723 Layer2qosethUp 0
keylset VOIPG723 SlaslaMode 0
keylset VOIPG723 Slavalue 70


keylset WinMx WimixtrafficDirection downlink
keylset WinMx WimixtrafficIntendedrate 12
keylset WinMx WimixtrafficFramesize 285
keylset WinMx WimixtrafficRateMode 1
keylset WinMx WimixtrafficServer GPserver
keylset WinMx WimixtrafficipProtocolNum Auto
keylset WinMx WimixtrafficPhyrate 54
keylset WinMx WimixtrafficType TCP
keylset WinMx Layer4to7SrcPort 40004
keylset WinMx Layer4to7DestPort 50004
keylset WinMx Layer3qosenable 0
keylset WinMx Layer3qosdscp 0
keylset WinMx Layer2qoswlanUp 0
keylset WinMx Layer2qosenable 0
keylset WinMx Layer2qosethUp 0
keylset WinMx SlaperLoad 50


keylset WindowsMediaPlayer WimixtrafficDirection downlink
keylset WindowsMediaPlayer WimixtrafficIntendedrate 80
keylset WindowsMediaPlayer WimixtrafficFramesize 151
keylset WindowsMediaPlayer WimixtrafficRateMode 1
keylset WindowsMediaPlayer WimixtrafficServer GPserver
keylset WindowsMediaPlayer WimixtrafficipProtocolNum Auto
keylset WindowsMediaPlayer WimixtrafficPhyrate 54
keylset WindowsMediaPlayer WimixtrafficType RTP
keylset WindowsMediaPlayer Layer4to7SrcPort 20006
keylset WindowsMediaPlayer Layer4to7DestPort 30006
keylset WindowsMediaPlayer Layer3qosenable 0
keylset WindowsMediaPlayer Layer3qosdscp 0
keylset WindowsMediaPlayer Layer2qoswlanUp 0
keylset WindowsMediaPlayer Layer2qosenable 0
keylset WindowsMediaPlayer Layer2qosethUp 0
keylset WindowsMediaPlayer SlaLatency 10000
keylset WindowsMediaPlayer SlaJitter 500
keylset WindowsMediaPlayer SlaPacketLoss 10


keylset HttpGet WimixtrafficDirection downlink
keylset HttpGet WimixtrafficIntendedrate 25
keylset HttpGet WimixtrafficFramesize 470
keylset HttpGet WimixtrafficRateMode 0
keylset HttpGet WimixtrafficServer HTTPserver
keylset HttpGet WimixtrafficipProtocolNum Auto
keylset HttpGet WimixtrafficPhyrate 54
keylset HttpGet WimixtrafficType HTTP
keylset HttpGet Layer4to7Operation "http get"
keylset HttpGet Layer4to7SrcPort 25000
keylset HttpGet Layer4to7DestPort 26000
keylset HttpGet Layer3qosenable 0
keylset HttpGet Layer3qosdscp 0
keylset HttpGet Layer2qoswlanUp 0
keylset HttpGet Layer2qosenable 0
keylset HttpGet Layer2qosethUp 0
keylset HttpGet SlaperLoad 50


keylset Mpeg-2Webcast WimixtrafficDirection multicast(downlink)
keylset Mpeg-2Webcast WimixtrafficIntendedrate 180
keylset Mpeg-2Webcast WimixtrafficFramesize 1368
keylset Mpeg-2Webcast WimixtrafficRateMode 1
keylset Mpeg-2Webcast WimixtrafficServer MULTICASTserver
keylset Mpeg-2Webcast WimixtrafficipProtocolNum Auto
keylset Mpeg-2Webcast WimixtrafficPhyrate 54
keylset Mpeg-2Webcast WimixtrafficType MPEG2
keylset Mpeg-2Webcast Layer4to7SrcPort 3155
keylset Mpeg-2Webcast Layer4to7DestPort 3155
keylset Mpeg-2Webcast Layer3qosenable 0
keylset Mpeg-2Webcast Layer3qosdscp 0
keylset Mpeg-2Webcast MulticastaddrmacAddress 01:00:5e:01:01:01
keylset Mpeg-2Webcast MulticastaddripAddress 224.1.1.1
keylset Mpeg-2Webcast Layer2qoswlanUp 0
keylset Mpeg-2Webcast Layer2qosenable 0
keylset Mpeg-2Webcast Layer2qosethUp 0
keylset Mpeg-2Webcast SlaDf 150
keylset Mpeg-2Webcast SlaMlr 10


keylset HttpPost WimixtrafficDirection uplink
keylset HttpPost WimixtrafficIntendedrate 25
keylset HttpPost WimixtrafficFramesize 470
keylset HttpPost WimixtrafficRateMode 1
keylset HttpPost WimixtrafficServer HTTPserver
keylset HttpPost WimixtrafficipProtocolNum Auto
keylset HttpPost WimixtrafficPhyrate 54
keylset HttpPost WimixtrafficType HTTP
keylset HttpPost Layer4to7Operation "http post"
keylset HttpPost Layer4to7SrcPort 27000
keylset HttpPost Layer4to7DestPort 28000
keylset HttpPost Layer3qosenable 0
keylset HttpPost Layer3qosdscp 0
keylset HttpPost Layer2qoswlanUp 0
keylset HttpPost Layer2qosenable 0
keylset HttpPost Layer2qosethUp 0
keylset HttpPost SlaperLoad 50

#Wimix Server Profiles


keylset HTTPserver WimixservermacAddress 00:11:22:33:cc:01
keylset HTTPserver WimixserverethPort 192.168.10.246:1
keylset HTTPserver WimixserveripMode 0
keylset HTTPserver Wimixservernetmask 255.255.0.0
keylset HTTPserver WimixservermacMode 1
keylset HTTPserver WimixserveripAddress 192.168.3.200
keylset HTTPserver Wimixservergateway 192.168.1.1
keylset HTTPserver Vlanenable 0
keylset HTTPserver Vlanid 0


keylset DNSserver WimixservermacAddress 00:11:22:33:ff:03
keylset DNSserver WimixserverethPort 192.168.10.246:1
keylset DNSserver WimixserveripMode 0
keylset DNSserver Wimixservernetmask 255.255.0.0
keylset DNSserver WimixservermacMode 1
keylset DNSserver WimixserveripAddress 192.168.8.200
keylset DNSserver Wimixservergateway 192.168.1.1
keylset DNSserver Vlanenable 0
keylset DNSserver Vlanid 0


keylset VIDEOserver WimixservermacAddress 00:11:22:33:ff:02
keylset VIDEOserver WimixserverethPort 192.168.10.246:1
keylset VIDEOserver WimixserveripMode 0
keylset VIDEOserver Wimixservernetmask 255.255.0.0
keylset VIDEOserver WimixservermacMode 1
keylset VIDEOserver WimixserveripAddress 192.168.5.200
keylset VIDEOserver Wimixservergateway 192.168.1.1
keylset VIDEOserver Vlanenable 0
keylset VIDEOserver Vlanid 0


keylset FTPserver WimixservermacAddress 00:11:22:33:bb:01
keylset FTPserver WimixserverethPort 192.168.10.246:1
keylset FTPserver WimixserveripMode 0
keylset FTPserver Wimixservernetmask 255.255.0.0
keylset FTPserver WimixservermacMode 1
keylset FTPserver WimixserveripAddress 192.168.2.200
keylset FTPserver Wimixservergateway 192.168.1.1
keylset FTPserver Vlanenable 0
keylset FTPserver Vlanid 0


keylset GPserver WimixservermacAddress 00:11:22:33:dd:01
keylset GPserver WimixserverethPort 192.168.10.246:1
keylset GPserver WimixserveripMode 0
keylset GPserver Wimixservernetmask 255.255.0.0
keylset GPserver WimixservermacMode 1
keylset GPserver WimixserveripAddress 192.168.4.200
keylset GPserver Wimixservergateway 192.168.1.1
keylset GPserver Vlanenable 0
keylset GPserver Vlanid 0


keylset VOIPserver WimixservermacAddress 00:11:22:33:aa:01
keylset VOIPserver WimixserverethPort 192.168.10.246:1
keylset VOIPserver WimixserveripMode 0
keylset VOIPserver Wimixservernetmask 255.255.0.0
keylset VOIPserver WimixservermacMode 1
keylset VOIPserver WimixserveripAddress 192.168.1.200
keylset VOIPserver Wimixservergateway 192.168.1.1
keylset VOIPserver Vlanenable 0
keylset VOIPserver Vlanid 0


keylset MULTICASTserver WimixservermacAddress 00:11:22:33:ff:01
keylset MULTICASTserver WimixserverethPort 192.168.10.246:1
keylset MULTICASTserver WimixserveripMode 0
keylset MULTICASTserver Wimixservernetmask 255.255.0.0
keylset MULTICASTserver WimixservermacMode 1
keylset MULTICASTserver WimixserveripAddress 192.168.6.200
keylset MULTICASTserver Wimixservergateway 192.168.1.1
keylset MULTICASTserver Vlanenable 0
keylset MULTICASTserver Vlanid 0


keylset MAILserver WimixservermacAddress 00:11:22:33:ff:02
keylset MAILserver WimixserverethPort 192.168.10.246:1
keylset MAILserver WimixserveripMode 0
keylset MAILserver Wimixservernetmask 255.255.0.0
keylset MAILserver WimixservermacMode 1
keylset MAILserver WimixserveripAddress 192.168.7.200
keylset MAILserver Wimixservergateway 192.168.1.1
keylset MAILserver Vlanenable 0
keylset MAILserver Vlanid 0

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

