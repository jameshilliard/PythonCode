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
        test_wimix_traffic
        test_wimix_client
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

# wimix global arguments
keylset global_config wimixResultSampleVal 10
keylset global_config wimixResultSampleOption 0
keylset global_config SettleTime 2
keylset global_config LossTolerance 0
keylset global_config RandomSeed 1186422843
keylset global_config overTimeGraphs 0
keylset global_config wimixResultOption 0

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

if {[catch {source [file join $env(HOME) hardware.tcl]}]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}
if {![info exists dut1] || ![info exists dut2]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}

# find the ethernet port of dut1 for the wimix servers
set dut1_int_list [vw_keylget dut1 Interface]
foreach dut1_int [keylkeys dut1_int_list] {
    set dut1_int_cfg [vw_keylget dut1_int_list $dut1_int]
    if {[catch {set dut1_int_type [vw_keylget dut1_int_cfg InterfaceType]}]} {
        puts "Error: No InterfaceType defined in dut1"
        exit -1
    }
    if { $dut1_int_type == "802.3" } {
        set dut1_eth_port [vw_keylget dut1_int_cfg WavetestPort]
        break
    }
}

#Group HomeLaptop
keylset HomeLaptop GroupType 802.11abg
keylset HomeLaptop Dut {dut1}
keylset HomeLaptop Ssid $test_ssid

#Group HomeLaptop - Client Options
keylset HomeLaptop GratuitousArp True
keylset HomeLaptop Dhcp Enable
keylset HomeLaptop Qos Disable
keylset HomeLaptop Uapsd 0
keylset HomeLaptop ListenInt 1
keylset HomeLaptop MgmtRetries 11
keylset HomeLaptop DataRetries 11
keylset HomeLaptop phyInterface 802.11ag
keylset HomeLaptop Wlan80211eQoSAC 0
keylset HomeLaptop BaseIp 192.168.1.12
keylset HomeLaptop Gateway 192.168.1.1
keylset HomeLaptop MacAddress None

#Group HomeLaptop - Security Options
keylset HomeLaptop Method {None}

#Group VideoCamera
keylset VideoCamera GroupType 802.11abg
keylset VideoCamera Dut {dut1}
keylset VideoCamera Ssid $test_ssid

#Group VideoCamera - Client Options
keylset VideoCamera GratuitousArp True
keylset VideoCamera Dhcp Enable
keylset VideoCamera Hops 0
keylset VideoCamera Qos Disable
keylset VideoCamera Uapsd 0
keylset VideoCamera CtsToSelf 0
keylset VideoCamera TransmitDeference 0
keylset VideoCamera MgmtRetries 0
keylset VideoCamera DataRetries 0
keylset VideoCamera CwMin 0
keylset VideoCamera CwMax 0
keylset VideoCamera phyInterface 802.11ag
keylset VideoCamera BaseIp 192.168.1.11
keylset VideoCamera Gateway 192.168.1.1
keylset VideoCamera MacAddress None

#Group VideoCamera - Security Options
keylset VideoCamera Method {None}

#Group WirelessTv
keylset WirelessTv GroupType 802.11abg
keylset WirelessTv Dut {dut1}
keylset WirelessTv Ssid $test_ssid

#Group WirelessTv - Client Options
keylset WirelessTv GratuitousArp True
keylset WirelessTv Dhcp Enable
keylset WirelessTv Hops 2
keylset WirelessTv Qos Disable
keylset WirelessTv Uapsd 0
keylset WirelessTv CtsToSelf 0
keylset WirelessTv TransmitDeference 0
keylset WirelessTv MgmtRetries 0
keylset WirelessTv DataRetries 0
keylset WirelessTv CwMin 0
keylset WirelessTv CwMax 0
keylset WirelessTv phyInterface 802.11ag
keylset WirelessTv BaseIp 192.168.1.13
keylset WirelessTv Gateway 192.168.1.1
keylset WirelessTv MacAddress None

#Group WirelessTv - Security Options
keylset WirelessTv Method {None}

#Group WorkLaptop
keylset WorkLaptop GroupType 802.11abg
keylset WorkLaptop Dut {dut1}
keylset WorkLaptop Ssid $test_ssid

#Group WorkLaptop - Client Options
keylset WorkLaptop GratuitousArp True
keylset WorkLaptop Dhcp Enable
keylset WorkLaptop Hops -1
keylset WorkLaptop Qos Disable
keylset WorkLaptop Uapsd 0
keylset WorkLaptop CtsToSelf 0
keylset WorkLaptop TransmitDeference 0
keylset WorkLaptop MgmtRetries 0
keylset WorkLaptop DataRetries 0
keylset WorkLaptop CwMin 0
keylset WorkLaptop CwMax 0
keylset WorkLaptop phyInterface 802.11ag
keylset WorkLaptop BaseIp 192.168.1.10
keylset WorkLaptop Gateway 192.168.1.1
keylset WorkLaptop MacAddress None

#Group WorkLaptop - Security Options
keylset WorkLaptop Method {None}

#Group iDevice
keylset iDevice GroupType 802.11abg
keylset iDevice Dut {dut1}
keylset iDevice Ssid $test_ssid

#Group iDevice - Client Options
keylset iDevice GratuitousArp True
keylset iDevice Dhcp Enable
keylset iDevice Hops 3
keylset iDevice Qos Disable
keylset iDevice Uapsd 0
keylset iDevice CtsToSelf 0
keylset iDevice TransmitDeference 0
keylset iDevice MgmtRetries 0
keylset iDevice DataRetries 0
keylset iDevice CwMin 0
keylset iDevice CwMax 0
keylset iDevice phyInterface 802.11ag
keylset iDevice BaseIp 192.168.1.14
keylset iDevice Gateway 192.168.1.1
keylset iDevice MacAddress None

#Group iDevice - Security Options
keylset iDevice Method {None}

#Wimix Test Settings
keylset test_wimix_client Test wimix_script
keylset test_wimix_client wimixMode Client
keylset test_wimix_client testProfile Residential
keylset test_wimix_client testProfileImage images/wimix_residential.png
keylset test_wimix_client staggerStartInt 1
keylset test_wimix_client staggerStart 0
keylset test_wimix_client totalClientPer 100
keylset test_wimix_client loadVal 5
keylset test_wimix_client totalLoadPer 100
keylset test_wimix_client loadMode 0
keylset test_wimix_client loadSweepEnd 20
keylset test_wimix_client loadSweepStart 10
keylset test_wimix_client loadSweepStep 1
keylset test_wimix_client continueFlag 0
keylset test_wimix_client ClientMix.WirelessTv.TrafficType {VideoStreaming}
keylset test_wimix_client ClientMix.WirelessTv.Percentage 20
keylset test_wimix_client ClientMix.HomeLaptop.TrafficType {InternetRadio InternetVoice PersonalEmail WebBrowsing}
keylset test_wimix_client ClientMix.HomeLaptop.Percentage 20
keylset test_wimix_client ClientMix.iDevice.TrafficType {InternetVideo WebBrowsing}
keylset test_wimix_client ClientMix.iDevice.Percentage 20
keylset test_wimix_client ClientMix.WorkLaptop.TrafficType {WorkEmail WebBrowsing FileDownloads FileUploads}
keylset test_wimix_client ClientMix.WorkLaptop.Percentage 20
keylset test_wimix_client ClientMix.VideoCamera.TrafficType {VideoSurveillance}
keylset test_wimix_client ClientMix.VideoCamera.Percentage 20
#keylset global_config Source {WirelessTv}
#keylset global_config Destination {HomeLaptop iDevice WorkLaptop VideoCamera}

#Wimix Traffic Profiles
keylset FileDownloads WimixtrafficDirection downlink
keylset FileDownloads WimixtrafficIntendedrate 50
keylset FileDownloads WimixtrafficFramesize 1500
keylset FileDownloads WimixtrafficRateMode 1
keylset FileDownloads WimixtrafficServer MediaServer
keylset FileDownloads WimixtrafficipProtocolNum Auto
keylset FileDownloads WimixtrafficPhyrate 54
keylset FileDownloads WimixtrafficType FTP
keylset FileDownloads Layer4to7UserName anonymous
keylset FileDownloads Layer4to7SrcPort 21863
keylset FileDownloads Layer4to7FileName home.txt
keylset FileDownloads Layer4to7FileSize 10
keylset FileDownloads Layer4to7Operation "ftp get"
keylset FileDownloads Layer4to7Password anonymous
keylset FileDownloads Layer4to7DestPort 31863
keylset FileDownloads Layer3qosenable 0
keylset FileDownloads Layer3qosdscp 0
keylset FileDownloads Layer2qoswlanUp 0
keylset FileDownloads Layer2qosenable 0
keylset FileDownloads Layer2qosethUp 0
keylset FileDownloads SlaperLoad 50

keylset VideoStreaming WimixtrafficDirection downlink
keylset VideoStreaming WimixtrafficIntendedrate 100
keylset VideoStreaming WimixtrafficFramesize 1500
keylset VideoStreaming WimixtrafficRateMode 1
keylset VideoStreaming WimixtrafficServer MediaServer
keylset VideoStreaming WimixtrafficipProtocolNum Auto
keylset VideoStreaming WimixtrafficPhyrate 54
keylset VideoStreaming WimixtrafficType MPEG2
keylset VideoStreaming Layer4to7SrcPort 22291
keylset VideoStreaming Layer4to7DestPort 32291
keylset VideoStreaming Layer3qosenable 0
keylset VideoStreaming Layer3qosdscp 0
keylset VideoStreaming Layer2qoswlanUp 0
keylset VideoStreaming Layer2qosenable 0
keylset VideoStreaming Layer2qosethUp 0
keylset VideoStreaming SlaDf 50
keylset VideoStreaming SlaMlr 1

keylset FileUploads WimixtrafficDirection uplink
keylset FileUploads WimixtrafficIntendedrate 20
keylset FileUploads WimixtrafficFramesize 1500
keylset FileUploads WimixtrafficRateMode 1
keylset FileUploads WimixtrafficServer Internet
keylset FileUploads WimixtrafficipProtocolNum Auto
keylset FileUploads WimixtrafficPhyrate 54
keylset FileUploads WimixtrafficType FTP
keylset FileUploads Layer4to7UserName anonymous
keylset FileUploads Layer4to7SrcPort 22786
keylset FileUploads Layer4to7FileName home.txt
keylset FileUploads Layer4to7FileSize 10
keylset FileUploads Layer4to7Operation "ftp put"
keylset FileUploads Layer4to7Password anonymous
keylset FileUploads Layer4to7DestPort 32786
keylset FileUploads Layer3qosenable 0
keylset FileUploads Layer3qosdscp 0
keylset FileUploads Layer2qoswlanUp 0
keylset FileUploads Layer2qosenable 0
keylset FileUploads Layer2qosethUp 0
keylset FileUploads SlaperLoad 50

keylset WebBrowsing WimixtrafficDirection downlink
keylset WebBrowsing WimixtrafficIntendedrate 10
keylset WebBrowsing WimixtrafficFramesize 470
keylset WebBrowsing WimixtrafficRateMode 1
keylset WebBrowsing WimixtrafficServer Internet
keylset WebBrowsing WimixtrafficipProtocolNum Auto
keylset WebBrowsing WimixtrafficPhyrate 54
keylset WebBrowsing WimixtrafficType HTTP
keylset WebBrowsing Layer4to7Operation "http get"
keylset WebBrowsing Layer4to7SrcPort 21163
keylset WebBrowsing Layer4to7DestPort 31163
keylset WebBrowsing Layer3qosenable 0
keylset WebBrowsing Layer3qosdscp 0
keylset WebBrowsing Layer2qoswlanUp 0
keylset WebBrowsing Layer2qosenable 0
keylset WebBrowsing Layer2qosethUp 0
keylset WebBrowsing SlaperLoad 50

keylset VideoSurveillance WimixtrafficDirection uplink
keylset VideoSurveillance WimixtrafficIntendedrate 100
keylset VideoSurveillance WimixtrafficFramesize 1500
keylset VideoSurveillance WimixtrafficRateMode 1
keylset VideoSurveillance WimixtrafficServer MediaServer
keylset VideoSurveillance WimixtrafficipProtocolNum Auto
keylset VideoSurveillance WimixtrafficPhyrate 54
keylset VideoSurveillance WimixtrafficType MPEG2
keylset VideoSurveillance Layer4to7SrcPort 23556
keylset VideoSurveillance Layer4to7DestPort 33556
keylset VideoSurveillance Layer3qosenable 0
keylset VideoSurveillance Layer3qosdscp 0
keylset VideoSurveillance Layer2qoswlanUp 0
keylset VideoSurveillance Layer2qosenable 0
keylset VideoSurveillance Layer2qosethUp 0
keylset VideoSurveillance SlaDf 50
keylset VideoSurveillance SlaMlr 1

keylset InternetVideo WimixtrafficDirection downlink
keylset InternetVideo WimixtrafficIntendedrate 100
keylset InternetVideo WimixtrafficFramesize 1500
keylset InternetVideo WimixtrafficRateMode 1
keylset InternetVideo WimixtrafficServer Internet
keylset InternetVideo WimixtrafficipProtocolNum Auto
keylset InternetVideo WimixtrafficPhyrate 54
keylset InternetVideo WimixtrafficType UDP
keylset InternetVideo Layer4to7SrcPort 20674
keylset InternetVideo Layer4to7DestPort 30674
keylset InternetVideo Layer3qosenable 0
keylset InternetVideo Layer3qosdscp 0
keylset InternetVideo Layer2qoswlanUp 0
keylset InternetVideo Layer2qosenable 0
keylset InternetVideo Layer2qosethUp 0
keylset InternetVideo SlaLatency 10000
keylset InternetVideo SlaJitter 500
keylset InternetVideo SlaPacketLoss 10

keylset PersonalEmail WimixtrafficDirection downlink
keylset PersonalEmail WimixtrafficIntendedrate 10
keylset PersonalEmail WimixtrafficFramesize 1500
keylset PersonalEmail WimixtrafficRateMode 1
keylset PersonalEmail WimixtrafficServer Internet
keylset PersonalEmail WimixtrafficipProtocolNum Auto
keylset PersonalEmail WimixtrafficPhyrate 54
keylset PersonalEmail WimixtrafficType HTTP
keylset PersonalEmail Layer4to7Operation "http get"
keylset PersonalEmail Layer4to7SrcPort 21508
keylset PersonalEmail Layer4to7DestPort 31508
keylset PersonalEmail Layer3qosenable 0
keylset PersonalEmail Layer3qosdscp 0
keylset PersonalEmail Layer2qoswlanUp 0
keylset PersonalEmail Layer2qosenable 0
keylset PersonalEmail Layer2qosethUp 0
keylset PersonalEmail SlaperLoad 50

keylset InternetVoice WimixtrafficsipSignaling 1
keylset InternetVoice WimixtrafficDirection bidirectional
keylset InternetVoice WimixtrafficIntendedrate 50
keylset InternetVoice WimixtrafficFramesize 236
keylset InternetVoice WimixtrafficRateMode 1
keylset InternetVoice WimixtrafficServer Internet
keylset InternetVoice WimixtrafficipProtocolNum Auto
keylset InternetVoice WimixtrafficPhyrate 54
keylset InternetVoice WimixtrafficType VOIPG711
keylset InternetVoice Layer4to7SrcPort 24069
keylset InternetVoice Layer4to7DestPort 34069
keylset InternetVoice Layer3qosenable 0
keylset InternetVoice Layer3qosdscp 0
keylset InternetVoice Layer2qoswlanUp 0
keylset InternetVoice Layer2qosenable 0
keylset InternetVoice Layer2qosethUp 0
keylset InternetVoice SlaslaMode 0
keylset InternetVoice Slavalue 78

keylset InternetRadio WimixtrafficDirection downlink
keylset InternetRadio WimixtrafficIntendedrate 50
keylset InternetRadio WimixtrafficFramesize 256
keylset InternetRadio WimixtrafficRateMode 1
keylset InternetRadio WimixtrafficServer Internet
keylset InternetRadio WimixtrafficipProtocolNum Auto
keylset InternetRadio WimixtrafficPhyrate 54
keylset InternetRadio WimixtrafficType RTP
keylset InternetRadio Layer4to7SrcPort 21794
keylset InternetRadio Layer4to7DestPort 31794
keylset InternetRadio Layer3qosenable 0
keylset InternetRadio Layer3qosdscp 0
keylset InternetRadio Layer2qoswlanUp 0
keylset InternetRadio Layer2qosenable 0
keylset InternetRadio Layer2qosethUp 0
keylset InternetRadio SlaLatency 10000
keylset InternetRadio SlaJitter 500
keylset InternetRadio SlaPacketLoss 10

keylset WorkEmail WimixtrafficDirection downlink
keylset WorkEmail WimixtrafficIntendedrate 10
keylset WorkEmail WimixtrafficFramesize 300
keylset WorkEmail WimixtrafficRateMode 1
keylset WorkEmail WimixtrafficServer Internet
keylset WorkEmail WimixtrafficipProtocolNum Auto
keylset WorkEmail WimixtrafficPhyrate 54
keylset WorkEmail WimixtrafficType TCP
keylset WorkEmail Layer4to7SrcPort 21155
keylset WorkEmail Layer4to7DestPort 31155
keylset WorkEmail Layer3qosenable 0
keylset WorkEmail Layer3qosdscp 0
keylset WorkEmail Layer2qoswlanUp 0
keylset WorkEmail Layer2qosenable 0
keylset WorkEmail Layer2qosethUp 0
keylset WorkEmail SlaperLoad 50

#Wimix Server Profiles
keylset MediaServer WimixservermacAddress 00:01:02:5F:45:1B
keylset MediaServer WimixserverethPort $dut1_eth_port
keylset MediaServer WimixserveripMode 0
keylset MediaServer Wimixservernetmask 255.255.255.0
keylset MediaServer WimixservermacMode 1
keylset MediaServer WimixserveripAddress 192.168.1.201
keylset MediaServer Wimixservergateway 192.168.1.1
keylset MediaServer Vlanenable 0
keylset MediaServer Vlanid 0

keylset Internet WimixservermacAddress 00:01:02:BD:1C:B2
keylset Internet WimixserverethPort $dut1_eth_port
keylset Internet WimixserveripMode 0
keylset Internet Wimixservernetmask 255.255.255.0
keylset Internet WimixservermacMode 1
keylset Internet WimixserveripAddress 192.168.1.202
keylset Internet Wimixservergateway 192.168.1.1
keylset Internet Vlanenable 0
keylset Internet Vlanid 0

# wimix traffic test
#Group Handset
keylset Handset GroupType 802.11abg
keylset Handset Dut {dut1}

#Group Handset - Client Options
keylset Handset GratuitousArp True
keylset Handset Dhcp Enable
keylset Handset Qos Disable
keylset Handset Uapsd 0
keylset Handset ListenInt 1
keylset Handset phyInterface 802.11ag
keylset Handset Wlan80211eQoSAC 0
keylset Handset SubnetMask 255.255.0.0
keylset Handset BaseIp 192.168.3.10
keylset Handset Gateway 192.168.1.1
keylset Handset MacAddress None

#Group Handset - Security Options
keylset Handset Method {None}

#Group Laptop
keylset Laptop GroupType 802.11abg
keylset Laptop Dut {dut1}

#Group Laptop - Client Options
keylset Laptop GratuitousArp True
keylset Laptop Dhcp Enable
keylset Laptop Hops -1
keylset Laptop Qos Disable
keylset Laptop Uapsd 0
keylset Laptop CtsToSelf 0
keylset Laptop TransmitDeference 0
keylset Laptop MgmtRetries 0
keylset Laptop DataRetries 0
keylset Laptop CwMin 0
keylset Laptop CwMax 0
keylset Laptop phyInterface 802.11ag
keylset Laptop VlanEnable True
keylset Laptop Wlan80211eQoSEnable True
keylset Laptop SubnetMask 255.255.0.0
keylset Laptop BaseIp 192.168.1.10
keylset Laptop Gateway 192.168.1.1
keylset Laptop MacAddress None

#Group Laptop - Security Options
keylset Laptop Method {None}

#Group PDA
keylset PDA GroupType 802.11abg
keylset PDA Dut {dut1}

#Group PDA - Client Options
keylset PDA GratuitousArp True
keylset PDA Dhcp Enable
keylset PDA Hops 0
keylset PDA Qos Disable
keylset PDA Uapsd 0
keylset PDA CtsToSelf 0
keylset PDA TransmitDeference 0
keylset PDA MgmtRetries 0
keylset PDA DataRetries 0
keylset PDA CwMin 0
keylset PDA CwMax 0
keylset PDA phyInterface 802.11ag
keylset PDA SubnetMask 255.255.0.0
keylset PDA BaseIp 192.168.2.10
keylset PDA Gateway 192.168.1.1
keylset PDA MacAddress None

#Group PDA - Security Options
keylset PDA Method {None}

#Group POSTerminal
keylset POSTerminal GroupType 802.11abg
keylset POSTerminal Dut {dut1}

#Group POSTerminal - Client Options
keylset POSTerminal GratuitousArp True
keylset POSTerminal Dhcp Enable
keylset POSTerminal Qos Disable
keylset POSTerminal Uapsd 0
keylset POSTerminal CtsToSelf 0
keylset POSTerminal TransmitDeference 0
keylset POSTerminal MgmtRetries 0
keylset POSTerminal DataRetries 0
keylset POSTerminal CwMin 0
keylset POSTerminal CwMax 0
keylset POSTerminal phyInterface 802.11ag
keylset POSTerminal SubnetMask 255.255.0.0
keylset POSTerminal BaseIp 192.168.4.10
keylset POSTerminal Gateway 192.168.1.1
keylset POSTerminal MacAddress None

#Group POSTerminal - Security Options
keylset POSTerminal Method {None}

#Group Scanner
keylset Scanner GroupType 802.11abg
keylset Scanner Dut {dut1}

#Group Scanner - Client Options
keylset Scanner GratuitousArp True
keylset Scanner Dhcp Enable
keylset Scanner Hops 2
keylset Scanner Qos Disable
keylset Scanner Uapsd 0
keylset Scanner CtsToSelf 0
keylset Scanner TransmitDeference 0
keylset Scanner MgmtRetries 0
keylset Scanner DataRetries 0
keylset Scanner CwMin 0
keylset Scanner CwMax 0
keylset Scanner phyInterface 802.11ag
keylset Scanner SubnetMask 255.255.0.0
keylset Scanner BaseIp 192.168.5.10
keylset Scanner Gateway 192.168.1.1
keylset Scanner MacAddress None

#Group Scanner - Security Options
keylset Scanner Method {None}

#Group VideoCamera
keylset VideoCamera GroupType 802.11abg
keylset VideoCamera Dut {dut1}

#Group VideoCamera - Client Options
keylset VideoCamera GratuitousArp True
keylset VideoCamera Dhcp Enable
keylset VideoCamera Hops 3
keylset VideoCamera Qos Disable
keylset VideoCamera Uapsd 0
keylset VideoCamera CtsToSelf 0
keylset VideoCamera TransmitDeference 0
keylset VideoCamera MgmtRetries 0
keylset VideoCamera DataRetries 0
keylset VideoCamera CwMin 0
keylset VideoCamera CwMax 0
keylset VideoCamera phyInterface 802.11ag
keylset VideoCamera SubnetMask 255.255.0.0
keylset VideoCamera BaseIp 192.168.6.10
keylset VideoCamera Gateway 192.168.1.1
keylset VideoCamera MacAddress None

#Group VideoCamera - Security Options
keylset VideoCamera Method {None}

#Wimix Test Settings
keylset test_wimix_traffic Test wimix_script
keylset test_wimix_traffic wimixMode Traffic
keylset test_wimix_traffic testProfile Retail
keylset test_wimix_traffic testProfileImage images/wimix_retail.png
keylset test_wimix_traffic staggerStart 0
keylset test_wimix_traffic staggerStartInt 1
keylset test_wimix_traffic loadVal 8000
keylset test_wimix_traffic totalLoadPer 100.0
keylset test_wimix_traffic loadSweepStart 1000
keylset test_wimix_traffic loadMode 0
keylset test_wimix_traffic continueFlag 0
keylset test_wimix_traffic loadSweepEnd 30000
keylset test_wimix_traffic totalTrafficPer 100.0
keylset test_wimix_traffic loadSweepStep 5000
keylset test_wimix_traffic TrafficMix.VOIPG711.ClientType {Handset}
keylset test_wimix_traffic TrafficMix.VOIPG711.Percentage 10.0
keylset test_wimix_traffic TrafficMix.HttpGet.ClientType {Laptop}
keylset test_wimix_traffic TrafficMix.HttpGet.Percentage 5.0
keylset test_wimix_traffic TrafficMix.HttpPost.ClientType {Laptop}
keylset test_wimix_traffic TrafficMix.HttpPost.Percentage 5.0
keylset test_wimix_traffic TrafficMix.FtpGet.ClientType {Laptop}
keylset test_wimix_traffic TrafficMix.FtpGet.Percentage 10.0
keylset test_wimix_traffic TrafficMix.SMTP.ClientType {PDA}
keylset test_wimix_traffic TrafficMix.SMTP.Percentage 5.0
keylset test_wimix_traffic TrafficMix.UnclassifiedTcp.ClientType {POSTerminal}
keylset test_wimix_traffic TrafficMix.UnclassifiedTcp.Percentage 15.0
keylset test_wimix_traffic TrafficMix.Mpeg-2Video.ClientType {VideoCamera}
keylset test_wimix_traffic TrafficMix.Mpeg-2Video.Percentage 40.0
keylset test_wimix_traffic TrafficMix.BarcodeApp.ClientType {Scanner}
keylset test_wimix_traffic TrafficMix.BarcodeApp.Percentage 10.0

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
keylset FtpGet Layer4to7DestPort 31000
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

keylset VOIPG711 WimixtrafficipProtocolNum Auto
keylset VOIPG711 WimixtrafficDirection bidirectional
keylset VOIPG711 WimixtrafficIntendedrate 50
keylset VOIPG711 WimixtrafficFramesize 236
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

keylset PatientMonitorInfo WimixtrafficDirection downlink
keylset PatientMonitorInfo WimixtrafficIntendedrate 10
keylset PatientMonitorInfo WimixtrafficFramesize 274
keylset PatientMonitorInfo WimixtrafficRateMode 1
keylset PatientMonitorInfo WimixtrafficServer DNSserver
keylset PatientMonitorInfo WimixtrafficipProtocolNum Auto
keylset PatientMonitorInfo WimixtrafficPhyrate 54
keylset PatientMonitorInfo WimixtrafficType TCP
keylset PatientMonitorInfo Layer4to7SrcPort 60009
keylset PatientMonitorInfo Layer4to7DestPort 70009
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
keylset HttpGet Layer4to7SrcPort 52000
keylset HttpGet Layer4to7DestPort 53000
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
keylset HttpPost Layer4to7SrcPort 54000
keylset HttpPost Layer4to7DestPort 55000
keylset HttpPost Layer3qosenable 0
keylset HttpPost Layer3qosdscp 0
keylset HttpPost Layer2qoswlanUp 0
keylset HttpPost Layer2qosenable 0
keylset HttpPost Layer2qosethUp 0
keylset HttpPost SlaperLoad 50

keylset HTTPserver WimixservermacAddress 00:11:22:33:cc:01
keylset HTTPserver WimixserverethPort $dut1_eth_port
keylset HTTPserver WimixserveripMode 0
keylset HTTPserver Wimixservernetmask 255.255.0.0
keylset HTTPserver WimixservermacMode 1
keylset HTTPserver WimixserveripAddress 192.168.3.200
keylset HTTPserver Wimixservergateway 192.168.1.1
keylset HTTPserver Vlanenable 0
keylset HTTPserver Vlanid 0

keylset DNSserver WimixservermacAddress 00:11:22:33:ff:03
keylset DNSserver WimixserverethPort $dut1_eth_port
keylset DNSserver WimixserveripMode 0
keylset DNSserver Wimixservernetmask 255.255.0.0
keylset DNSserver WimixservermacMode 1
keylset DNSserver WimixserveripAddress 192.168.8.200
keylset DNSserver Wimixservergateway 192.168.1.1
keylset DNSserver Vlanenable 0
keylset DNSserver Vlanid 0

keylset VIDEOserver WimixservermacAddress 00:11:22:33:ff:01
keylset VIDEOserver WimixserverethPort $dut1_eth_port
keylset VIDEOserver WimixserveripMode 0
keylset VIDEOserver Wimixservernetmask 255.255.0.0
keylset VIDEOserver WimixservermacMode 1
keylset VIDEOserver WimixserveripAddress 192.168.5.200
keylset VIDEOserver Wimixservergateway 192.168.1.1
keylset VIDEOserver Vlanenable 0
keylset VIDEOserver Vlanid 0

keylset FTPserver WimixservermacAddress 00:11:22:33:bb:01
keylset FTPserver WimixserverethPort $dut1_eth_port
keylset FTPserver WimixserveripMode 0
keylset FTPserver Wimixservernetmask 255.255.0.0
keylset FTPserver WimixservermacMode 1
keylset FTPserver WimixserveripAddress 192.168.2.200
keylset FTPserver Wimixservergateway 192.168.1.1
keylset FTPserver Vlanenable 0
keylset FTPserver Vlanid 0

keylset GPserver WimixservermacAddress 00:11:22:33:dd:01
keylset GPserver WimixserverethPort $dut1_eth_port
keylset GPserver WimixserveripMode 0
keylset GPserver Wimixservernetmask 255.255.0.0
keylset GPserver WimixservermacMode 1
keylset GPserver WimixserveripAddress 192.168.4.200
keylset GPserver Wimixservergateway 192.168.1.1
keylset GPserver Vlanenable 0
keylset GPserver Vlanid 0

keylset VOIPserver WimixservermacAddress 00:11:22:33:aa:01
keylset VOIPserver WimixserverethPort $dut1_eth_port
keylset VOIPserver WimixserveripMode 0
keylset VOIPserver Wimixservernetmask 255.255.0.0
keylset VOIPserver WimixservermacMode 1
keylset VOIPserver WimixserveripAddress 192.168.1.200
keylset VOIPserver Wimixservergateway 192.168.1.1
keylset VOIPserver Vlanenable 0
keylset VOIPserver Vlanid 0

keylset MULTICASTserver WimixservermacAddress 00:11:22:33:ff:01
keylset MULTICASTserver WimixserverethPort $dut1_eth_port
keylset MULTICASTserver WimixserveripMode 0
keylset MULTICASTserver Wimixservernetmask 255.255.0.0
keylset MULTICASTserver WimixservermacMode 1
keylset MULTICASTserver WimixserveripAddress 192.168.6.200
keylset MULTICASTserver Wimixservergateway 192.168.1.1
keylset MULTICASTserver Vlanenable 0
keylset MULTICASTserver Vlanid 0

keylset MAILserver WimixservermacAddress 00:11:22:33:ff:02
keylset MAILserver WimixserverethPort $dut1_eth_port
keylset MAILserver WimixserveripMode 0
keylset MAILserver Wimixservernetmask 255.255.0.0
keylset MAILserver WimixservermacMode 1
keylset MAILserver WimixserveripAddress 192.168.7.200
keylset MAILserver Wimixservergateway 192.168.1.1
keylset MAILserver Vlanenable 0
keylset MAILserver Vlanid 0

if {[catch {source [file join $env(HOME) hardware.tcl]}]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}
if {![info exists dut1] || ![info exists dut2]} {
  puts "Error: You need dut1 and dut2 definitions in ~/hardware.tcl"
  exit -1
}

