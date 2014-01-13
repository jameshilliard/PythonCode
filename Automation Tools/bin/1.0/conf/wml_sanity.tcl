if {[catch {set test_chassis $env(TEST_CHASSIS)}]} {
    set test_chassis "192.168.10.249"
}

if {[catch {set test_dut $env(TEST_DUT)}]} {
    set test_dut "dut1"
}

if {[catch {set test_aux_dut $env(TEST_AUX_DUT)}]} {
    set test_aux_dut "dut2"
}

if {[catch {set test_list $env(TEST_LIST)}]} {
    set test_list {
      test_qos_assurance
      test_qos_capacity
      test_qos_roam_quality
      test_unicast_latency
      test_unicast_max_client_capacity
      test_unicast_max_forwarding_rate
      test_unicast_packet_loss
      test_unicast_unidirectional_throughput
      test_roaming_delay
      test_roaming_benchmark
      test_tcp_goodput
      test_rate_vs_range
      test_mesh_latency_aggregate
      test_mesh_latency_per_hop
      test_mesh_max_forwarding_rate_per_hop
      test_mesh_throughput_aggregate
      test_mesh_throughput_per_hop
      test_aaa_auth_rate
      
      dhcp
      
      channel_2
      channel_11
      channel_40
      channel_64

      two_chan_roam

      eleven_n
  }
  
  foreach method $ALL_SECURITY_METHODS {
      lappend test_list method_$method
  }
}

set test_method {None}

if {[catch {set test_channel $env(TEST_CHANNEL)}]} {
	set test_channel 9
}

if {[catch {set test_ssid $env(TEST_SSID)}]} {
	set test_ssid sanity
}

set test_frame_sizes {88} 
set test_iloads      {700.0}

##### Global configuration #####
keylset global_config ChassisName   $test_chassis

#keylset global_config LicenseKey    #####-#####-#####
catch {source [file join $env(HOME) "vw_licenses.tcl"]}

keylset global_config Direction     {Unidirectional}

keylset global_config Channel       {$test_channel}

keylset global_config NumTrials     1

keylset global_config TrialDuration 2

keylset global_config LogsDir       [file join $VW_TEST_ROOT results]

keylset global_config TestList $test_list

##### Group configuration #####
keylset group_wireless NumClients      2
keylset group_wireless GroupType       802.11abg
keylset group_wireless Method          $test_method

keylset group_wireless PskAscii        something_secret
keylset group_wireless WepKey40Hex     CAFEBABE01
keylset group_wireless WepKey128Hex    BADC0FFEE123456789CAFEFEED

# the following line ties this group to the appropriate access point info.
# mostly used to figure out how to configure the AP and which card/port
# on the veriwave chassis to use.
keylset group_wireless Dut              $test_dut

keylset group_wireless Dhcp             Disable
keylset group_wireless BaseIp           10.10.11.1
keylset group_wireless IncrIp           0.0.0.1
keylset group_wireless SubnetMask       255.255.0.0
keylset group_wireless Gateway          10.10.251.1
keylset group_wireless BssidIndex       2
keylset group_wireless Ssid             $test_ssid

keylset group_wireless GratuitousArp    False

keylset group_wireless Identity          anonymous
keylset group_wireless Password          whatever
keylset group_wireless AnonymousIdentity anonymous

keylset group_wireless Hops              0

keylset group_wireless AuxDut           $test_aux_dut
keylset group_wireless repeatValue      10
keylset group_wireless roamRate         1

keylset group_wireless ClientCertificate          $VW_TEST_ROOT/etc/cert-clt.pem
keylset group_wireless RootCertificate            $VW_TEST_ROOT/etc/root.pem
keylset group_wireless PrivateKeyFile             $VW_TEST_ROOT/etc/cert-clt.pem
keylset group_wireless EnableValidateCertificate  off

keylset group_wireless deauth 0
keylset group_wireless disassociate 0
keylset group_wireless durationUnits 0
keylset group_wireless dwellTime 1.0
keylset group_wireless pmkid 0
keylset group_wireless powerProfileFlag 0
keylset group_wireless preauth 0
keylset group_wireless reassoc 0
keylset group_wireless renewDHCP 0
keylset group_wireless renewDHCPonConn 0

# the wired clients
keylset group_ether NumClients        2
keylset group_ether GroupType         802.3
keylset group_ether Dut               $test_dut
keylset group_ether Dhcp              Disable
keylset group_ether Gateway           10.10.251.1
keylset group_ether BaseIp            10.10.12.1
keylset group_ether SubnetMask        255.255.0.0
keylset group_ether IncrIp            0.0.0.1
keylset group_ether AuxDut            $test_aux_dut
keylset group_ether Hops              -1

keylset group_wireless_2 NumClients      2
keylset group_wireless_2 GroupType       802.11abg
keylset group_wireless_2 Method          $test_method
keylset group_wireless_2 PskAscii        something_secret
keylset group_wireless_2 Dut              $test_aux_dut
keylset group_wireless_2 Dhcp             Disable
keylset group_wireless_2 BaseIp           10.10.13.1
keylset group_wireless_2 IncrIp           0.0.0.1
keylset group_wireless_2 SubnetMask       255.255.0.0
keylset group_wireless_2 Gateway          10.10.251.1
keylset group_wireless_2 BssidIndex       2
keylset group_wireless_2 Ssid             $test_ssid
keylset group_wireless_2 GratuitousArp    True
keylset group_wireless_2 Identity          anonymous
keylset group_wireless_2 Password          whatever
keylset group_wireless_2 AnonymousIdentity anonymous
keylset group_wireless_2 Hops              1

# qos groups
# the wireless clients
keylset wireless_voice NumClients       2
keylset wireless_voice GroupType        802.11abg
keylset wireless_voice Method           $test_method
keylset wireless_voice Dut              $test_dut
keylset wireless_voice Dhcp             Disable
keylset wireless_voice BaseIp           10.10.11.1
keylset wireless_voice IncrIp           0.0.0.1
keylset wireless_voice SubnetMask       255.255.0.0
keylset wireless_voice Gateway          10.10.251.1
keylset wireless_voice BssidIndex       2
keylset wireless_voice Ssid             $test_ssid
keylset wireless_voice repeatValue      30
keylset wireless_voice TrafficClass     Voice
keylset wireless_voice GratuitousArp    True

set wireless_background $wireless_voice
keylset wireless_background TrafficClass     Background

keylset ether_voice NumClients        2
keylset ether_voice GroupType         802.3
keylset ether_voice Dut               $test_dut
keylset ether_voice Dhcp              Disable
keylset ether_voice Gateway           10.10.251.1
keylset ether_voice BaseIp            10.10.13.1
keylset ether_voice SubnetMask        255.255.0.0
keylset ether_voice IncrIp            0.0.0.1
keylset ether_voice TrafficClass      Voice

set ether_background $ether_voice
keylset ether_background TrafficClass Background

set group_dhcp $group_wireless
keylset group_dhcp dhcp Enable

set group_11n $group_wireless
keylset group_11n phyInterface 802.11n

#
# roaming_delay test-specific information
#
# since all roaming_delay options are per group,
# their values need to be defined at the group
# level
keylset test_roaming_delay     Test        roaming_delay
keylset test_roaming_delay     Source      { group_wireless }
keylset test_roaming_delay     Destination { group_ether }

#
#  qos_roam_quality test specific information
#
keylset test_qos_roam_quality Test        qos_roam_quality
keylset test_qos_roam_quality Destination { group_wireless }
keylset test_qos_roam_quality Source      { group_ether }
keylset test_qos_roam_quality baseCallDurationUnits 0
keylset test_qos_roam_quality callDropDelayThreshold 50
keylset test_qos_roam_quality baseCallDurationVal 5



#
# roaming_benchmark test specific information
#
# most roaming_benchmark options are per group and thus
# must have their values defined at the group level
#
# roaming_benchmark test currently not enabled
keylset test_roaming_benchmark Test        roaming_benchmark
keylset test_roaming_benchmark Source      { group_ether }
keylset test_roaming_benchmark Destination { group_wireless }
keylset test_roaming_benchmark repeatValue 5
keylset test_roaming_benchmark repeatType 1

#
#  unicast_latency test-specific information
#
keylset test_unicast_latency Test          unicast_latency
keylset test_unicast_latency Source        { group_wireless }
keylset test_unicast_latency Destination   { group_ether }
keylset test_unicast_latency Frame         Custom
keylset test_unicast_latency FrameSizeList $test_frame_sizes
keylset test_unicast_latency ILoadList     $test_iloads
keylset test_unicast_latency ILoadMode     Custom

#
#  unicast_max_client_capacity test specific information
#
keylset test_unicast_max_client_capacity Test          unicast_max_client_capacity
keylset test_unicast_max_client_capacity Source        { group_ether }
keylset test_unicast_max_client_capacity Destination   { group_wireless }
keylset test_unicast_max_client_capacity Frame Standard
keylset test_unicast_max_client_capacity FrameSizeList 512
keylset test_unicast_max_client_capacity ILoadList     10
keylset test_unicast_max_client_capacity ILoadMode Custom
keylset test_unicast_max_client_capacity MaxSearchValue 255

#
#  unicast_packet_loss test-specific information
#
keylset test_unicast_packet_loss Test          unicast_packet_loss
keylset test_unicast_packet_loss Source        { group_wireless }
keylset test_unicast_packet_loss Destination   { group_ether }
keylset test_unicast_packet_loss Frame         Standard
keylset test_unicast_packet_loss FrameSizeList $test_frame_sizes
keylset test_unicast_packet_loss ILoadList     $test_iloads
keylset test_unicast_packet_loss ILoadMode     Custom

#
#  unicast_max_forwarding_rate test-specific information
#
keylset test_unicast_max_forwarding_rate Test             unicast_max_forwarding_rate
keylset test_unicast_max_forwarding_rate Source           { group_wireless }
keylset test_unicast_max_forwarding_rate Destination      { group_ether }
keylset test_unicast_max_forwarding_rate Frame            Standard
keylset test_unicast_max_forwarding_rate FrameSizeList    $test_frame_sizes
keylset test_unicast_max_forwarding_rate SearchResolution 0.1

#
#  unicast_unidirectional_throughput test-specific information
#
keylset test_unicast_unidirectional_throughput Test          unicast_unidirectional_throughput
keylset test_unicast_unidirectional_throughput Source        { group_wireless }
keylset test_unicast_unidirectional_throughput Destination   { group_ether }
keylset test_unicast_unidirectional_throughput Frame Standard
keylset test_unicast_unidirectional_throughput FrameSizeList $test_frame_sizes
keylset test_unicast_unidirectional_throughput SearchResolution 0.1 
keylset test_unicast_unidirectional_throughput Mode Fps
keylset test_unicast_unidirectional_throughput MinSearchValue Default
keylset test_unicast_unidirectional_throughput MaxSearchValue Default
keylset test_unicast_unidirectional_throughput StartValue Default

#
# mesh_latency_aggregate test specific information
#
keylset test_mesh_latency_aggregate Test          mesh_latency_aggregate
keylset test_mesh_latency_aggregate Source        { group_ether }
keylset test_mesh_latency_aggregate Destination   {  group_wireless_2  }
keylset test_mesh_latency_aggregate FrameSizeList { 88 }
keylset test_mesh_latency_aggregate ILoadList { 700.0 }

#  mesh_latency_per_hop test specific information
#
keylset test_mesh_latency_per_hop Test          mesh_latency_per_hop
keylset test_mesh_latency_per_hop Frame Custom
keylset test_mesh_latency_per_hop Source        { group_ether }
keylset test_mesh_latency_per_hop Destination   { group_wireless_2 }
keylset test_mesh_latency_per_hop FrameSizeList { 88 } 
keylset test_mesh_latency_per_hop ILoadList { 700.0 }
keylset test_mesh_latency_per_hop ILoadMode Custom

#
#  mesh_max_forwarding_rate_per_hop test specific information
#
keylset test_mesh_max_forwarding_rate_per_hop Test          mesh_max_forwarding_rate_per_hop
keylset test_mesh_max_forwarding_rate_per_hop Frame Standard
keylset test_mesh_max_forwarding_rate_per_hop Source        { group_ether }
keylset test_mesh_max_forwarding_rate_per_hop Destination   { group_wireless_2 }
keylset test_mesh_max_forwarding_rate_per_hop FrameSizeList {88}
keylset test_mesh_max_forwarding_rate_per_hop SearchResolution 0.1

#
#  mesh_throughput_aggregate test specific information
#
# use either the Fps settings or the percentage settings for 
# SearchResolution, MinSearchValue,  MaxSearchValue and StartValue.
#
keylset test_mesh_throughput_aggregate Test          mesh_throughput_aggregate
keylset test_mesh_throughput_aggregate Frame Standard
keylset test_mesh_throughput_aggregate Source        { group_ether }
keylset test_mesh_throughput_aggregate Destination   { group_wireless_2 }
keylset test_mesh_throughput_aggregate FrameSizeList {88}
keylset test_mesh_throughput_aggregate SearchResolution 0.1
keylset test_mesh_throughput_aggregate Mode Percent
keylset test_mesh_throughput_aggregate MinSearchValue 1%
keylset test_mesh_throughput_aggregate MaxSearchValue 150%
keylset test_mesh_throughput_aggregate StartValue 50%

#
#  mesh_throughput_per_hop test specific information
#
# use either the Fps settings or the percentage settings for 
# SearchResolution, MinSearchValue,  MaxSearchValue and StartValue.
#
keylset test_mesh_throughput_per_hop Test          mesh_throughput_per_hop
keylset test_mesh_throughput_per_hop Frame Standard
keylset test_mesh_throughput_per_hop Source        { group_ether }
keylset test_mesh_throughput_per_hop Destination   { group_wireless_2 }
keylset test_mesh_throughput_per_hop FrameSizeList {88}
keylset test_mesh_throughput_per_hop SearchResolution 0.1
keylset test_mesh_throughput_per_hop Mode Percent
keylset test_mesh_throughput_per_hop MinSearchValue 1%
keylset test_mesh_throughput_per_hop MaxSearchValue 150%
keylset test_mesh_throughput_per_hop StartValue 50%

#
#  rate_vs_range test specific information
#
keylset test_rate_vs_range Test          rate_vs_range
keylset test_rate_vs_range Frame Custom
keylset test_rate_vs_range Source        { group_wireless }
keylset test_rate_vs_range Destination   { group_ether }
keylset test_rate_vs_range FrameSizeList { 256 }
keylset test_rate_vs_range ILoadList { 4380.0 }
keylset test_rate_vs_range Mode Custom
keylset test_rate_vs_range ExternalAttenuation 0
keylset test_rate_vs_range InitialPowerLevel -10
keylset test_rate_vs_range FinalPowerLevel -20
keylset test_rate_vs_range IncrementPowerLevel 2
keylset test_rate_vs_range GratuitousArp True

#
# tcp_goodput test specific information
#
keylset test_tcp_goodput Test          tcp_goodput
keylset test_tcp_goodput Source        { group_ether }
keylset test_tcp_goodput Destination   { group_wireless }
keylset test_tcp_goodput NumOfSessionPerClient 2
keylset test_tcp_goodput TcpWindowSize 65535
keylset test_tcp_goodput FrameSizeList { 536 1460 }

#
# aaa_auth_rate test specific information
#
keylset test_aaa_auth_rate Test          aaa_auth_rate
keylset test_aaa_auth_rate Source        { aaa_group }
keylset test_aaa_auth_rate Destination   { aaa_group }
keylset test_aaa_auth_rate AuthenticationRate 10
keylset test_aaa_auth_rate ResultSampleTime 1
keylset test_aaa_auth_rate DisconnectClients True

set aaa_group $group_wireless
keylset aaa_group Method WPA-EAP-TLS

#
# qos assurance
#
keylset test_qos_assurance Test        qos_assurance
keylset test_qos_assurance Source      { wireless_voice wireless_background }
keylset test_qos_assurance Destination { ether_voice ether_background}
keylset test_qos_assurance VoiceQoSEnabled True
keylset test_qos_assurance VoiceCodec G.711
keylset test_qos_assurance VoiceNumberOfCalls 1
keylset test_qos_assurance VoiceUserPriority 7
keylset test_qos_assurance VoiceTosField Default
keylset test_qos_assurance VoiceTosReserved False
keylset test_qos_assurance VoiceTosDiffservDscp Default
keylset test_qos_assurance VoiceTosLowCost False
keylset test_qos_assurance VoiceTosLowDelay False
keylset test_qos_assurance VoiceTosHighThroughput False
keylset test_qos_assurance VoiceTosHighReliability False
keylset test_qos_assurance VoiceSearchMax 50
keylset test_qos_assurance VoiceSearchMin 1
keylset test_qos_assurance VoiceSrcPort 5003
keylset test_qos_assurance VoiceDestPort 5004
keylset test_qos_assurance SlaMinRValue 78.0
keylset test_qos_assurance SlaMaxPktLoss 1.0
keylset test_qos_assurance SlaMode R-Value
keylset test_qos_assurance SlaMaxLatency 30.0
keylset test_qos_assurance SlaMaxJitter 250.0
keylset test_qos_assurance BackgroundQoSEnabled False
keylset test_qos_assurance BackgroundFrameRate 100
keylset test_qos_assurance BackgroundFRrameSize 1500
keylset test_qos_assurance BackgroundMaxFrameRate Default
keylset test_qos_assurance BackgroundMinFrameRate Default
keylset test_qos_assurance BackgroundSearchResolution 0.1
keylset test_qos_assurance BackgroundSearchStep 10
keylset test_qos_assurance BackgroundType UDP
keylset test_qos_assurance BackgroundUserPriority 1
keylset test_qos_assurance BackgroundTosField Default
keylset test_qos_assurance BackgroundTosReserved False
keylset test_qos_assurance BackgroundTosDiffservDscp Default
keylset test_qos_assurance BackgroundTosLowCost False
keylset test_qos_assurance BackgroundTosLowDelay False
keylset test_qos_assurance BackgroundTosHighThroughput False
keylset test_qos_assurance BackgroundTosHighReliability False
keylset test_qos_assurance BackgroundSrcPort 0
keylset test_qos_assurance BackgroundDestPort 0
keylset test_qos_assurance BackgroundDirection Bidirectional

keylset test_qos_assurance ArpRate 0

#
# qos capacity
#
keylset test_qos_capacity Test        qos_capacity
keylset test_qos_capacity Source      { wireless_voice wireless_background }
keylset test_qos_capacity Destination { ether_voice ether_background}
keylset test_qos_capacity VoiceCodec G.711
keylset test_qos_capacity VoiceSearchMin 10
keylset test_qos_capacity VoiceSearchMax 11
keylset test_qos_capacity VoiceUserPriority 7
keylset test_qos_capacity VoiceTosField Default
keylset test_qos_capacity VoiceTosReserved False
keylset test_qos_capacity VoiceTosDiffsrvDscp Default
keylset test_qos_capacity VoiceTosLowCost False
keylset test_qos_capacity VoiceTosLowDelay False
keylset test_qos_capacity VoiceTosHighThroughput False
keylset test_qos_capacity VoiceTosHighReliability False
keylset test_qos_capacity VoiceSrcPort 5004
keylset test_qos_capacity VoiceDestPort 5003
keylset test_qos_capacity VoiceQoSEnabled False
keylset test_qos_capacity SlaMinRValue 78.0
keylset test_qos_capacity SlaMaxPktLoss 1.0
keylset test_qos_capacity SlaMode R-Value
keylset test_qos_capacity SlaMaxLatency 30.0
keylset test_qos_capacity SlaMaxJitter 250.0
keylset test_qos_capacity BackgroundFrameSize 1500
keylset test_qos_capacity BackgroundFrameRate 100
keylset test_qos_capacity BackgroundType UDP
keylset test_qos_capacity BackgroundUserPriority 1
keylset test_qos_capacity BackgroundTosField Default
keylset test_qos_capacity BackgroundTosReserved False
keylset test_qos_capacity BackgroundTosDiffservDscp Default
keylset test_qos_capacity BackgroundTosLowCost False
keylset test_qos_capacity BackgroundTosLowDelay False
keylset test_qos_capacity BackgroundTosHighThroughput False
keylset test_qos_capacity BackgroundTosHighReliability False
keylset test_qos_capacity BackgroundSrcPort 0
keylset test_qos_capacity BackgroundDestPort 0
keylset test_qos_capacity BackgroundQosEnabled True

keylset test_qos_capacity ArpRate 0

keylset method_null Test          unicast_packet_loss
keylset method_null Destination   { group_ether    }
keylset method_null FrameSizeList 88
keylset method_null ILoadList     5
keylset method_null TrialDuration 1

#
# security method testing
#
foreach method $ALL_SECURITY_METHODS {
    set group_$method $group_wireless
    keylset group_$method Method $method

    set method_$method $method_null
    keylset method_$method Source group_$method
}

#
# channel tests
#
set group_channels $group_wireless
set channel_list {2 11 40 64}
foreach channel $channel_list {
    set group_channel_$channel $group_wireless
    keylset group_channel_$channel Channel $channel

    # make sure floats still work
    if { $channel <= 14 } {
        keylset group_channel_$channel MgmtPhyRate       5.5
    }

    set channel_$channel $method_None
    keylset channel_$channel Source group_channel_$channel
}

#
# DHCP test
#
set dhcp $method_None
keylset dhcp Source group_dhcp

#
# 802.11n test
#
set eleven_n $method_None
keylset eleven_n Source group_11n

if {[catch {source [file join $env(HOME) hardware.tcl]}]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}
if {![info exists dut1] || ![info exists dut2]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}
    
#
# multiple channel roaming
# (must be after the sourcing of dut info)
#
upvar #0 $test_aux_dut aux_copy
set two_chan_dut $aux_copy
keylset two_chan_dut Channel 1
set two_chan_group $group_wireless
keylset two_chan_group AuxDut two_chan_dut
set two_chan_roam $test_roaming_delay
keylset two_chan_roam Source two_chan_group

