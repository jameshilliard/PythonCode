# System -WiMix  WMTC001 - WiMix_Hospital_Environment

if { ![info exists env(VW_MTP_HOME)] } {
    puts "Error: Environment variable VW_MTP_HOME not set.\n"
    exit -1
}
set src_path [file join $env(VW_MTP_HOME) global_configs.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

set src_path [file join $env(VW_MTP_HOME) client_setup_wimix.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

set src_path [file join $env(VW_MTP_HOME) System WiMix wimix.tcl]
if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}

keylset global_config LogsDir [file join $LogsDirRoot System WiMix WMTC001]

keylset global_config Source {PatientMonitor}
keylset global_config Destination {Handset Laptop VideoCamera}


#wimix_script Options
keylset wimix_script Test wimix_script
keylset wimix_script wimixMode 0

#Wimix Test Settings
keylset wimix_script wimixMode Traffic
keylset wimix_script testProfile HealthCare
keylset wimix_script testProfileImage images/wimix_hospital.png
keylset wimix_script staggerStart 0
keylset wimix_script staggerStartInt 1
keylset wimix_script loadVal 10000
keylset wimix_script totalLoadPer 100.0
keylset wimix_script loadSweepStart 1000
keylset wimix_script loadMode 0
keylset wimix_script continueFlag 0
keylset wimix_script loadSweepEnd 30000
keylset wimix_script totalTrafficPer 100.0
keylset wimix_script loadSweepStep 5000
keylset wimix_script TrafficMix.VOIPG711.ClientType {Handset}
keylset wimix_script TrafficMix.VOIPG711.Percentage 18.0
keylset wimix_script TrafficMix.VOIPG711.delay 0
keylset wimix_script TrafficMix.VOIPG711.endTime END
keylset wimix_script TrafficMix.HttpGet.ClientType {Laptop}
keylset wimix_script TrafficMix.HttpGet.Percentage 10.0
keylset wimix_script TrafficMix.HttpGet.delay 0
keylset wimix_script TrafficMix.HttpGet.endTime END
keylset wimix_script TrafficMix.HttpPost.ClientType {Laptop}
keylset wimix_script TrafficMix.HttpPost.Percentage 7.0
keylset wimix_script TrafficMix.HttpPost.delay 0
keylset wimix_script TrafficMix.HttpPost.endTime END
keylset wimix_script TrafficMix.FtpGet.ClientType {Laptop}
keylset wimix_script TrafficMix.FtpGet.Percentage 5.0
keylset wimix_script TrafficMix.FtpGet.delay 0
keylset wimix_script TrafficMix.FtpGet.endTime END
keylset wimix_script TrafficMix.SMTP.ClientType {Laptop}
keylset wimix_script TrafficMix.SMTP.Percentage 10.0
keylset wimix_script TrafficMix.SMTP.delay 0
keylset wimix_script TrafficMix.SMTP.endTime END
keylset wimix_script TrafficMix.DnsReq.ClientType {Laptop}
keylset wimix_script TrafficMix.DnsReq.Percentage 1.0
keylset wimix_script TrafficMix.DnsReq.delay 0
keylset wimix_script TrafficMix.DnsReq.endTime END
keylset wimix_script TrafficMix.DnsResp.ClientType {Laptop}
keylset wimix_script TrafficMix.DnsResp.Percentage 1.0
keylset wimix_script TrafficMix.DnsResp.delay 0
keylset wimix_script TrafficMix.DnsResp.endTime END
keylset wimix_script TrafficMix.RTSP.ClientType {Laptop}
keylset wimix_script TrafficMix.RTSP.Percentage 2.0
keylset wimix_script TrafficMix.RTSP.delay 0
keylset wimix_script TrafficMix.RTSP.endTime END
keylset wimix_script TrafficMix.Mpeg-2Webcast.ClientType {Laptop}
keylset wimix_script TrafficMix.Mpeg-2Webcast.Percentage 20.0
keylset wimix_script TrafficMix.Mpeg-2Webcast.delay 0
keylset wimix_script TrafficMix.Mpeg-2Webcast.endTime END
keylset wimix_script TrafficMix.Mpeg-2Video.ClientType {VideoCamera}
keylset wimix_script TrafficMix.Mpeg-2Video.Percentage 20.0
keylset wimix_script TrafficMix.Mpeg-2Video.delay 0
keylset wimix_script TrafficMix.Mpeg-2Video.endTime END
keylset wimix_script TrafficMix.PatientMonitorInfo.ClientType {PatientMonitor}
keylset wimix_script TrafficMix.PatientMonitorInfo.Percentage 6.0
keylset wimix_script TrafficMix.PatientMonitorInfo.delay 0
keylset wimix_script TrafficMix.PatientMonitorInfo.endTime END

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
