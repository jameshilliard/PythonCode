#keylset max_client_capacity FlowLearningTime 5
#keylset max_client_capacity ClientLearningTime 5
#keylset max_client_capacity SettleTime 5
#keylset max_client_capacity AgingTime 10
#keylset max_client_capacity ArpNumRetries 30
#keylset max_client_capacity ArpRate 20
#keylset max_client_capacity ArpTimeout 30


keylset global_config TestList { max_client_capacity }


# Please specify maximum number of clients/AP
# NOTE (USER_PARAM): THIS VALUE SHOULD BE ADJUSTED BY THE USER
# This will try to connect max 50 clients   ($ExpectedClientConnections)
keylset max_client_capacity MaxSearchValue $MaxClientConnects



#Test Configuration
#  unicast_max_client_capacity test specific information
#
keylset max_client_capacity Benchmark unicast_max_client_capacity
keylset max_client_capacity Frame Standard
keylset max_client_capacity FrameSizeList { 512 }
keylset max_client_capacity ILoadList { 10.0 }
keylset max_client_capacity ILoadMode Custom
keylset max_client_capacity SearchResolutionAbsolute 1
keylset max_client_capacity MinSearchValue 1



#In Maximum Client Capacity Test Always set Direction from Ethernet --> Wireless 

keylset global_config Direction { Unidirectional }
keylset global_config Source { ether_group_1 }
keylset global_config Destination { wireless_group_g }

# Set the P/F criteria
keylset max_client_capacity ExpectedClientConnections $ExpectedClientConnections

