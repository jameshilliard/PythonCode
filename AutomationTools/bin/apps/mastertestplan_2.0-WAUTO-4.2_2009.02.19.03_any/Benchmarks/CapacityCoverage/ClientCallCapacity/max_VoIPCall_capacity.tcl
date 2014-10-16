#VoIP call capacity script

keylset global_config TestList { qos_capacity }

#Test Configuration
# qos_capacity test specific information
# Either Source or Destination MUST be an ethernet group  

keylset qos_capacity Benchmark qos_capacity
keylset qos_capacity VoiceQoSEnabled False
#we use G.711, G.723 and G.729 codecs
keylset qos_capacity VoiceCodec { G.711 G.723 G.729 }
#keylset qos_capacity VoiceCodec { G.711 }
keylset qos_capacity VoiceSearchMin 1
keylset qos_capacity VoiceSearchMax 75 	


keylset qos_capacity VoiceUserPriority 7
keylset qos_capacity VoiceSrcPort 5003
keylset qos_capacity VoiceDestPort 5004
keylset qos_capacity SlaMinRValue 78.0
keylset qos_capacity SlaMaxPktLoss 1.0

#Use R-Value for QoS measurements
#Sla - Service Layer Agreement; decides max latency and max jitter allowed for pass/fail
keylset qos_capacity SlaMode R-Value
keylset qos_capacity SlaMaxLatency 30.0
keylset qos_capacity SlaMaxJitter 250.0
keylset qos_capacity BackgroundQoSEnabled False
# Per test procedure frame sizes. 
keylset qos_capacity BackgroundFrameSize { 88 128 256 512 1024 1518 }
# Frame sizes reduced for efficiency
keylset qos_capacity BackgroundFrameSize { 1518 }
# Per test procedure frame rates. 
keylset qos_capacity BackgroundFrameRate { 10 50 100 500 }
# Frame rates reduced for efficiency 
keylset qos_capacity BackgroundFrameRate { 10 }
keylset qos_capacity BackgroundType UDP
keylset qos_capacity BackgroundUserPriority 1
keylset qos_capacity BackgroundSrcPort 2000
keylset qos_capacity BackgroundDestPort 2000


#Define background traffic 
#The BssidIndex of the background_group has to match the BssidIndex of the normal groups definded.

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
keylset qos_capacity VoiceExpectedCallCapacity $VoiceExpectedCallCapacity