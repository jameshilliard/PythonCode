# VCL Init script for Tcl
VclSession session
VclChassis chassis
VclCard card
VclPort port
VclMobileClient mc
VclEthernetClient ec
VclClientGroup clientGroup
VclFlow flow
VclFlowGroup flowGroup
VclBiflow biflow
VclRawServer rawServer
VclRawClient rawClient
VclHttpClient httpClient
VclHttpServer httpServer
VclFtpClient ftpClient
VclFtpServer ftpServer
VclAppSession appSession
VclFlowModMac mac
mac setDefaultFlow flow
VclFlowModIpv4 ipv4
ipv4 setDefaultFlow flow
VclFlowModIcmp icmp
icmp setDefaultFlow flow
VclFlowModUdp udp
udp setDefaultFlow flow
VclFlowModTcp tcp
tcp setDefaultFlow flow
VclFlowModRtp rtp
rtp setDefaultFlow flow
VclFlowModWlanQos wlanQos
wlanQos setDefaultFlow flow
VclFlowModEnetQos enetQos
enetQos setDefaultFlow flow
VclCapture capture
VclStats stats
VclFlowStats flowStats
VclStatsClient clientStats
VclActions action
VclIgmpRsp igmp
MemoryBuffer membuf
Checksum checksum
VclUtilities vclUtils
MemoryBuffer sendData
MemoryBuffer recvData
VclPortIf wtrpc
VclCapFile capfile
VclBiflowModTcp biflowTcp
biflowTcp setDefaultBiflow biflow
appSession setDefaultBiflow biflow

set vclVersion [ action getVclVersionStr ]

proc startFlowTransmit { flowList } {
   return [ action startFlowTransmit $flowList ]
}

proc stopFlowTransmit { flowList } {
   return [ action stopFlowTransmit $flowList ]
}

proc startFlowGroup { groupName } {
   return [ action startFlowGroup $groupName ]
}

proc stopFlowGroup { groupName } {
   return [ action stopFlowGroup $groupName ]
}

proc vclError { err } {
    return [ vclUtils getErrorString $err ]
}

proc vclAppError { err } {
    return [ vclUtils getAppErrorString $err ]
}

proc vclTime {} {
    return [ vclUtils getTime ]
}

package provide vcl 1.0
