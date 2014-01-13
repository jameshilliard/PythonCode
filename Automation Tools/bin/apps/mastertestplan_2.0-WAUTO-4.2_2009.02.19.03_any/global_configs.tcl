# Global Configurations
# This is a global configurations file. The changes made here affect all the test scripts


keylset global_config TemplateVersion 2.4.1.0

#Please specify the chassis ip address
# CHANGE THIS TO THE ACTUAL CHASSIS ADDRESS
keylset global_config ChassisName 10.50.5.177
#keylset global_config ChassisName 192.168.1.1

#Please specify the Root directory for results
set LogsDirRoot [file join $env(VW_MTP_HOME) results ]
#keylset global_config LogsDir [file join $env(VW_MTP_HOME) results_linux ]

#Please put the License Key
# ADD THE ACTUAL LICENSE KEYS AS A LIST.
keylset global_config LicenseKey  xxxxx-xxxxx-xxxxx

# Turn on Pass/Fail criteria
keylset global_config PassFailUser True
# Set the desired criteria for various tests. Note, some tests
# have fixed values for the criteria. These values are set in the test specific
# setup files in the lower levels of the heirarchy.
# Set the the throughput, TCP goodput, and Maximum Forwarding Rate criteria
# as a percentage of theoretical maximum
set AcceptableThroughput 90
set AcceptableGoodput 75
set AcceptableForwardingRate 90
# Set the criteria for maximum acceptable latency (msecs) and average latency
set AcceptableMaxLatency 50.0
set AcceptableAvgLatency 2.0
# Set the criteria for expected number of client connections
set ExpectedClientConnections 10
#Set the criteria for accepted frame loss rate for packet loss in percentage
set AcceptableFrameLossRate 5
### One for Power levels and another for Corresponding forwarding rates
set RefPowerList {-6 -24 -42}
set RefRateList  {3.0 3.0 3.0}
#Set criteria for auth rate
set ExpectedAuthentications 1.0
# set the criteria for the expected background traffic rate without affecting call
# quality
set AcceptableBackgroundRate 2500
# Set the criteria for VOIP Qos Number of Voice calls.
set VoiceExpectedCallCapacity 50
#Set the criteria for roaming_delay  ,roaming_benchmark
set AcceptableRoamFailures 0
set AcceptableRoamDelay 700
#set the criteria for voip roaming
set AcceptableDroppedCalls  5
set AcceptableRValue  78

keylset global_config NumTrials 1
#keylset global_config TrialDuration 30
keylset global_config TrialDuration 3

keylset global_config LossTolerance 0.1
keylset global_config DataPhyRate 54
keylset global_config MgmtPhyRate 6

# Learning Parameters. 
keylset global_config FlowLearningTime 2
keylset global_config ClientLearningTime 2
keylset global_config SettleTime 2
keylset global_config AgingTime 2
keylset global_config ArpNumRetries 5
keylset global_config ArpRate 50
keylset global_config ArpTimeout 10

#DataBase Support to Log results into database
#If DbSupport is True enable the next 5 lines and provide the
#corresponding values for the database support else comment.

keylset global_config DbSupport False
keylset global_config DbType "mysql"
keylset global_config DbUserName "root"
keylset global_config DbName "mydb"
keylset global_config DbPassword "veriwave"
keylset global_config DbServerIP "localhost"
if { ![info exists env(MTP_TEST_MODE)] } {
    puts "Warning: Environment variable MTP_TEST_MODE not set.\n"
    #exit -1
}
# Override since may not be able to set
set mtpMode "REGRESSION"
# Use the following to define different test Parameters depending on the type of Testing
# This can be used to speed up testing, or make it more or less comprehensive.
switch -glob -- $mtpMode {
    "FULL" {
          set Channel { 1 6 11 }
          set A_Channel { 36 161 }
          set NumClients { 1 10 }
          set FrameSizeList { 64 128 256 512 1024 1280 1518 }
          set LatencyIloadList { 2000 1800 1600 1400 1200 1000 800 }
          set AssocProbe { unicast bdcst off }
          set MSSsegmentSize { 216 536 1460 }
          set MaxClientConnects { 50 }           
          set SecurityTypes { None WPA-PSK WPA2-PSK WPA-PEAP-MSCHAPv2 WPA2-PEAP-MSCHAPv2 WPA2-EAP-FAST }
          set RoamingSecurityTypes { None WPA-PSK WPA2-PSK WPA-PEAP-MSCHAPv2 WPA2-PEAP-MSCHAPv2 WPA2-EAP-FAST }
    }
    "REGRESSION" {
          set Channel { 6 }
          set A_Channel { 36 }
          set NumClients { 1 }
          set FrameSizeList { 64 512 1518 }
          set LatencyIloadList { 2000 1400 800 }
          set AssocProbe   { unicast  }
          set MSSsegmentSize { 1460 }      
          set MaxClientConnects { 20 }
          set SecurityTypes { None  }
          set RoamingSecurityTypes { None }

    }

}

#Specify the DUT hardware.
# DUT configuration can be defined in another TCL file. In the default case
# it is in the file hardware.tcl. 

set src_path [file join [pwd] hardware.tcl]
set my_dut dut1
set my_roam_dut1 roam_dut1

if {[catch {source $src_path} result]} {
    puts "Opening of $src_path failed: $result"
    exit -1
}
