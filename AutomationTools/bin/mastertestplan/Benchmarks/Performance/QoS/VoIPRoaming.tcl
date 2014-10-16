#keylset qos_roam_quality FlowLearningTime 5
#keylset qos_roam_quality ClientLearningTime 5
#keylset qos_roam_quality SettleTime 5
#keylset qos_roam_quality AgingTime 10
#keylset qos_roam_quality ArpNumRetries 5
#keylset qos_roam_quality ArpRate 50
#keylset qos_roam_quality ArpTimeout 10

#Test Configuration of VoIP Roaming Test


keylset global_config TrialDuration 300

keylset global_config TestList { qos_roam_quality }
keylset wireless_group_a AuxDut $my_roam_dut1
keylset wireless_group_g AuxDut $my_roam_dut1
keylset ether_group_1 AuxDut $my_roam_dut1
#  qos_roam_quality test specific information
#
keylset qos_roam_quality Benchmark qos_roam_quality
keylset qos_roam_quality qosRoamQosEnabled True
keylset qos_roam_quality qosRoamBaseCallDurationUnits 1
keylset qos_roam_quality qosRoamCallDropDelayThreshold 50
keylset qos_roam_quality qosRoamBaseCallDurationVal 1
keylset qos_roam_quality qosRoamDeauth 0
keylset qos_roam_quality qosRoamPreauth 0
keylset qos_roam_quality qosRoamDisassociate 0
keylset qos_roam_quality qosRoamDwellTime 5
keylset qos_roam_quality qosRoamRenewDHCPonConn 0
keylset qos_roam_quality qosRoamPmkid 0
keylset qos_roam_quality qosRoamRenewDHCP 0
keylset qos_roam_quality qosRoamDurationUnits 1
keylset qos_roam_quality qosRoamRepeatValue 8
keylset qos_roam_quality qosRoamPowerProfileFlag 0
keylset qos_roam_quality qosRoamRepeatType 1
keylset qos_roam_quality qosRoamReassoc 0
keylset qos_roam_quality qosRoamRoamRate 0.5
keylset qos_roam_quality VoiceCodec { G.711 G.723 G.729 }

#Set the P/F criteria
keylset qos_roam_quality AcceptableDroppedCalls  $AcceptableDroppedCalls
keylset qos_roam_quality AcceptableRValue  $AcceptableRValue
#keylset qos_roam_quality AcceptableDroppedCalls $AcceptableDroppedCalls
#keylset qos_roam_quality AcceptableRValue  $AcceptableRValue
