# Imports
from vcl import *
from basetest import *
import RoamDelayEventClass 
import WaveEngine as WE
from roaming_common import RoamingCommon 
from CommonFunctions import *
import odict

from threading import Thread
import time
import math
import os
import os.path
import traceback
import sched
import copy
from optparse import OptionParser
#Graph libraries
from reportlab.graphics.charts.axes import XValueAxis
from reportlab.graphics.shapes import Drawing, Line, String, Rect, STATE_DEFAULTS
from reportlab.graphics.charts.linecharts import HorizontalLineChart
from reportlab.graphics.charts.linecharts import makeMarker
from reportlab.graphics import renderPDF
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.lib import colors
from reportlab.graphics.charts.legends import Legend, LineLegend
from reportlab.graphics.charts.textlabels import Label


class Test(RoamingCommon, BaseTest):
    def __init__(self):
        BaseTest.__init__(self)
        RoamingCommon.__init__(self)
        
        """
        Specify the test name, needed roaming_common.RoamingCommon
        """
        self.testName = 'Roaming Delay'
        
#-------------------User Configuration--------------------------------
        """
        Specify the duration for which the test is to be run.
        """
        self.totalduration = 25

        #-------------- Hardware definition ----------------
        """
        The CardMap defines the WaveBlade ports that will be available for the
        test.
        Field Definitions:                                                     
          PortName -    Name given to the specified WaveBlade port. This is a 
          user defined name. 
          ChassisID -   The WT90/20 Chassis DNS name or IP address. Format: 
          'string' or '0.0.0.0'
          CardNumber -  The WaveBlade card number as given on the Chassis front
          panel.
          PortNumber -  The WaveBlade port number, should be equal to 0 for 
          current cards. 
          Channel -     WiFi channel number to use on the port. 
          Autonegotiation - Ethernet Autonegotiation mode. Valid values: 
          'on', 'off', 'forced'.
          Speed -       Ethernet speed setting if not obtained by 
          autonegotiation. Valid values: 10, 100, 1000
          Duplex -      Ethernet Duplex mode if not obtained by 
          autonegotiation. Valid values: 'full', 'half'
        Field Format: dictionary
          For Wifi Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, 
              <Channel> ),
          For Ethernet Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, 
              <autoNegotiation>, <speed>, <duplex> ),
        """
        self.CardMap = { 'WT90_E1': ( 'wt-tga-14-61', 1, 0, 'on', 100, 'full' ),
                         'WT90_W1': ( 'wt-tga-14-61', 3, 0, 2 ),
                         'WT90_W2': ( 'wt-tga-14-61', 4, 0, 2 )
                       }

        """
        Security Options is dictionary of passed security parameters.  
        It has a mandatory key of 'Method' and optional keys depending 
        upon the particular security chose.  Some common one defined:
        """
        self.Security_None = {'Method': 'NONE'}
        self.Security_WEP  = {'Method': 'WEP-OPEN-128', 'KeyId': 0, 
        'NetworkKey': '00:00:00:00:00:00' }
        self.Security_WPA2 = {'Method': 'WPA2-EAP-TLS', 
        'Identity': 'anonymous', 'Password' : 'whatever'}
          
        """
        The NetworkList defines the network profiles that can be configured
        for a clientgroup.
        Each profile is a Dictionary of <Profilename> : {Parameters}
        Field Definitions of Parameters:
          'ssid' : <ssidname>  - Type : string
          'security' : <security options> - Type : dictionary.
          'otherflags' : {Different network related flags}
          The different network related flags can optionally be 
          'Disassoc_before_reassoc' : <True/False>
          'Reassoc_when_roam' : <True/False>
          'pmkid_cache' : <True/False>
          'Deauth_before_roam' : <True/False>
          'PreAuth' : <True/False>
        """
        self.NetworkList = {
                           'Cisco': {'ssid': 'cisco', 
                           'security': self.Security_None, 
                           'otherflags': {'Disassoc_before_reassoc': False, 
                           'Reassoc_when_roam': False, 'pmkid_cache': False,
                           'Deauth_before_roam': False, 'PreAuth' : False} },

                           'Aruba': {'ssid': 'aruba', 
                           'security': self.Security_WPA2, 'otherflags' : {}},

                           'Colubris_NONE': {'ssid': 'roam_ap', 
                           'security': self.Security_None, 'otherflags' : {}},
                            
                           'Colubris_WPA2': {'ssid': 'WPA2_EAP', 
                           'security': self.Security_WPA2, 'otherflags' : {}}
                           }

        """
        Ethernet Client properties. For now, there is just one Ethernet 
        client that can be configured. The main traffic will flow from 
        Ethernet to the Wireless clients.
        """
        self.Port8023_Name       = 'WT90_E1'
        self.Port8023_ClientName = 'Client_8023'
        self.Port8023_IPaddress  = '192.168.1.160'
        self.Port8023_Subnet     = '255.255.0.0'
        self.Port8023_Gateway    = '192.168.1.110'
        self.Port8023_MAC        = 'DEFAULT'
        self.Port8023_AssocRate    = 100
        self.Port8023_AssocTimeout = 1
        self.Port8023_AssocRetry   = 1
        self.Port8023_VlanTag    = {}

        """
        These parameters will effect the performance of the test. They 
        should only be altered if a specific problem is occuring that 
        keeps the test from executing with the DUT.

        ARPRate -    The rate at which the test will attempt issue ARP requests 
                     during the learning phase.  Units: ARPs/second; Type: float
        ARPRetries - Number of attempts to retry any give ARP request before 
                     considering the ARP a failure.
        ARPTimeout - Amount of time the test will wait for an ARP response 
                     before retrying or failing.
        """
        self.ARPRate           =  10.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0

        #-------------------- Timing parameters -----------------
        """
        These parameters will effect the performance of the test. They should 
        only be altered if a specific problem is occuring that keeps the 
        test from executing with the DUT. 
        BSSIDscanTime -     Amount of time to allow for scanning during the 
        BSSID discovery process. Units: seconds
        AssociateRate -     The rate at which the test will attempt to 
        associate clients with the SUT. This includes the time required to 
        complete .1X authentications.  Units: associations/second.
        AssociateTimeout -  Amount of time the test will wait for a client 
        association to complete before considering iteration a failed 
        connection. Units: seconds; 
        AssociateRetries -  Number of attempts to retry the complete 
        association process for each client in the test.
        """
        self.BSSIDscanTimeout = 5
        self.AssociateRate    = 10
        self.AssociateTimeout = 10 
        self.AssociateRetries = 0

        #--------------------- Logging Parameters ---------------
        """
        These parameters determine how the output of the test is to be formed. 
        CSVfilename -       Name of the output file that will contain the 
        primary test results. This file will be in CSV format. This name can 
        include a path as well. Otherwise the file will be placed at the 
        location of the calling program. 
        SavePCAPfile -      Boolean True/False value. If True a PCAP file will 
        be created containing the detailed frame data that was captured on 
        each WT-20/90 port. 
        """
        self.CSVfilename      = 'Results_roaming_delay.csv'
        self.ReportFilename   = 'Report_roaming_delay.pdf'
        self.DetailedFilename = 'Detailed_roaming_delay.csv'
        self.RSSIfilename     = 'RSSI_roaming_delay.csv'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False

        #------------ Power ramp up/down profiles ---------------
        """
        These profiles determine what power ramp up/down pattern will be 
        generated for each Roam event for any client. Any of the defined
        power profiles can be attached to a Roam profile which in turn gets
        attached to a clientgroup.
        A Powerlist is a dictionary of the form, 'Powerprofilename' : 
        ([power ramp down profile], [power ramp up profile]). 
        A power ramp down/up profile = [startpower, endpower, powerstep, 
        timeinterval]
        startpower - This is the power level from which the power up/down 
        pattern will start. startpower has to be greater than stoppower in
        a power ramp down event. viceversa for ramp up event.
        stoppower  - This is the power level at which the power up/down
        patter will stop.
        powerstep  - The power increment/decrement steps.
        timeinterval - How long to transmit frames at each power level.
        """
        self.Powerlist = { 
                         'Pprofile1': ([-20, -20, 10, 100], [-20, -10, 10, 100])
                         }

        #-------------------- Roam profiles-----------------------
        """
        Any of the Roam profiles can be attached to a clientgroup. Thus, each 
        of the clients in the clientgroup will inherit the attached Roam 
        profile.
        A Roamlist of a dictionary of form, 'Roamprofilename' : 
        {Key : Value pairs}
          Key : Value pairs can be
          'PortList': listofports - This is the list of ports 
          across which the Roam is to be executed.
          'DwellTime' : listofdwelltimes - This is the list of dwell times 
          for any client on each of the corresponding ports. There has to 
          be a direct mapping between the portlist and dwelltime list. 
          'ClientDistr' : <True/False> - If True, then the clients
          will be evenly distributed across all the available ports. If False,
          then all the clients will start roaming from the first port.
          'TimeDistr' : <'even'/'dense'> - Type: string. If 'even', then
          the roam events of all the clients will be distributed evenly across
          the given dwell time. When timedistribution is 'even', there can be
          only one dwelltime in the listofdwelltimes. 
          'TestType' : <'Repeat'/'Duration'> - If 'Repeat', then the roams
          will be repeated across all ports for 'val' number of times.
          If 'Duration', then the roams will be executed for 'val' period of
          time iterating through the port list.
          'TestTypeValue' : <repeatcount/duration value> - Type: float/integer.
          This value is interpreted on the basis of roam_testtype config.
          'Powerprof' : <name of the power profile> - Type: string.
          This is the name of a predefined powerprofile. See power ramp up
          down profile section. 
         """ 
        self.Roamlist = {
                        'Roam1': {'PortList'     : ['WT90_W1', 'WT90_W2'], 
                                  'DwellTime'    : [5, 1],
                                  'BSSIDList'    : ['00:13:5f:0e:cb:10', '00:12:44:b1:7e:b0'],
                                  'ClientDistr'  : True ,
                                  'TimeDistr'    : 'even',
                                  'TestType'     : 'Duration',
                                  'TesttypeValue': 31,
                                  'Powerprof'    : 'Pprofile1'
                                  },
                        'Roam2': {'PortList'     : ['WT90_W1', 'WT90_W2'], 
                                  'DwellTime'    : [5, 3],
                                  'BSSIDList'    : ['00:13:5f:0e:cb:10', '00:12:44:b1:7e:b0'],
                                  'ClientDistr'  : False,
                                  'TimeDistr'    : 'dense',
                                  'TestType'     : 'Repeat',
                                  'TesttypeValue': 3,
                                  }
                        }
                        
        #------------------- Flow Parameters ----------------
        """
        These parameters determine the type of data frames and flows to be 
        used in the test.
        Any of the defined flows can then be attached to a clientgroup.
        A Flowlist is a dictionary of 'Flowname' : 
        {Key : Value pairs} 
        Key : Value pairs can be
        'Type' : Packet or frame type. Valid values: 'UDP', 'TCP', 'IP', 'ICMP'
        'Framesize' : frame size . Type <integer>
        'Phyrate' : rate. Type <integer>
        'Ratemode' : 'pps'
        'Intendedrate' : Traffic rate. Type <integer>
        'Numframes' : Max frames to be sent. Type <integer>
        MainFlowlist - The list of flows that would be attached to a 
        clientgroup as the main traffic pattern for the clientgroup. The
        traffic will flow from Ethernet client to the Wireless clients in
        the clientgroup.
        LearnFlowlist - The list of learning flows that can be attached 
        to a clientgroup. The learning flows would be generated from the
        clients in the clientgroup to the Ethernet client.
        """
        self.MainFlowlist = {
                            'Flow1': {'Type'         : 'IP', 
                                      'Framesize'    : 512,
                                      'Phyrate'      : 54, 
                                      'Ratemode'     : 'pps',
                                      'Intendedrate' : 100, 
                                      'Numframes'    : WE.MAXtxFrames
                                      }
                            }
        self.LearnFlowlist = {
                            'Lflow1':{'Type'         : 'IP',
                                      'Framesize'    : 256, 
                                      'Phyrate'      : 54, 
                                      'Ratemode'     : 'pps', 
                                      'Intendedrate' : 100, 
                                      'Numframes'    : 10
                                     }
                             }

        #---------------- ClientGroup Parameters ----------------
        """
        The Clientgroups is a dictionary that defines the characteristics of
        each clientgroup. A number of wireless clients are created each of 
        which inherits the properties of the clientgroup.
        Each of the clientgroup is defined as 
        'Groupname': {Key : Value pairs}
        Key : Value pairs can be
        'StartMAC' : The MAC address of the first client in the group. For 
        random MAC, use 'DEFAULT'
        'StartIP'  : The IP address of the first client in the group.
        'Gateway'  : Gateway IP address for all the clients.
        'SubMask'  : Subnet mask for the IP addresses of the clients.
        'NumClients' : The number of wireless clients to be created in 
        this client group.
        'Security' : security profile name - This attaches a network 
        profile that gets configured for each of the clients.
        'Roamprof' : roamprofile name - This attaches a roam profile that 
        gets configured for each of the clients.
        'MainFlow' : mainflow name - The main traffic flow that will be 
        attached to each client.
        'LearnFlow' : learnflow name - The learning traffic flow that will 
        get attached to each client. 
        'AssocProbe': Probe before associate- either do not send probe request ('None') or
                     send probe request (either 'Unicast' or 'Broadcast')
        """
        self.Clientgroups = {
                            'Group1': {'Enable'    : True,
                                       'StartMAC'  : 'ae:ae:ae:00:00:01',
                                       'MACIncr'   : -4,
                                       'StartIP'   : '192.168.1.100', 
                                       'IncrIp'    : '0.0.0.1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0',
                                       'NumClients': 2,
                                       'Security'  : 'Cisco',
                                       'Roamprof'  : 'Roam1',
                                       'MainFlow'  : 'Flow1',
                                       'LearnFlow' : 'Lflow1',
                                       'AssocProbe': 'Unicast'
                                       },
                            'Group2': {'Enable'    : False,
                                       'StartMAC'  : '00:00:11:22:33:44',
                                       'MACIncr'   : 'Auto',
                                       'StartIP'   : '192.168.1.200',
                                       'IncrIp'    : '0.0.0.1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0', 
                                       'NumClients': 2,
                                       'Security'  : 'Cisco',
                                       'Roamprof'  : 'Roam2',
                                       'MainFlow'  : 'Flow1'
                                       } 
                            }

                        
# ---------------- End of User configuration -------------
        self.graphPlotInterval = 3.0

    def getTestName(self):
    
        return  'roaming_delay'
       
    def getInfo(self):
        msg = "The test measures the roaming delays and packet loss of the clients roaming when the SUT is stressed with a specified roam pattern and each client configured with certian dwell time(s). Client roam pattern can be tuned with the option of clients' starting points distributed among the AP's.\n\nThe test works by creating the configured number of wireless clients on the Wireless test ports and one Ethernet client on the Ethernet port of the VeriWave system.  Once these clients are created and assigned the necessary attributes (security, data flows, etc.), the  Wireless clients are bound to their initial target test ports, and associated with  the SUT (i.e., the APs). The test then begins to move (roam) the Wireless clients  between the APs at the desired interval and in user specified pattern which is defined in the roam profile.   When each roam operation is performed,the test measures the time taken to roam and the number of data packets (from Ethernet to Wireless) lost  during the roam. At the end of the test duration, the script reports the minimum,  maximum and average roam delays for each test client, the number of roams performed,  and the average number of packets lost per roam for each client."
        return msg
    
    def generateConfigSummary(self):
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        ConfigSummary = {}
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            CGconfig = self.Clientgroup[CGname]
            roamList = (x+'  -  '+ y for x, y, _ in CGconfig.GetRoamlist())
            roamList = reduce(lambda x, y: x+', ' +y, roamList)
            Config = dict([('Network', CGconfig.Getssid()),
                           ('Security' , (CGconfig.Getsecurity())['Method']),
                           ('#Clients', CGconfig.numclients),
                           ('Roam Sequence', roamList)])
            #return the dwell time of first port/time pair
            Config['Dwell Time'] = (CGconfig.GetRoamlist())[0][2]
            
            if CGconfig.GetTimeDistr() == 'dense':
                timeDistr = 'same time'
            else:
                timeDistr = 'even time'
            if CGconfig.GetClientdistrF() == True:
                clientDistr = 'even across ports'
            else:
                clientDistr = 'same port'
            Config['Time Dist'] = timeDistr
            Config['Client Dist'] = clientDistr

            testPeriodType = CGconfig.Gettesttype()
            testTypeVal = int(CGconfig.GettesttypeValue())
            if testPeriodType == 'Repeat':
                testPeriod = '%d Cycles'%testTypeVal
            elif testPeriodType == 'Duration':
                val, units = self.computeTimeValueAndUnits(testTypeVal)
                testPeriod = '%d %s'%(val, units)
            Config['Test Period'] =  testPeriod 
            
            datatrafficStr = ''
            if CGname in self.Clientgroups.keys():
                flowname = self.Clientgroups[CGname]['MainFlow']
                if flowname in self.MainFlowlist.keys():
                    flowConfig = self.MainFlowlist[flowname]
                    datatrafficStr += str(flowConfig['Framesize']) + 'Byte '
                    datatrafficStr += flowConfig['Type']
                    datatrafficStr += ' ' + str(flowConfig['Intendedrate']) + 'pps '
                    Config['Traffic Data'] = datatrafficStr
            ConfigSummary[CGname] = Config     
              
        return ConfigSummary
    
    def insertTestConfigIntoReport(self, ConfigSummaryPerCG):
        roamSummary = [('Group', 'Network', 'Security', '#Clients',
                        'Roam Sequence' , 'Test Period', 'Dwell Time',
                        'Time Dist', 'Client Dist', 'Traffic Data')]
        columnsList = [0.65*inch, 1.15*inch, 1.15*inch, 0.55*inch, 1.4*inch,
                       0.65*inch, 0.5*inch, 0.45*inch, 0.5*inch, 0.6*inch]
        for CG in ConfigSummaryPerCG.keys():
            Config = ConfigSummaryPerCG[CG]
            if Config['Security'].upper() == 'NONE':
                security = 'Open'
            else:
                security = Config['Security']

            resultTuple = (CG, Config['Network'], security, Config['#Clients'],
                           Config['Roam Sequence'], Config['Test Period'],
                           Config['Dwell Time'], Config['Time Dist'], 
                           Config['Client Dist'],Config['Traffic Data'])
            
            roamSummary.append(resultTuple)
            
        self.MyReport.InsertDetailedTable(roamSummary, columns = columnsList)
    
    def getDetailedLogColumnNames(self):
        tmpStr = "Roam Time, Client Group, Client Name, Source Port, Source BSSID, \
                  Destination Port, Destination BSSID,\
                  Total Roam Delay, Client Delay, AP Roam Delay, \
                  Probe Request Timestamp, Probe Response Timestap, \
                  AP Probe Response Delay, 802.11 Auth Request Timestamp, \
                  802.11 Auth Response Timestamp, AP 802.11 Auth Delay, \
                  WEP Auth Request Timestamp, WEP Auth Response Timestamp, \
                  AP WEP Auth Delay, Assoc Request Timestamp, Assoc Response Timestamp,\
                  AP Assoc Delay, EAP ReqIdentity Timestamp, EAPOL Group Key Timestamp,\
                  Auth Time"
        columnNamesStr = self.stripLeftAndRight(tmpStr) 
        
        return columnNamesStr
        
    def CreateClientgroup(self, name, base_mac, base_ip, gateway, subnetmask, 
        numclients, network, ipIncr, macIncr, assocProbe):
        if network not in self.NetworkList.keys():
            self.Print("Security profile %s not found\n" % network, 'ERR')
            return
        #Adds a 'CGgroupname': ClientGroupObject (from RoamDelayEventClass) 
        self.Clientgroup[name] = RoamDelayEventClass.RoamDelayClientGroup(name, 
                base_mac, base_ip, gateway, subnetmask, numclients, ipIncr,
                macIncr, assocProbe, self.NetworkList[network]['ssid'], 
                self.NetworkList[network]['security'],
                self.NetworkList[network]['otherflags'])

    def CGGenclients(self):
        retList = []
        maxSplitTime = 1800
        for CGname in self.Clientgroup.keys():
            retVal = self.Clientgroup[CGname].splitGenClients(maxSplitTime)
            retList.append(retVal)
        return retList

    def Generateclients(self):
        #For each CGobject, RoamDelayEventClass generates a list of 
        #Client objects. This is stored as a dictionary of form
        #'clientname': ClientObject. This dictionary can be 
        #retrieved for each CGobject with GetClientdict() method.
        max_test_time = 0
        for CGname in self.Clientgroup.keys():
            total_roam_time = self.Clientgroup[CGname].Generateclients()
            if total_roam_time > max_test_time:
                max_test_time = total_roam_time
        self.SetTotalDuration(max_test_time)

    def getEventGenerator(self):
        return RoamDelayEventClass.Eventgenerator()
    
    def getTestEthPortList(self):
        return [self.Port8023_Name]
    
    def CreateRoamprofile(self, name, roamlist, clientdistrflag, 
                          timedistr,  testType, testTypeValue, portbssidMapList):
        self.Roamprofiles[name] = RoamDelayEventClass.RoamProfile(roamlist, 
                                                                  clientdistrflag,
                                                                  timedistr,
                                                                  portbssidMapList,
                                                                  testType,
                                                                  testTypeValue) 
    
    def createAndConnectEthClient(self):        
        incrTuple = (1,)
        MAC = self.Port8023_MAC
        if MAC == 'DEFAULT':
            MAC = IETF_MAC(1)
            incrTuple += ('DEFAULT',)
        elif MAC == 'AUTO':
            incrTuple += ('AUTO',)
        else:
            incrTuple += ('00:00:00:00:00:00',)
        incrTuple += ('0.0.0.0',)
        self.Client8023 = WE.CreateClients([ (self.Port8023_ClientName,
                                              self.Port8023_Name, 
                                              '000000000000', 
                                              MAC, 
                                              self.Port8023_IPaddress,
                                              self.Port8023_Subnet, 
                                              self.Port8023_Gateway, 
                                              incrTuple, 
                                              self.Port8023_Security, 
                                              self.Port8023_VlanTag)])
        
        ethGroupName = self._getEthernetGroupName()
        
        self.clientgroupObjs[ethGroupName].addClients(self.Client8023)
        
        self.connectClients(self.Client8023)
        
    def _getEthernetGroupName(self):
        return self.Port8023_GroupName
            
    def AddFlow(self, CGname, flowprof, learnflowprof = None):
        if flowprof == None:
            self.Print("No Flow profile for Clientgroup %s\n" % CGname,\
                    'ERR')
            return
        if CGname not in self.ClientgrpClients.keys():
            self.Print("No clients found in Clientgroup %s\n" % CGname,\
                    'ERR')
            return

        ListofClientdict = self.ClientgrpClients[CGname]
        self.ClientgrpFlows[CGname] = flowprof
        FlowOptions = self.FlowOptions.copy() # VPR 2983   {}
        FlowOptions['Type'] = flowprof.Type
        FlowOptions['FrameSize'] = flowprof.FrameSize
        FlowOptions['PhyRate'] = flowprof.PhyRate
        FlowOptions['RateMode'] = flowprof.RateMode
        FlowOptions['IntendedRate'] = flowprof.IntendedRate
        if FlowOptions['Type'] == 'UDP':
            FlowOptions['srcPort'] = flowprof.srcPort
            FlowOptions['destPort'] = flowprof.destPort
        elif FlowOptions['Type'] == 'ICMP':
            FlowOptions['type'] = flowprof.type
            FlowOptions['code'] = flowprof.code
        FlowOptions['NumFrames'] = flowprof.NumFrames
        Flowdict = WE.CreateFlows_PartialMesh(self.Client8023,
                ListofClientdict, False, FlowOptions)
        for key in Flowdict.keys():
            self.FlowList[key] = Flowdict[key]
        WE.ModifyFlows(Flowdict, {'FrameSize': flowprof.FrameSize,
                'IntendedRate': flowprof.IntendedRate, 
                'NumFrames': flowprof.NumFrames, 
                'RateMode': flowprof.RateMode,
                'Type': flowprof.Type})

        if learnflowprof != None:    
            FlowOptions = {}
            FlowOptions['Type'] = learnflowprof.Type
            FlowOptions['FrameSize'] = learnflowprof.FrameSize
            FlowOptions['PhyRate'] = learnflowprof.PhyRate
            FlowOptions['RateMode'] = learnflowprof.RateMode
            FlowOptions['IntendedRate'] = learnflowprof.IntendedRate
            FlowOptions['NumFrames'] = learnflowprof.NumFrames
            LearnFlowdict = WE.CreateFlows_PartialMesh(ListofClientdict,
                    self.Client8023, False, FlowOptions)
            for flowname in LearnFlowdict.keys():
                srcclientname = LearnFlowdict[flowname][1]
                dstclientname = LearnFlowdict[flowname][3]
                clientdict = self.Clientgroup[CGname].GetClientdict()
                if srcclientname in clientdict.keys():
                    flowparams = RoamDelayEventClass.Flowparams()
                    flowparams.pkttype = learnflowprof.Type
                    flowparams.numframes = learnflowprof.NumFrames
                    flowparams.framesize = learnflowprof.FrameSize
                    flowparams.ratemode = learnflowprof.RateMode
                    flowparams.rate = learnflowprof.IntendedRate
                    flowparams.srcclient = srcclientname
                    flowparams.dstclient = dstclientname
                    flowparams.flowname = flowname
                    flowparams.grpname = "LearnGroup"
                    clientdict[srcclientname].Setlearnflow(flowparams)
                self.LearnFlowList[flowname] = LearnFlowdict[flowname]
            WE.ModifyFlows(LearnFlowdict, 
                    {'FrameSize': learnflowprof.FrameSize, 
                    'IntendedRate': learnflowprof.IntendedRate, 
                    'NumFrames': learnflowprof.NumFrames, 
                    'RateMode': learnflowprof.RateMode,
                    'Type': flowprof.Type})
    
    def makeScheduler(self, eventlist, FuncRealTime, absTime):
        if ((eventlist == -1)
                or (len(eventlist) == 0)):
            return None
        listofports = []
        for CGname in self.Clientgroup.keys():
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            for clientname in clientdict.keys():
                bssidportlist = clientdict[clientname].GetbssidportMap()
                for items in bssidportlist:
                    for port in items.keys():
                        if port not in listofports:
                            listofports.append(port)
        listofports.append(self.Port8023_Name)
        listofports.sort()
        Ethportlist = []
        Wportlist = []
        for port in listofports:
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes:
                Wportlist.append(port)
            if WE.GetCachePortInfo(port) == '8023':
                Ethportlist.append(port)

        #Run events one by one and sleep in between
        Scheduler = sched.scheduler(time.time, time.sleep)
        for i in range(len(eventlist)):
            Scheduler.enterabs(eventlist[i].GetTime() + absTime, 1, 
                    eventlist[i].run, '')
        actualTestDuration = eventlist[len(eventlist) - 1].GetTime()
        stats_interval = 1
        start_time = int(0.0 + stats_interval + absTime + self.lastRunTime)
        end_time = int(actualTestDuration + absTime)
        for i in range(start_time, end_time, stats_interval):
            Scheduler.enterabs(i, 100, FuncRealTime, (Ethportlist, 
                    Wportlist))
        #When we reach the test duration end time, quit even if we have any event 
        #yet to be run (this happens when the user sets high roam rate).
        #We check every 1 sec until we are 
        #1 sec away from the last roam event time (to make sure we are checking before the 
        #last roam event and thus making sure the exception raised is valid). The tolerance x
        #of 1 < x <2 sec should be Ok, if the user wants to run for the exact period 
        #of time or less tolerance, he should better adjust the roam rate
        testEndTime = actualTestDuration + absTime
        for i in range(start_time, end_time, 1):    
            Scheduler.enterabs(i, 1,  self.clearEvents, ())
        
        self.lastRunTime = actualTestDuration
        return Scheduler

    def startFlows(self):
        if len(self.FlowList) > 0:
            self._startFlowGroup("XmitGroup")

        if len(self.LearnFlowList) > 0:
            self._startFlowGroup("LearnXGroup")

    def stopFlows(self):
        if len(self.LearnFlowList) > 0:
            WE.VCLtest("action.stopFlowGroup('%s')" % "LearnXGroup", 
                    globals())
            WE.VCLtest("action.stopFlowGroup('%s')" % "LearnGroup", 
                    globals())
        if len(self.FlowList) > 0:
            WE.VCLtest("action.stopFlowGroup('%s')" % "XmitGroup", 
                    globals())

    """
    # KLUDGE! Walk each MC through the port list, finally ending up back at 
    # the starting port; this ensures that all MC instances except the 
    # one on the starting port are disabled 
    # (the MC instances are always enabled when first created) 
    # this must be done BEFORE the flows are started!
    def WalkMCPortlist(self):
        for CGname in self.Clientgroup.keys():
            if CGname in self.InvalidClientgrps:
                continue
            clientdict = self.Clientgroup[CGname].GetClientdict()
            for clientname in clientdict.keys():
                bssidportlist = []
                roamlist = clientdict[clientname].Getroameventlist()
                if len(roamlist) > 0:
                    for (port, bssid, timex) in roamlist:
                       items = {port: bssid}
                       if items not in bssidportlist:
                           bssidportlist.append(items)
                WE.VCLtest("mc.read('%s')" % clientname, globals())
                for items in bssidportlist:
                    for port in items.keys():
                        WE.Setactivebssid(clientname, port,
                            items[port])
                        time.sleep(0.50)
                #bring MC back to the starting port 
                #(i.e., first port in roam list for MC)
                roamlist = clientdict[clientname].Getroameventlist()
                if len(roamlist) > 0:
                    (startport, startbssid, starttime) = roamlist[0]
                    WE.Setactivebssid(clientname, startport,
                            startbssid)
                    time.sleep(0.50)
    
        """



    

    def createflows(self):
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        for groupname in groupnames:
            if 'MainFlow' not in self.Clientgroups[groupname].keys():
                self.Print("MainFlow not defined for %s\n" % groupname, 'ERR')
                return
            mainflowname = self.Clientgroups[groupname]['MainFlow']
            if mainflowname not in self.MainFlowlist.keys():
                self.Print("%s not defined\n" % mainflowname, 'ERR')
                return
            Keys = self.MainFlowlist[mainflowname].keys()
            if 'Type' in Keys:
                pkttype = self.MainFlowlist[mainflowname]['Type']
            else:
                pkttype = 'IP'
            if 'Framesize' in Keys:
                framesize = self.MainFlowlist[mainflowname]['Framesize']
            else:
                framesize = 256
            if 'Phyrate' in Keys:
                phyrate = self.MainFlowlist[mainflowname]['Phyrate']
            else:
                phyrate = 54
            if 'Ratemode' in Keys:
                ratemode = self.MainFlowlist[mainflowname]['Ratemode']
            else:
                ratemode = 'pps'
            if 'Intendedrate' in Keys:
                intendedrate = self.MainFlowlist[mainflowname]['Intendedrate']
            else:
                intendedrate = 100
            if 'Numframes' in Keys:
                numframes = self.MainFlowlist[mainflowname]['Numframes']
            else:
                numframes = WE.MAXtxFrames
            srcPort = 8000
            destPort = 69
            type = 0
            code = 0
            if pkttype == 'UDP':
                if 'srcPort' in Keys:
                    srcPort = self.MainFlowlist[mainflowname]['srcPort']

                if 'destPort' in Keys:
                    destPort = self.MainFlowlist[mainflowname]['destPort']
            elif pkttype == 'ICMP':
                if 'type' in Keys:
                    type = self.MainFlowlist[mainflowname]['type']
                if 'code' in Keys:
                    code = self.MainFlowlist[mainflowname]['code']
            
            mainflow = self.Flow(pkttype, framesize, phyrate, ratemode,intendedrate, 
                                 numframes, SourcePort = srcPort, DestinationPort = destPort,
                                 IcmpType = type, IcmpCode = code)
            
            learnflow = None
            learnflowname = ''
            if 'LearnFlow' in self.Clientgroups[groupname].keys():
                learnflowname = self.Clientgroups[groupname]['LearnFlow']
            if learnflowname != '':
                if learnflowname not in self.LearnFlowlist.keys():
                    self.Print("%s not defined in LearnFlowlist\n" %
                            learnflowname, 'ERR')
                    return
                Keys = self.LearnFlowlist[learnflowname].keys()
                if 'Type' in Keys:
                    pkttype = self.LearnFlowlist[learnflowname]['Type']
                else:
                    pkttype = 'IP'
                if 'Framesize' in Keys:
                    framesize = self.LearnFlowlist[learnflowname]['Framesize']
                else:
                    framesize = 256
                if 'Phyrate' in Keys:
                    phyrate = self.LearnFlowlist[learnflowname]['Phyrate']
                else:
                    phyrate = 54
                if 'Ratemode' in Keys:
                    ratemode = self.LearnFlowlist[learnflowname]['Ratemode']
                else:
                    ratemode = 'pps'
                if 'Intendedrate' in Keys:
                    intendedrate = self.LearnFlowlist[learnflowname]['Intendedrate']
                else:
                    intendedrate = 100
                if 'Numframes' in Keys:
                    numframes = self.LearnFlowlist[learnflowname]['Numframes']
                else:
                    numframes = 10

                learnflow = self.Flow(pkttype, framesize, phyrate, ratemode,
                                intendedrate, numframes)
            self.AddFlow(groupname, mainflow, learnflow)

    def getRoamedClientList(self):
        return RoamDelayEventClass.getRoamedClientList()
    
    def getClientData(self):
        return RoamDelayEventClass.getClientStats()
    
    def getLastRoamDetails(self, clientName):
        return RoamDelayEventClass.getLastRoamDetails(clientName)
    
    def _loadEthGroupData(self, waveClientTableStore, waveSecurityStore):
        #Pick up the first Enabled ethernet client group
        clientGroupNames = waveClientTableStore.keys()
        clientGroupNames.sort()
        for groupName in clientGroupNames:
            clientObj = waveClientTableStore[groupName]
            if ((clientObj['Enable'] in [True, 'True']) and
                clientObj['Interface'] == '802.3 Ethernet'):
                self.Port8023_GroupName = groupName
                self.Port8023_Name = clientObj['PortName']
                self.Port8023_IPaddress = clientObj['BaseIp']
                if clientObj['Dhcp'] == 'Enable':
                    self.Port8023_IPaddress = '0.0.0.0'
                self.Port8023_Subnet = clientObj['SubnetMask']
                self.Port8023_Gateway = clientObj['Gateway']
                self.Port8023_Security = waveSecurityStore[groupName]
                #Compute VLAN tag and copy into options
                if ( clientObj['VlanEnable'] == 'True') :
                    self.Port8023_VlanTag['VlanTag'] = \
                        ((int(clientObj['VlanUserPriority'])) & 0x7 )* 2**13 + \
                        ((bool(clientObj['VlanCfi'])) & 0x1 ) * 2**12 + \
                        ((int(clientObj['VlanId'])) & 0xfff )
                if clientObj['MacAddressMode'] == 'Auto':
                    self.Port8023_MAC = 'AUTO'
                elif clientObj['MacAddressMode'] == 'Random':
                    self.Port8023_MAC = 'DEFAULT'
                else:
                    self.Port8023_MAC = clientObj['MacAddress']
                break
    
    def _loadTestKeyAndName(self):
        self.testKey = 'roaming_delay'
        self.testName = 'Roaming Delay'
        
    def roamGroups(self, waveClientTableStore):
        """
        All Enabled wlan groups are roam groups for this test
        """
        enabledWlanGroups  = self.wlanGroups(waveClientTableStore)
        return enabledWlanGroups 
    
    def _getRoamData(self, waveTestSpecificStore, waveClientTableStore, wlanGroups):
        roaming_data = waveTestSpecificStore[self.testKey]
        return roaming_data
        
    
    def _loadTestSpecificData(self, waveClientTableStore, waveTestSpecificStore,
                              waveSecurityStore, roaming_data, 
                              enabledGroups, wlanGroups, roamGroups):
        self._loadEthGroupData(waveClientTableStore, waveSecurityStore)
        
    def _getDwellList(self, clientVals):
        if 'dwellTimeOption' in clientVals and clientVals['dwellTimeOption'] == 2: #True
            dwellList = clientVals['dwellTime'][:]
        else:
            dwellList = []
            for port in clientVals['portNameList']:
                dwellList.append(clientVals['dwellTime'])
        
        return dwellList
    
    def _getClientDistr(self, clientDistOption):
        clientDistr =  False
        if clientDistOption == 1:
            clientDistr =  False
        if clientDistOption == 2:
            clientDistr = True
        
        return clientDistr
    
    def _getTimeDistr(self, timeDistOption):
        timeDistr =  'dense'
        if timeDistOption == 1:
            timeDistr =  'dense'
        if timeDistOption == 2:
            timeDistr = 'even'
            
        return timeDistr
            
    def _getTestType(self, repeatType):
        if repeatType == 2:
            testType = 'Duration'
        if repeatType == 1:
            testType = 'Repeat'
        
        return testType
    
    def _updateClientGroupProfile(self, roaming_data):
        self._updateCGProfLFlowFlag(roaming_data)
    
    def _checkDwellTimeValidity(self, portlist, dwellTimeList):
        ret = (True, '')
        for dwellTime in dwellTimeList:
            if dwellTime < 1:
                msg = "Dwell time < 1 sec for %s\n"
                ret = (False, msg)
                return ret
            
        if len(portlist) != len(dwellTimeList):
            ret = (False, "Unequal ports and dwell times for %s\n" )

        return ret
            
    def run(self):
        try:
            self.ExitStatus = 0
            WE.setPortInfo({})
            WE.setPortBSSID2SSID({})
            WE.OpenLogging(Path = self.LoggingDirectory,
                    Detailed = self.DetailedFilename)
            self.setRealtimeCallback(self.PrintRealtimeStats)
            RoamDelayEventClass.clearStats()
            self.ConfigureData()
            self.generateClientConfig()
            self.validateInitialConfig()
            self.configurePorts()
            self.initailizeCSVfile()
            allClientsDict = self.createAndConnectRoamClients(False)
            self.writeAPinformation(allClientsDict)
            self.createAndConnectEthClient()
            self.createflows()
            self._configureClientObjectsFlows(self.FlowList)
            if self.createFlowGroups() == -1:
                raise WE.RaiseException
            self.setNATflag() 
            self.doAllArpExchanges()
            WE.ClearAllCounter(self.CardList)
            self.startFlows()

            if self.splitRunF == False:
                self.Generateclients()
                self.validateRoamConfig()
                self.startTest(self.RealtimeCallback)
            else:
                self.startSplitTest()
            
            self.stopFlows()
            lastRoamDetails = self.collectLastRoamDetails() 
            self.processStats(lastRoamDetails)
            self.SaveResults()
            if self.generatePdfReportF:
                self.PrintReport()
                #self.SaveResults()
            #Update the csv results, pdf charts (if opted by the user) in the GUI
            #'Results' page    
            self.ExitStatus=self.FinalResult
            self.updateGUIresultsPage()
        except WE.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            self.Print(str(exc_value), 'ERR')
            self.ExitStatus = 2
            self.SaveResults()
        except Exception, e:
            # some other error occured
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            try:
                msg = "Fatal script error:\n"
                for text in traceback.format_exception(exc_type, exc_value,
                        exc_tb):
                    msg += str(text)
                self.Print(str(msg), 'ERR')
            except Exception, e:
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1

        self.CloseShop()
        return self.ExitStatus


#------------ Main() -------------- 
if __name__ == "__main__":
    # Commandline execution starts here
        
    # set up options parser.  -h or --help will print usage.
    usage = "usage: %prog [options] -f FILENAME"
    parser = OptionParser( usage )
    parser.add_option("-f", "--file", dest="filename",
                    help="read configuration from FILE", metavar="FILE")
    parser.add_option("-l", "--savelogs",
                    dest="logs", action="store_true", default=False,
                    help="save hardware logs after test")
    (options, args) = parser.parse_args()
    # ...args is a list of extra arguments, like a wml config file.
    
    # Create the test
    userTest = Test()

    WE.SetOutputStream(PrintToConsole)
    if options.filename != None:
        retval = userTest.loadFile( options.filename )
    if options.logs:
        userTest.SavePCAPfile = True

    userTest.run()
    sys.exit(userTest.ExitStatus)
