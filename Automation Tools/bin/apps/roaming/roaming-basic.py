#Roaming
#
#Objective:
# Measure the time it takes the network to recovery when a client 
# switches APs.
#
#  EP1 <-> WP1 & WP2
#
import sys
import time
import WaveEngine
from vcl import *
from CommonFunctions import *
# Nonzero value if you want to single step through ever VCL command
WaveEngine.SingleStep(False)

#Test Paramters
MinimumTime   =   5
SettleTime    =   2
TXpacketRate  = 100
FrameSize     = 256
CSVfilename = 'Results_6.06_Roaming.csv'
num_of_clients = 2
roam_int = 2
totDuration = 12

#Single Ethernet client parameters
Port8023_Name       = 'EP1'
Port8023_IPaddress  = '192.168.6.160'
Port8023_Subnet     = '255.255.255.0'
Port8023_Gateway    = '192.168.6.110'
Port8023_ClientName = 'Client_8023'


ClientProfile = {}
dwell_time = roam_int * num_of_clients
num_roams = totDuration / dwell_time

base_ip = '192.168.6.'
start_ip_byte = 150
smask = '255.255.255.0'
gateway = '192.168.6.110'
port_list = ['WP1', 'WP2']
security_type = 'WPA2-EAP-TLS'

#Create a dict of ClientProfiles
for i in range(1, num_of_clients+1):
    key = 'Client00%d' % i
    roam_profile = []
    roam_profile.append((port_list[0], roam_int * i))
    for j in range(1, num_roams):
        roam_profile.append((port_list[j % len(port_list)] , dwell_time))
    value = (base_ip+str(start_ip_byte + i), smask, gateway, security_type, roam_profile)
    ClientProfile['Client00%d' % i] = value

#Security Paramters
SecurityList = {
#	  Name           security  apAuthMethod   keyMethod   networkAuthMethod encryptionMethod
     'NONE':         ( 'off',       'open',     'none',      'none'       ,   'none'),
     'WPA-PSK' :     ( 'on',	    'open' ,	' wpa',      'psk'        ,   'tkip' ), 
     'WPA-EAP-TLS' :  ( 'on',	    'open' ,    'wpa' ,      'eapTls'     ,   'tkip' ),
	 'WPA-PEAP'   :  ( 'on',        'open',     'wpa' ,      'peapMschapv2',  'tkip' ),
     'WPA-LEAP'   :  ( 'on',	    'open',	    'wpa' ,      'leap'       ,   'tkip' ),
     'WPA-EAP-FAST': ( 'on',	    'open',	    'wpa' ,      'eapFast'    ,   'tkip' ),
     'WPA-EAP-GTC':  ( 'on',	    'open',	    'wpa' ,      'eapTtlsGtc' ,   'tkip' ),
     'WPA2-PSK':     ( 'on',	    'open',	    'wpa2' ,     'psk'        ,   'ccmp' ),
     'WPA2-EAP-TLS': ( 'on',	    'open',	    'wpa2' ,     'eapTls'     ,   'ccmp' ),
     'WPA2-PEAP':    ( 'on',	    'open',	    'wpa2' ,     'peapMschapv2',  'ccmp' ),
     'WPA2-LEAP':    ( 'on',	    'open',	    'wpa2' ,     'leap'       ,   'ccmp' ),
     'WPA2-EAP-FAST':( 'on',	    'open',	    'wpa2' ,     'eapFast'    ,   'ccmp' ),
     'WPA2-EAP-GTC': ( 'on',	    'open',	    'wpa2' ,     'eapTtlsGtc' ,   'ccmp' ),
     'WEP40':        ( 'on',	    'open',	    'wepStatic' ,'none'       ,   'wep40'),
     'WEP40S':       ( 'on',	    'shared',	'wepStatic' ,'none'       ,   'wep40'),
     'WEP104':       ( 'on',	    'open',	    'wepStatic' ,'none'       ,   'wep104'),
     'WEP104S':      ( 'on',	    'shared',   'wepStatic' ,'none'       ,   'wep104'),
     'DWEP-EAP-TLS': ( 'on',	    'open',     'wepDynamic' ,'eapTls'    ,   'wep40' ),
     'DWEP-PEAP':    ( 'on',	    'open',     'wepDynamic' ,'peapMschapv2', 'wep40' ),
     'DWEP-EAP-GTC': ( 'on',	    'open',     'wepDynamic' ,'eapTtlsGtc',   'wep40' ),
	
	#### To suppport CCKM...currently not supported by TGA
     'CCKM-PSK-TKIP':( 'on',	    'open',     'cckm' ,     'psk'        ,   'tkip' ),
     'CCKM-EAP-TLS-TKIP':( 'on',    'open',     'cckm' ,     'eapTls'     ,   'tkip' ),
     'CCKM-PEAP-TKIP':( 'on',       'open',     'cckm' ,     'peapMschapv2',  'tkip' ),
     'CCKM-LEAP-TKIP':( 'on',       'open',     'cckm' ,     'leap'        ,  'tkip' ),
     'CCKM-EAP-FAST-TKIP':( 'on',   'open',     'cckm' ,     'eapFast'     ,  'tkip' ),
     'CCKM-EAP-GTC-TKIP':( 'on',    'open',     'cckm' ,     'eapTtlsGtc'  ,  'tkip' ),
     'CCKM-PSK-CCMP': ( 'on',       'open',     'cckm' ,     'psk'         ,  'ccmp' ),
     'CCKM-EAP-TLS-CCMP':( 'on',    'open',     'cckm' ,     'eapTls'      ,  'ccmp' ),
     'CCKM-PEAP-CCMP':( 'on',       'open',     'cckm' ,     'peapMschapv2',  'ccmp' ),
     'CCKM-LEAP-CCMP':( 'on',       'open',     'cckm' ,     'leap'        ,  'ccmp' ),
     'CCKM-EAP-FAST-CCMP':( 'on',   'open',     'cckm' ,     'eapFast'     ,  'ccmp' ),
     'CCKM-EAP-GTC-CCMP':( 'on',    'open',     'cckm' ,     'eapTtlsGtc'  ,  'ccmp' )
	
}
AccountList = [ ('anonymous', 'whatever'), ('anonymous', 'whatever') ]

#Other Timing pararmetes that may be changed
Flow_PhyRate      =  54
Client_PhyRate    =   6
BSSIDscanTimeout  =   5
AssociateRate     =  10
AssociateRetries  =   0
AssociateTimeout  =  10
LoopDelay_mS      = 100
DisplayPrecission =   3

############# Hardware defination ####################
#                 Name     Chassis      Cd Pt  Chan
CardLocation = { 'WP1': ( 'wt-tga-10-28', 2, 0, 6 ),
                 'WP2': ( 'wt-tga-10-28', 3, 0, 1 ),
                 'EP1': ( 'wt-tga-10-28', 1, 0, 'on', 100, 'full' ) }

########################## DO NOT MODIFY BELOW HERE ##########################
WaveEngine.OpenLogging()

################################## Subroutines ###############################
ErrorRoamTime = 3600000

# This is for the GUI guys that the script will ignore for now
def DummyUpdate(MessageString, ElapsedTime, Transmitting_Flag, PassedParameters):
    return True

##################################### Main ###################################
# Tell WaveEngine to send the output to the one found in CommonFunctions
WaveEngine.SetOutputStream(PrintToConsole)

# Build the cardlist
CardList = [ Port8023_Name ]
for Clientname in ClientProfile.keys():
    (IP, Subnet, Gateway, Security, RoamLocation) = ClientProfile[Clientname]
    (Location, Time) = RoamLocation[0]
    for (Location, Time) in RoamLocation:
        if Location not in CardList:
            CardList.append(Location)

if WaveEngine.ConnectPorts(CardList, CardLocation) < 0:
    WaveEngine.DisconnectAll()
    WaveEngine.CloseLogging()
    sys.exit(-1) 

#Print Version Number
WaveEngine.PrintVersionInfo()

#Fill in ClientList with the first BSSID found on each card
MyBSSIDs = WaveEngine.GetBSSIDdictonary(CardList, BSSIDscanTimeout)
if len(MyBSSIDs.keys()) != len(CardList):
    WaveEngine.GetLogFile(CardList)
    WaveEngine.DisconnectAll()
    WaveEngine.CloseLogging()
    sys.exit(-1)

# Build the ClientList and RoamSchedule tables
TransmitTime = MinimumTime
RoamSchedule = []
ClientList = []
for Clientname in ClientProfile.keys():
    StartRoamingTime = 0
    (IP, Subnet, Gateway, Security, RoamLocation) = ClientProfile[Clientname]
    (StartLocation, DwellTime) = RoamLocation[0]
    BSSIDList = [ MyBSSIDs[StartLocation][0] ]
    for (Location, DwellTime) in RoamLocation:
        if MyBSSIDs[Location][0] not in BSSIDList:
            BSSIDList.append(MyBSSIDs[Location][0])
        if StartRoamingTime > 0:
            RoamSchedule.append( (StartRoamingTime, Clientname, Location, MyBSSIDs[Location][0], ErrorRoamTime) )
        StartRoamingTime += DwellTime
    ClientList.append( (Clientname, StartLocation, BSSIDList, RandomMAC(), IP, Subnet, Gateway, (), Security, {}) )
    if StartRoamingTime > TransmitTime:
        TransmitTime = StartRoamingTime
# Now sort the roam list
RoamSchedule.sort()
WaveEngine.InsertTimelogMessage(RoamSchedule)

#Create ethernet the clients
Client8023 = WaveEngine.CreateClients([ (Port8023_ClientName, Port8023_Name, '000000000000', RandomMAC(), Port8023_IPaddress, Port8023_Subnet, Port8023_Gateway, (), '', {}) ] )


#Create wireless clients
ListofClient = WaveEngine.CreateClients(ClientList, {},  SecurityList, AccountList)
if len(ListofClient) < 1:
    WaveEngine.DisconnectAll()
    WaveEngine.CloseLogging()
    sys.exit(-1)

#Associate with the AP to make sure that we are not screwed up yet
TotalTimeout = len(ListofClient)/AssociateRate + AssociateTimeout
if WaveEngine.ConnectClients(ListofClient, AssociateRate, AssociateRetries, AssociateTimeout, TotalTimeout) < 0:
    WaveEngine.GetLogFile(CardList)
    WaveEngine.DisconnectAll()
    WaveEngine.CloseLogging()
    sys.exit(-1)

#Setup a bi-directional flow between the single Ethernet client to each of the wireless clients
FlowOptions = {'Type': 'IP', 'FrameSize': FrameSize, 'PhyRate': Flow_PhyRate, 'RateMode': 'pps', 'IntendedRate': TXpacketRate, 'NumFrames': WaveEngine.MAXtxFrames}
FlowList = WaveEngine.CreateFlows_Many2One(ListofClient, Client8023, False, FlowOptions)
WaveEngine.CreateFlowGroup(FlowList, "XmitGroup")

#Do the ARP exchange
if WaveEngine.ExchangeARP(FlowList, "XmitGroup") < 0:
    WaveEngine.GetLogFile(CardList)
    WaveEngine.DisconnectAll()
    WaveEngine.CloseLogging()
    sys.exit(-1)
    
roam_delay_list = []
roam_delay_client_name = []

#Do the Roaming now
PassedParameters = {}
WaveEngine.OutputstreamHDL("Starting to transmit %s byte frames at %s frames/sec for %s seconds\n" % (FrameSize, TXpacketRate, TransmitTime), WaveEngine.MSG_OK)
(TestPassed, roam_delay_client_name, roam_delay_list) = WaveEngine.RoamingIteration(CardList, RoamSchedule, Port8023_ClientName, TransmitTime, SettleTime, LoopDelay_mS/1000.0, "XmitGroup", DummyUpdate, PassedParameters)
WaveEngine.OutputstreamHDL("\n", WaveEngine.MSG_OK)

#Display results
WaveEngine.OutputstreamHDL("\n             --- Analysis ---\n", WaveEngine.MSG_OK)
ResultsForCSVfile = [ ('client_num','src_port','dest_port','start_time','end_time') ]    

NameList = ClientProfile.keys()
NameList.sort()
for Clientname in NameList:
    WaveEngine.OutputstreamHDL("Client: %s\n" % (Clientname), WaveEngine.MSG_OK)

    FlowNameUp   = "F_%s-->%s" % ( Clientname, Port8023_ClientName)
    FlowNameDown = "F_%s-->%s" % ( Port8023_ClientName, Clientname)
    (IP, Subnet, Gateway, Security, RoamLocation) = ClientProfile[Clientname]

    #Do the 80211 to 8023 first
    (Eth_latencyMin, Eth_latencyMax, Eth_latencyAvg) = WaveEngine.MeasurePort_Latency([Port8023_Name], TransmitTime)
    Eth_latencyMinText = Float2EngNotation(Eth_latencyMin, DisplayPrecission)
    Eth_latencyMaxText = Float2EngNotation(Eth_latencyMax, DisplayPrecission)
    Eth_latencyAvgText = Float2EngNotation(Eth_latencyAvg, DisplayPrecission)
    WaveEngine.VCLtest("flowStats.read('%s','%s')" % (Port8023_Name, FlowNameDown), globals()) 
    Eth_TXflow         = flowStats.txFlowFramesOk

    # print the uplink
    RoamListLength = len(RoamLocation)
    RoamListIndex  = 0
    PortName       = RoamLocation[0][0] 
    DwellTime      = 0.0
    for (EventTime, RoamClientName, ActivePort, TheBSSID, RoamTime) in RoamSchedule:
        if Clientname == RoamClientName:
            # Create data for roaming graph
            DwellTime = EventTime
            ResultsForCSVfile.append( (Clientname, PortName, ActivePort, DwellTime, DwellTime + RoamTime ) )
            PortName = ActivePort

    # print the donwlink now
    RoamListIndex  = 0
    for (StartLocation, Time) in RoamLocation:
        RoamListIndex += 1
        (AP_latencyMin, AP_latencyMax, AP_latencyAvg) = WaveEngine.MeasurePort_Latency([StartLocation], TransmitTime)
        AP_latencyMinText = Float2EngNotation(AP_latencyMin, DisplayPrecission)
        AP_latencyMaxText = Float2EngNotation(AP_latencyMax, DisplayPrecission)
        AP_latencyAvgText = Float2EngNotation(AP_latencyAvg, DisplayPrecission)
        WaveEngine.VCLtest("flowStats.read('%s','%s')" % (ActivePort, FlowNameDown), globals())
        AP_RXflow         = flowStats.rxFlowFramesOk

        if RoamListIndex == 1:
            WaveEngine.OutputstreamHDL("%8s           TX:%7ld" % (Port8023_Name, Eth_TXflow), WaveEngine.MSG_OK)
            if RoamListIndex == RoamListLength:
                WaveEngine.OutputstreamHDL(" -----> ", WaveEngine.MSG_OK)
            else:
                WaveEngine.OutputstreamHDL(" --+--> ", WaveEngine.MSG_OK)
        else:
            WaveEngine.OutputstreamHDL("%29s   +--> " % (' '), WaveEngine.MSG_OK)
        WaveEngine.OutputstreamHDL("%8s  RX:%9ld\n" % (StartLocation, AP_RXflow), WaveEngine.MSG_OK)
        WaveEngine.OutputstreamHDL("%29s" % (' '), WaveEngine.MSG_OK)
        if RoamListIndex == RoamListLength:
            WaveEngine.OutputstreamHDL("        ", WaveEngine.MSG_OK)
        else:
            WaveEngine.OutputstreamHDL("   |    ", WaveEngine.MSG_OK)
        WaveEngine.OutputstreamHDL("Latency min=%5sS max=%5sS avg=%5sS\n" % (AP_latencyMinText, AP_latencyMaxText, AP_latencyAvgText), WaveEngine.MSG_OK)    
    WaveEngine.OutputstreamHDL(" \n", WaveEngine.MSG_OK)

#Roam Stats
lost_pkts_per_client_list = []
lost_pkts_per_client_per_roam = []
roam_count_list = []
roam_delay_client_list = []

ClientNames = ClientProfile.keys()
ClientNames.sort()
FlowNames = FlowList.keys()
FlowNames.sort()

for i in range(len(ClientProfile)):
    clientname = ClientNames[i]
    #read twice - workaround for VPR - 2786
    WaveEngine.VCLtest("clientStats.read('%s')" % clientname, globals())
    WaveEngine.VCLtest("clientStats.read('%s')" % clientname, globals())
    roam_start = clientStats.txMcStartTime
    roam_end = clientStats.rxMcStartTime
    roam_delay = ((roam_end - roam_start)/1000000)
    if (roam_delay > 0) and (roam_delay < 500000):
        roam_delay_list.append(roam_delay)
    else:
        roam_delay_list.append("NR")
        WaveEngine.OutputstreamHDL("Warning:Invalid roam delay reported", WaveEngine.MSG_OK)

    roam_delay_client_name.append(clientname)
    roamlist = ClientProfile[clientname][4] # To get the [{port1, roam_delay1},..{port-n, roam_delay-n}] list
    flowname = FlowNames[i]
    WaveEngine.VCLtest("flowStats.read('%s', '%s')" % (Port8023_Name, flowname), globals())
    tx_flow_roam_end = flowStats.txFlowFramesOk
    WaveEngine.VCLtest("mc.read('%s')" % (clientname), globals())
    rx_pkts_per_client = 0
    client_port_list = []
    roam_count = len(roamlist) - 1
    roam_count_list.append(roam_count)
    for j in range(len(roamlist)):
        client_port_list.append(roamlist[j][0])
    
    def unique(listofval):
        values=[]
        for v in listofval:
            if not v in values: values.append(v)
        return values

    client_port_list = unique(client_port_list)
    client_port_list.sort()
    for k in range(len(client_port_list)):
        portname = client_port_list[k]
        WaveEngine.VCLtest("mc.setActiveBssid('%s', '%s', '%s')" % (clientname, portname, MyBSSIDs[portname][0]), globals())
        time.sleep(0.2) #200 milliseconds..
        WaveEngine.VCLtest("flowStats.read('%s', '%s')" % (portname, flowname), globals())
        rx_flow_pkts = flowStats.rxFlowFramesOk
        rx_pkts_per_client = rx_pkts_per_client + rx_flow_pkts

    lost_pkts_per_client = tx_flow_roam_end - rx_pkts_per_client
    lost_pkts_per_client_list.append(lost_pkts_per_client)
    lost_pkts_per_client_per_roam.append(lost_pkts_per_client/roam_count)


#Save the results to a file
WaveEngine.CreateCSVFile(CSVfilename, ResultsForCSVfile)

#Here is the string that QA is looking for a pass on
WaveEngine.OutputstreamHDL(GetQAstatusString(TestPassed) , WaveEngine.MSG_SUCCESS)

#Done
WaveEngine.GetLogFile(CardList)
WaveEngine.DisconnectAll()

WaveEngine.OutputstreamHDL("\n\nRoam Stats Table:\n", WaveEngine.MSG_OK)
WaveEngine.OutputstreamHDL("=================\n", WaveEngine.MSG_OK)
WaveEngine.OutputstreamHDL("ClntName  MinRoamDly(msecs)  MaxRoamDly(msecs)  AvgRoamDly(msecs)  NumOfRoams  LostPkts/Roam  LostData/Roam(Kbits)\n", WaveEngine.MSG_OK)

for i in range(len(ClientProfile)):
    clientname = ClientNames[i]
    roam_delay_per_client = []
    for j in range(len(roam_delay_client_name)):
        if clientname == roam_delay_client_name[j]:
            roam_delay_per_client.append(roam_delay_list[j])

    roam_delay_per_client = roam_delay_per_client[1:]

    for k in range(len(roam_delay_per_client)):
        if roam_delay_per_client[k] == 'NR':
            roam_delay_per_client[k] = 0

    avgoflist = reduce((lambda x, y: x + y), 
            roam_delay_per_client)/len(roam_delay_per_client)
    min_max_avg_list = [min(roam_delay_per_client), max(roam_delay_per_client),\
            avgoflist]
    
    WaveEngine.OutputstreamHDL("%s\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\n" % (clientname, min_max_avg_list[0],
        min_max_avg_list[1], min_max_avg_list[2], roam_count_list[i], lost_pkts_per_client_per_roam[i],
        (FrameSize * lost_pkts_per_client_per_roam[i] * 8)/1000), WaveEngine.MSG_OK)
    
WaveEngine.CloseLogging()
