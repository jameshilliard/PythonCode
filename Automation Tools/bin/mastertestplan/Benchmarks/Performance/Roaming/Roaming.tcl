#Test Configuration of Roaming Test

keylset roaming_delay FlowLearningTime 5
keylset roaming_delay ClientLearningTime 5
keylset roaming_delay SettleTime 2
keylset roaming_delay AgingTime 5
keylset roaming_delay ArpNumRetries 5
keylset roaming_delay ArpRate 50
keylset roaming_delay ArpTimeout 20


keylset global_config TrialDuration 100
keylset global_config TestList { roaming_delay }


keylset wireless_group_a AuxDut $my_roam_dut1
keylset wireless_group_a learningFlowFlag 1
keylset wireless_group_a learningPacketCount  10
keylset wireless_group_a learningPacketRate 100
keylset wireless_group_a learningPacketSize 256
keylset wireless_group_a flowPacketSize 256
keylset wireless_group_a flowRate 100
#Select dwell time to be 20 sec
keylset wireless_group_a dwellTime 20
#dwell time options is enabled
keylset wireless_group_a dwellTimeOption 1
#uniform time distribution option is selected
keylset wireless_group_a timeDistOption 2
#do distribute clients among AP
keylset wireless_group_a clientDistOption 2
keylset wireless_group_a learningFlowFlag 1
keylset wireless_group_a learningPacketRate 100
keylset wireless_group_a learningPacketCount 10
keylset wireless_group_a learningPacketSize 256
keylset wireless_group_a flowPacketSize 256
keylset wireless_group_a flowRate 100
# durationUnits 0 = seconds, 1 = minutes, 2=hours
keylset wireless_group_a durationUnits 0
keylset wireless_group_a repeatValue 60
# repeatType 1 = repeat cycles, 2 = time duration
keylset wireless_group_a repeatType 2



keylset wireless_group_g AuxDut $my_roam_dut1
keylset wireless_group_g learningFlowFlag 1
keylset wireless_group_g learningPacketCount  10
keylset wireless_group_g learningPacketRate 100
keylset wireless_group_g learningPacketSize 256
keylset wireless_group_g flowPacketSize 256
keylset wireless_group_g flowRate 100
#Select dwell time to be 20 sec
#keylset wireless_group_g dwellTime 20
#dwell time options is enabled  
keylset wireless_group_g dwellTimeOption 1
#uniform time distribution option is selected
keylset wireless_group_g timeDistOption 2
#do distribute clients among AP
keylset wireless_group_g clientDistOption 2
keylset wireless_group_g learningFlowFlag 1
keylset wireless_group_g learningPacketRate 100
keylset wireless_group_g learningPacketCount 10
keylset wireless_group_g learningPacketSize 256
keylset wireless_group_g flowPacketSize 256
keylset wireless_group_g flowRate 100
# durationUnits 0 = seconds, 1 = minutes, 2=hours
keylset wireless_group_g durationUnits 0
keylset wireless_group_g repeatValue 600
# repeatType 1 = repeat cycles, 2 = time duration
keylset wireless_group_g repeatType 2

# The following groups are used in multissid roaming tests. 
set wireless_group_a2 $wireless_group_a
keylset wireless_group_a2 Ssid veriwave_roam
keylset wireless_group_a2 BaseIp 192.168.1.200

set wireless_group_g2 $wireless_group_g
keylset wireless_group_g2 Ssid veriwave_roam
keylset wireless_group_g2 BaseIp 192.168.1.200


#Set the P/F criteria
keylset wireless_group_a AcceptableRoamFailures $AcceptableRoamFailures
keylset wireless_group_a AcceptableRoamDelay $AcceptableRoamDelay

keylset wireless_group_g AcceptableRoamFailures $AcceptableRoamFailures
keylset wireless_group_g AcceptableRoamDelay $AcceptableRoamDelay

keylset wireless_group_a2 AcceptableRoamFailures $AcceptableRoamFailures
keylset wireless_group_a2 AcceptableRoamDelay $AcceptableRoamDelay

keylset wireless_group_g2 AcceptableRoamFailures $AcceptableRoamFailures
keylset wireless_group_g2 AcceptableRoamDelay $AcceptableRoamDelay

#Test Configuration
keylset roaming_delay Benchmark roaming_delay

keylset ether_group_1 AuxDut $my_roam_dut1




