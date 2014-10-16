#wimix.tcl

#keylset global_config Channel {36}

#Tests - you may define more than one in a TCL list.
#keylset global_config TrialDuration 1800
#keylset global_config TrialDuration 10

keylset global_config TestList {wimix_script}
keylset wimix_script Test wimix_script

    
#Traffics Global Options

keylset global_config Content None
keylset global_config UserPattern None
keylset global_config PayloadData None
keylset global_config DestinationPort None
keylset global_config SourcePort None

#Learning Global Options

keylset global_config AgingTime 0
keylset global_config ClientLearningTime 2

#TestParameters Global Options

keylset global_config wimixResultSampleVal 10
keylset global_config wimixResultSampleOption 0
keylset global_config SettleTime 1
keylset global_config ReconnectClients 1
keylset global_config LossTolerance 0
keylset global_config RandomSeed 1186422843
keylset global_config overTimeGraphs 0
keylset global_config wimixResultOption 0
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


keylset PatientMonitorInfo WimixtrafficDirection downlink
keylset PatientMonitorInfo WimixtrafficIntendedrate 10
keylset PatientMonitorInfo WimixtrafficFramesize 274
keylset PatientMonitorInfo WimixtrafficRateMode 1
keylset PatientMonitorInfo WimixtrafficServer DNSserver
keylset PatientMonitorInfo WimixtrafficipProtocolNum Auto
keylset PatientMonitorInfo WimixtrafficPhyrate 54
keylset PatientMonitorInfo WimixtrafficType TCP
keylset PatientMonitorInfo Layer4to7SrcPort 60009
keylset PatientMonitorInfo Layer4to7DestPort 65535
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
keylset FtpPut Layer4to7SrcPort 41000
keylset FtpPut Layer4to7FileName veriwave.txt
keylset FtpPut Layer4to7FileSize 10
keylset FtpPut Layer4to7Operation "ftp put"
keylset FtpPut Layer4to7Password anonymous
keylset FtpPut Layer4to7DestPort 51000
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
keylset HttpGet Layer4to7SrcPort 41001
keylset HttpGet Layer4to7DestPort 41002
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
keylset HttpPost Layer4to7SrcPort 41003
keylset HttpPost Layer4to7DestPort 41004
keylset HttpPost Layer3qosenable 0
keylset HttpPost Layer3qosdscp 0
keylset HttpPost Layer2qoswlanUp 0
keylset HttpPost Layer2qosenable 0
keylset HttpPost Layer2qosethUp 0
keylset HttpPost SlaperLoad 50

#Wimix Server Profiles


keylset HTTPserver WimixservermacAddress 00:11:22:33:cc:01
keylset HTTPserver WimixserverethPort 10.50.5.177:1
keylset HTTPserver WimixserveripMode 0
keylset HTTPserver Wimixservernetmask 255.255.0.0
keylset HTTPserver WimixservermacMode 1
keylset HTTPserver WimixserveripAddress 192.168.3.200
keylset HTTPserver Wimixservergateway 192.168.1.1
keylset HTTPserver Vlanenable 0
keylset HTTPserver Vlanid 0


keylset DNSserver WimixservermacAddress 00:11:22:33:ff:03
keylset DNSserver WimixserverethPort 10.50.5.177:1
keylset DNSserver WimixserveripMode 0
keylset DNSserver Wimixservernetmask 255.255.0.0
keylset DNSserver WimixservermacMode 1
keylset DNSserver WimixserveripAddress 192.168.8.200
keylset DNSserver Wimixservergateway 192.168.1.1
keylset DNSserver Vlanenable 0
keylset DNSserver Vlanid 0


keylset VIDEOserver WimixservermacAddress 00:11:22:33:aa:02
keylset VIDEOserver WimixserverethPort 10.50.5.177:1
keylset VIDEOserver WimixserveripMode 0
keylset VIDEOserver Wimixservernetmask 255.255.0.0
keylset VIDEOserver WimixservermacMode 1
keylset VIDEOserver WimixserveripAddress 192.168.5.200
keylset VIDEOserver Wimixservergateway 192.168.1.1
keylset VIDEOserver Vlanenable 0
keylset VIDEOserver Vlanid 0


keylset FTPserver WimixservermacAddress 00:11:22:33:bb:01
keylset FTPserver WimixserverethPort 10.50.5.177:1
keylset FTPserver WimixserveripMode 0
keylset FTPserver Wimixservernetmask 255.255.0.0
keylset FTPserver WimixservermacMode 1
keylset FTPserver WimixserveripAddress 192.168.2.200
keylset FTPserver Wimixservergateway 192.168.1.1
keylset FTPserver Vlanenable 0
keylset FTPserver Vlanid 0


keylset GPserver WimixservermacAddress 00:11:22:33:dd:01
keylset GPserver WimixserverethPort 10.50.5.177:1
keylset GPserver WimixserveripMode 0
keylset GPserver Wimixservernetmask 255.255.0.0
keylset GPserver WimixservermacMode 1
keylset GPserver WimixserveripAddress 192.168.4.200
keylset GPserver Wimixservergateway 192.168.1.1
keylset GPserver Vlanenable 0
keylset GPserver Vlanid 0


keylset VOIPserver WimixservermacAddress 00:11:22:33:aa:01
keylset VOIPserver WimixserverethPort 10.50.5.177:1
keylset VOIPserver WimixserveripMode 0
keylset VOIPserver Wimixservernetmask 255.255.0.0
keylset VOIPserver WimixservermacMode 1
keylset VOIPserver WimixserveripAddress 192.168.1.200
keylset VOIPserver Wimixservergateway 192.168.1.1
keylset VOIPserver Vlanenable 0
keylset VOIPserver Vlanid 0


keylset MULTICASTserver WimixservermacAddress 00:11:22:33:ff:01
keylset MULTICASTserver WimixserverethPort 10.50.5.177:1
keylset MULTICASTserver WimixserveripMode 0
keylset MULTICASTserver Wimixservernetmask 255.255.0.0
keylset MULTICASTserver WimixservermacMode 1
keylset MULTICASTserver WimixserveripAddress 192.168.6.200
keylset MULTICASTserver Wimixservergateway 192.168.1.1
keylset MULTICASTserver Vlanenable 0
keylset MULTICASTserver Vlanid 0


keylset MAILserver WimixservermacAddress 00:11:22:33:ff:02
keylset MAILserver WimixserverethPort 10.50.5.177:1
keylset MAILserver WimixserveripMode 0
keylset MAILserver Wimixservernetmask 255.255.0.0
keylset MAILserver WimixservermacMode 1
keylset MAILserver WimixserveripAddress 192.168.7.200
keylset MAILserver Wimixservergateway 192.168.1.1
keylset MAILserver Vlanenable 0
keylset MAILserver Vlanid 0
