
keylset qos_assurance FlowLearningTime 5
keylset qos_assurance ClientLearningTime 5
keylset qos_assurance SettleTime 5
keylset qos_assurance AgingTime 10
keylset qos_assurance ArpNumRetries 5
keylset qos_assurance ArpRate 50
keylset qos_assurance ArpTimeout 10



#Test Configuration of VoIP SLA Requirement Test with  802.11a clients


keylset global_config TestList { qos_assurance }



#Test Configuration
keylset qos_assurance Benchmark qos_assurance

#Three types of codecs G.711, G.723 and G.729 are used
keylset qos_assurance VoiceCodec { G.711 G.723 G.729 }
keylset qos_assurance VoiceCodec { G.711  }

#Number of Voice calls per test
keylset qos_assurance VoiceNumberOfCalls { 1 10  }
keylset qos_assurance VoiceQoSEnabled False
keylset qos_assurance VoiceUserPriority 7
keylset qos_assurance VoiceTosField Default
keylset qos_assurance VoiceTosReserved False
keylset qos_assurance VoiceTosDiffservDscp Default
keylset qos_assurance VoiceTosLowCost False
keylset qos_assurance VoiceTosLowDelay False
keylset qos_assurance VoiceTosHighThroughput False
keylset qos_assurance VoiceTosHighReliability False
keylset qos_assurance VoiceSearchMax 50
keylset qos_assurance VoiceSearchMin 1
keylset qos_assurance VoiceSsrcPort 5003
keylset qos_assurance VoiceDestPort 5004
keylset qos_assurance SlaMinRValue 78.0
keylset qos_assurance SlaMaxPktLoss 1.0

#R-value is used for QoS calculations
keylset qos_assurance SlaMode R-Value
keylset qos_assurance SlaMaxLatency 30.0
keylset qos_assurance SlaMaxJitter 250.0
keylset qos_assurance BackgroundQoSEnabled False
keylset qos_assurance BackgroundFrameRate 100
# Per test procedure frame sizes. 
keylset qos_assurance BackgroundFrameSize { 88 128 256 512 1024 1518 }
# Frame sizes reduced for efficiency
keylset qos_assurance BackgroundFrameSize { 1518 }
keylset qos_assurance BackgroundMaxFrameRate Default
keylset qos_assurance BackgroundMinFrameRate Default
keylset qos_assurance BackgroundSearchResolution 0.1
keylset qos_assurance BackgroundSearchStep 10
keylset qos_assurance BackgroundSearchMode Binary
keylset qos_assurance BackgroundType UDP
keylset qos_assurance BackgroundUserPriority 1
keylset qos_assurance BackgroundTosField Default
keylset qos_assurance BackgroundTosReserved False
keylset qos_assurance BackgroundTosDiffservDscp Default
keylset qos_assurance BackgroundTosLowCost False
keylset qos_assurance BackgroundTosLowDelay False
keylset qos_assurance BackgroundTosHighThroughput False
keylset qos_assurance BackgroundTosHighReliability False
keylset qos_assurance BackgroundSrcPort 22000
keylset qos_assurance BackgroundDestPort 22000
keylset qos_assurance BackgroundDirection Bidirectional



#create background traffic groups

# Wireless_background Configuration
set wireless_backgrnd_a $wireless_group_a
set wireless_backgrnd_g $wireless_group_g
# Make changes specific to the Background clients here
keylset wireless_backgrnd_a TrafficClass Background
keylset wireless_backgrnd_a BaseIP 192.168.1.120

keylset wireless_backgrnd_g TrafficClass Background
keylset wireless_backgrnd_g BaseIP 192.168.1.120

# Ether_voice Configuration

# Ether_background Configuration
set ether_backgrnd $ether_group_1
keylset ether_backgrnd TrafficClass Background
keylset ether_backgrnd BaseIp 192.168.1.2


#Set the P/F criteria
keylset qos_assurance BackgroundAcceptableBackgroundRate $AcceptableBackgroundRate





