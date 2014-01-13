# Imports
from vcl import *
from basetest import *
import RoamBenchmarkEventClass 
#import roambenchmark
from roamLib import computeWaitTimes
import WaveEngine as WE
from roaming_common import RoamingCommon 
from roamBenchCommon import RoamBenchCommon
from CommonFunctions import *
import odict

import pdb
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


class Test(RoamBenchCommon, RoamingCommon,  BaseTest):
    def __init__(self):
        BaseTest.__init__(self)
        RoamingCommon.__init__(self)
#-------------------User Configuration--------------------------------


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
          For Ethernet Card:
              Autonegotiation mode - Ethernet Autonegotiation mode. Valid values: 
                              'on', 'off', 'forced'.
              Speed -       Ethernet speed setting if not obtained by 
              Autonegotiation. Valid values: 10, 100, 1000
              Duplex -      Ethernet Duplex mode if not obtained by 
                          autonegotiation. Valid values: 'full', 'half'
          For WiFi Card:
              Channel -     WiFi channel number to use on the port. 
              
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
        testOptions contains the options applicable across all the roaming groups.
        'flowPacketSize':   The size of the packets sent to the roaming clients (from an 
                            eth group), this packet flow is used in measuring the 
                            roam metrics (roaming delay, packet loss etc)
        'flowRate': The rate of the above flow
        'repeatType':   Specifies whether test should be run for certain amount of time 
                        or for certain number of cycles
                        Values-   'Duration', 'Repeat'
        'durationUnits': Applicable only when 'repeatType' is 2 (Duration)
                         Values- 0: Seconds, 1: Minutes, 2:Hours
        'repeatValue':  This specifies the amount of time or number of cycles depending
                        on the 'repeatType'
                        Type- Positive Integer
                        
        'learningFlowFlag': Specifies whether learning flows are to be used
                            0: OFF, 1: ON
        'learningPacketRate': Rate of the learning flow 
        
        The below options specify client attributes while roaming 
        Their values are 0:OFF, 1:ON
        
        'disassociate': Disassociate to the AP the client is leaving (to a roam AP)
        'deauth':  Deauthenticate to the AP the client is leaving (to a roam AP)

        'reassoc': Use reassociate message rather than associate when associating 
                   to a roam AP (an AP roamed to)
        'renewDHCPonConn': Renew DHCP on reconnection
        'renewDHCP': Renew DHCP on roam
        'preauth': Pre-authenticate the clients to the APs they might roam to
        'pmkid': PMKID caching enbled
        """
        testOptions = {
                        'flowRate': 100,
                        'flowPacketSize': 256,
                        'repeatType': 'Repeat',
                        'durationUnits':0,
                        'repeatValue': 2,
                        'learningFlowFlag': 1,
                        'learningPacketRate': 100, 
                        'renewDHCPonConn': 0, 
                        'renewDHCP': 0,
                        'preauth': 0, 
                        'reassoc': 0, 
                        'deauth': 0, 
                        'disassociate': 0, 
                        'pmkid': 0, 
                       }
        """
        Security Options is dictionary of passed security parameters.  
        It has a mandatory key of 'Method' and optional keys depending 
        upon the particular security chose.  Some common one shown in the 
        code below:
        """
        self.Security_Eth_None = {'Method': 'None'}
        
        self.Security_WPA_PSK = {
                                 'Method': 'WPA-PSK',
                                'AnonymousIdentity': 'anonymous', 
                                'NetworkAuthMethod': 'PSK', 
                                'KeyType': 'ascii', 
                                'EnabeValidateCertificate': 'on', 
                                'KeyWidth': '', 
                                'EncryptionMethod': 'TKIP', 
                                'RootCertificate': '', 
                                'AputhMethod': 'Open', 
                                'LoginFile': '', 
                                'KeyId': '1', 
                                'ClientCertificate': '', 
                                'StartIndex': '1', 
                                'PrivateKeyFile': '', 
                                'LoginMethod': 'Single', 
                                'NetworkKey': 'whatever', 
                                'Password': 'whatever', 
                                'Identity': 'anonymous'
                                }         
        self.Security_None = {    'Method': 'None'}  
        
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
          'Disassoc_before_reassoc' : <0/1> (0:OFF, 1:ON)
          'Reassoc_when_roam' : <0/1> (0:OFF, 1:ON)
          'pmkid_cache' : <0/1> (0:OFF, 1:ON)
          'Deauth_before_roam' : <0/1> (0:OFF, 1:ON)
          'PreAuth' : <0/1> (0:OFF, 1:ON)
          'renewDHCPonConn': <0/1> (0:OFF, 1:ON)
          'renewDHCP': <0/1> (0:OFF, 1:ON)
        """
        self.NetworkList = {
                            'Group_1security': 
                                        {'ssid': 'None',
                                         'security': self.Security_Eth_None, 
                                         'bssid': 'None'
                                        }, 
                            'Security1': 
                                        {'ssid': 'Open-2',
                                         'security':self.Security_None,
                                         'otherflags': 
                                                    {'Disassoc_before_reassoc': testOptions['disassociate'], 
                                                     'Deauth_before_roam': testOptions['deauth'], 
                                                     'pmkid_cache': testOptions['pmkid'], 
                                                     'renewDHCPonConn': testOptions['renewDHCPonConn'], 
                                                     'PreAuth': testOptions['preauth'], 
                                                     'Reassoc_when_roam': testOptions['reassoc'], 
                                                     'renewDHCP': testOptions['renewDHCP']
                                                     }
                                        },
                                        
                           'Aruba': {'ssid': 'aruba',
                                     'security': self.Security_WPA2,
                                     'otherflags' : {}},

                           'EthNetwork':     {
                                              'security':self.Security_None
                                              }
                           }

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
                        associate clients with the SUT. This includes the time 
                        required to complete .1X authentications.  
                        Units: associations/second.
        AssociateTimeout -  Amount of time the test will wait for a client 
                            association to complete before considering iteration 
                            a failed connection. Units: seconds; 
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
                            primary test results. This file will be in CSV format. 
                            This name can include a path as well. 
                            Otherwise the file will be placed at the location of 
                            the calling program. 
        SavePCAPfile -      Boolean True/False value. If True a PCAP file will 
                            be created containing the detailed frame data that 
                            was captured on each WT-20/90 port. 
        """
        self.CSVfilename      = 'Results_roaming_benchmark.csv'
        self.ReportFilename   = 'Report_roaming_benchmark.pdf'
        self.DetailedFilename = 'Detailed_roaming_benchmark.csv'
        self.RSSIfilename     = 'RSSI_roaming_benchmark.csv'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False


        """
        self.roamRate : The number of roams in the SUT per second.
        """ 
        self.roamRate = 1.0
        
        self.roamInterval = 1/self.roamRate
        
        """
        self.roamFlowMappings: This contains the list of lists, with each inner 
                                list being of length 2, with first item as source 
                                group sending traffic to the second item the name 
                                of the destination group receiving traffic
        """
        self.roamFlowMappings = [['Group_1', 'Group_2']]
        
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
        'srcPort': Source Port of the flow. Type<String>
        'destPort': Destination Port of the flow. Type<String>
        MainFlowlist -  The list of flows that would be attached to a 
                        clientgroup as the main traffic pattern for the clientgroup. The
                        traffic will flow from Ethernet client to the Wireless clients in
                        the clientgroup.
        """
        self.MainFlowlist = {
                            'Flow1': 
                                 {'Type': 'UDP',
                                  'Intendedrate': testOptions['flowRate'], 
                                  'Framesize': testOptions['flowPacketSize'], 
                                  'Phyrate': 54.0, 
                                  'Numframes': WE.MAXtxFrames,
                                  'srcPort': '8000', 
                                  'destPort': '69',
                                  'Ratemode': 'pps'
                                  }
                            }

        #Some Misc computations
        testTypeVal = testOptions['repeatValue']
        if testOptions['repeatType'] == 'Duration':
            durationUnits = testOptions['durationUnits']
            if durationUnits == 1: #minutes
                testTypeVal *= 60
            elif durationUnits == 2: #hours
                testTypeVal *= 3600
            self.totalduration = testTypeVal

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
          'TestType' : <'Repeat'/'Duration'> - If 'Repeat', then the roams
                      will be repeated across all ports for 'val' number of times.
                      If 'Duration', then the roams will be executed for 'val' 
                      period of time iterating through the port list.
          'TestTypeValue' : <repeatcount/duration value> - Type: float/integer.
                          This value is interpreted on the basis of roam_testtype config.
          'ClientDistr' : <True>. The clients always will be evenly distributed 
                          across all the available ports. 
          'TimeDistr' : <'even'> - Type: string. Always 'even', 
                      the roam events of all the clients will be distributed 
                      evenly across the given dwell time. 
         """ 
        self.Roamlist = {
                         'Roam1': 
                                 {
                                  'PortList': ['WT90_W1', 'WT90_W2'],
                                  'BSSIDList': ['00:15:c6:28:c2:31', '00:13:c4:0d:70:11'],
                                  'DwellTime': [self.roamInterval, self.roamInterval],
                                  'TesttypeValue': testTypeVal, 
                                  'TestType': testOptions['repeatType'],
                                  'TimeDistr': 'even',
                                  'ClientDistr': True
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
        'MACIncrMode': <'INCREMENT'/'DECREMENT'>
        'MACStep'   : Change step in the direction specified through 'MACIncrMode'
        'StartIP'  : The IP address of the first client in the group.
        'IPStep': Specify which of the bytes have to be incremented and by how much 
                    Type <String>
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
        'ClientLearning': <'on' / 'off'> Whether Client Learning is to be ON or OFF
        LearningRate - The client learning rate 
        'AssocProbe': Probe before associate- either do not send probe request 
                    ('None') or send probe request (either 'Unicast' or 'Broadcast')
        'VlanEnable': <'True'/ 'False'>,
        'VlanUserPriority': 0-7, 
        'VlanCfi': Should the CFI bit be set. Type <Boolean> 
        'VlanId': Type <Integer>
        'QoSFlag': Should QoS flag be set. Type <Boolean>
        """
        self.Clientgroups = {
                            'Group_2': 
                                 {'Enable': True, 
                                  'StartMAC'  : 'ae:ae:ae:00:00:01',
                                  'MACIncrMode'   : 'INCREMENT',
                                  'MACStep'   : 1,
                                  'StartIP': '192.168.1.11',
                                  'IPStep': '0.0.0.1', 
                                  'Gateway': '192.168.1.1', 
                                  'SubMask': '255.255.255.0', 
                                  'NumClients': 1, 
                                  'Security': 'Security1', 
                                  'Roamprof': 'Roam1', 
                                  'MainFlow': 'Flow1',
                                  'ClientLearning': 'on',
                                  'LearningRate': 100, 
                                  'AssocProbe': 'Unicast',
                                  'MgmtPhyRate': 6.0, 
                                  'GratuitousArp': 'True', 
                                  'ProactiveKeyCaching': 'False', 
                                  }
                            } 
                    
        self.nonRoamGroups = {
                              'Group_1': {'Enable'    : True,
                                         'StartMAC'  : '50:40:30:20:10:aa',
                                         'MACIncrMode'   : 'INCREMENT',
                                         'MACStep'   : 1,
                                         'StartIP'   : '192.168.1.100',
                                         'IPStep'    : '0.0.0.1',
                                         'Gateway'   : '192.168.1.1',
                                         'SubMask'   : '255.255.255.0',
                                         'Port'      : 'WT90_E1',
                                         'Interface' : '802.3',
                                         'Security'  : 'Group_1security',
                                         'NumClients': 1,
                                         'VlanEnable': 'True',
                                         'VlanUserPriority': 0, 
                                         'VlanCfi': True, 
                                         'VlanId': 2,
                                         'QoSFlag'   : True,
                                         'Dhcp'      : 'Disable',
                                         'MgmtPhyRate': '6', 
                                         'GratuitousArp': 'True', 
                                         'Interface': '802.3 Ethernet', 
                                         'PhyRate': '54'
                                        }
                            }


# ---------------- End of User configuration ------------- 

#Data Structure manipulation based on the user configuration above

        self.testKey = 'roaming_benchmark'
        self.testName = 'Roaming Benchmark'
        
        #self.dummyClientGroupNumsDict, self.dummyRoamBenchDict need
        #to be populated for the script to run on its own (rather than as module)
        self.dummyClientGroupNumsDict = {}
        for group in self.Clientgroups:
            self.dummyClientGroupNumsDict[group] = self.Clientgroups[group]['NumClients']

        groupRoamInfo = {}
        for group in self.Clientgroups:
            groupRoamInfo[group] = {'portNameList': 
                                        self.Roamlist[self.Clientgroups[group]['Roamprof']]['PortList'],
                                    'ssid':
                                        self.NetworkList[self.Clientgroups[group]['Security']]['ssid'],
                                    'bssidList':
                                        self.Roamlist[self.Clientgroups[group]['Roamprof']]['BSSIDList']
                                            
                                    }
        #This data structure is the same as 
        self.dummyRoamBenchDict = { 'roamRate': 1/self.roamInterval,  
                                    'roamTraffic': self.roamFlowMappings,
                                    'dwellTime': self.roamInterval,
                                    'backgroundTraffic': [], 
                                    'powerProfileFlag': 0,
                                    
                                    }
        
        self.dummyRoamBenchDict.update(testOptions)
        #Repeat type should be int
        if testOptions[ 'repeatType'] == 'Duration':
            self.dummyRoamBenchDict['repeatType'] = 1
        elif testOptions[ 'repeatType'] == 'Repeat':
            self.dummyRoamBenchDict['repeatType'] = 2
            
        self.dummyRoamBenchDict.update(groupRoamInfo)

#----------------------------------------------------------------------------------------
        self.graphPlotInterval = 1.0
        self.roamSourcePorts = {}
        self.nonRoamClientGroups = {} 
        self.roamTrafficSource = {}
        
    def getTestName(self):
    
        return 'roaming_benchmark'
    
    def getInfo(self):
        msg = "The Roaming Benchmark test determines the number of roams per unit of time that the WLAN controller can support. The test reports the roam delay, failed roams and packet loss for a particular roam rate for the specified configuration. Unique roaming patterns can be specified for each network (SSID). Within the network, the client groups follow a predefined roaming pattern."
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
            security = (CGconfig.Getsecurity())['Method']
            if security.upper() == 'NONE':
                security = 'Open'
            Config = dict([('Network', CGconfig.Getssid()),
                           ('Security' , security),
                           ('#Clients', CGconfig.numclients),
                           ('Roam Sequence', roamList)])               
            datatrafficStr = ''
            if CGname in self.Clientgroups.keys():
                flowname = self.Clientgroups[CGname]['MainFlow']
                if flowname in self.MainFlowlist.keys():
                    flowConfig = self.MainFlowlist[flowname]
                    datatrafficStr += str(flowConfig['Framesize']) + 'Byte '
                    datatrafficStr += flowConfig['Type']
                    datatrafficStr += ' ' + str(flowConfig['Intendedrate']) + 'pps '
                    Config['Data Traffic'] = datatrafficStr
            Config['Traffic Source'] = self.roamTrafficSource[CGname]
            
            ConfigSummary[CGname] = Config
        #Pick a groups test period
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            CGconfig = self.Clientgroup[CGname]
            testPeriodType = CGconfig.Gettesttype()
            testTypeVal = int(CGconfig.GettesttypeValue())
            if testPeriodType == 'Repeat':
                testPeriod = '%d Cycles'%testTypeVal
            elif testPeriodType == 'Duration':
                val, units = self.computeTimeValueAndUnits(testTypeVal)
                testPeriod = '%d %s'%(val, units)
            break
        testSpecificConfig = {}
        testSpecificConfig['Test Period'] =  testPeriod
        testSpecificConfig['SUT Roam Rate'] = 1/self.roamInterval
        
        ConfigSummary['Test Config'] = testSpecificConfig
        
        return ConfigSummary
    
    def insertTestConfigIntoReport(self, configSummary):
        roamSummary = [('Group', 'Network', 'Security', '#Clients',
                        'Roam Sequence' , 'Traffic Source', 'Traffic Data')] 
        columnsList = [0.65*inch, 1*inch, 1.0*inch, 0.5*inch, 2.5*inch, 
                       0.65*inch, 0.75*inch]
        for CG in [x for x in configSummary.keys() if x != 'Test Config']:
            Config = configSummary[CG]
            resultTuple = (CG, Config['Network'], Config['Security'], 
                           Config['#Clients'], Config['Roam Sequence'],
                           Config['Traffic Source'], 
                           Config['Data Traffic'])
            roamSummary.append(resultTuple)
        
        self.MyReport.InsertDetailedTable(roamSummary, columns = columnsList)
        
        testSpecificConfig = [('Test Time', 'SUT Roam Rate')]
        testSpecificConfig.append((configSummary['Test Config']['Test Period'],
                                   configSummary['Test Config']['SUT Roam Rate']))
        self.MyReport.InsertDetailedTable(testSpecificConfig, [1.25*inch, 2.0*inch])
        
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
        #Adds a 'CGgroupname': ClientGroupObject (from RoamBenchmarkEventClass) 
        self.Clientgroup[name] = RoamBenchmarkEventClass.RoamBenchClientGroup(name, 
                base_mac, base_ip, gateway, subnetmask, numclients, ipIncr,
                macIncr, assocProbe, self.NetworkList[network]['ssid'], 
                self.NetworkList[network]['security'],
                self.NetworkList[network]['otherflags'])
    
    def CGGenclients(self):
        retList = []
        (cgWaitTimes, groupTestTime) = computeWaitTimes(self.roamInterval, self.dummyRoamBenchDict, self.dummyClientGroupNumsDict)
        maxSplitTime = 1800
        grpTestTime = -1
        CGnameList = self.Clientgroup.keys()
        CGnameList.sort()    #Make sure we do not shuffle the starttime of the clientgroups
        for CGname in  CGnameList:
            if groupTestTime.has_key(CGname):
                grpTestTime = groupTestTime[CGname]
            retVal = self.Clientgroup[CGname].splitGenClients(maxSplitTime, cgWaitTimes, self.roamInterval, grpTestTime)
            retList.append(retVal)
        return retList

    def Generateclients(self):
        #For each CGobject, RoamBenchmarkEventClass generates a list of 
        #Client objects. This is stored as a dictionary of form
        #'clientname': ClientObject. This dictionary can be 
        #retrieved for each CGobject with GetClientdict() method.
        max_test_time = 0
        grpTestTime = -1
        (cgWaitTimes, groupTestTime) = computeWaitTimes(self.roamInterval, self.dummyRoamBenchDict, self.dummyClientGroupNumsDict)
        for CGname in self.Clientgroup.keys():
            if groupTestTime.has_key(CGname):
                grpTestTime = groupTestTime[CGname]
            total_roam_time = self.Clientgroup[CGname].Generateclients(cgWaitTimes, self.roamInterval, grpTestTime)
            if total_roam_time > max_test_time:
                max_test_time = total_roam_time
        self.SetTotalDuration(max_test_time)

    def CreateRoamprofile(self, name, roamlist, clientdistrflag, 
                          timedistr,  testType, testTypeValue, portbssidMapList):
        self.Roamprofiles[name] = RoamBenchmarkEventClass.RoamProfile(roamlist,
                                                                      clientdistrflag,
                                                                      timedistr,
                                                                      portbssidMapList,
                                                                      testType,
                                                                      testTypeValue)
        
    #self.AddFlow(groupname, mainflow, learnflow)
    def createFlows(self, roamFlowObjects):
        #Create flows for Roam Groups
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        learnflowprof = None
        for groupName in groupnames:
            flowprof = roamFlowObjects[groupName]["mainflow"]
            learnflowprof = roamFlowObjects[groupName]["learnflow"]
            roamTrafficSrc = self.roamTrafficSource[groupName]
            #We allow only one Eth client, in which case waveEngine gives the client the 
            #group's name
            srcGroupName = srcClientName = roamTrafficSrc
            roamTrafficSrcDict = {srcClientName: self.nonRoamClientGroups[srcGroupName][srcClientName]}
            #Create a dictionary self.roamSourcePorts {GroupName: PortName} portName is the port
            #from which traffic is sent for the roam group 'GroupName'
            self.roamSourcePorts[groupName] = self.nonRoamGroups[srcGroupName]['Port']
            
            if flowprof == None:
                self.Print("No Flow profile for Clientgroup %s\n" % groupName,\
                        'ERR')
                return
            if groupName not in self.ClientgrpClients.keys():
                self.Print("No clients found in Clientgroup %s\n" % groupName,\
                        'ERR')
                return
    
            ListofClientdict = self.ClientgrpClients[groupName]
            self.ClientgrpFlows[groupName] = flowprof
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
            #
            #
            Flowdict = WE.CreateFlows_PartialMesh(roamTrafficSrcDict,
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
                        roamTrafficSrcDict, False, FlowOptions)
                for flowname in LearnFlowdict.keys():
                    srcclientname = LearnFlowdict[flowname][1]
                    dstclientname = LearnFlowdict[flowname][3]
                    clientdict = self.Clientgroup[groupName].GetClientdict()
                    if srcclientname in clientdict.keys():
                        flowparams = RoamBenchmarkEventClass.Flowparams()
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
    
    
    def checkRoamOppurtunities(self):
        """
        
        Verify if all the Wlan clients would get an oppurtunity to roam. 
        """ 

        #Find the test type (check any one group's testType)
        aCgName = self.Clientgroup.keys()[0]
        testType = self.Clientgroup[aCgName].Gettesttype()
        if testType == 'Duration':
            if (self.totalRoamClients * self.roamInterval) > self.totalduration:
                 self.Print("Warning: Not All the Wlan Clients would get the oppurtunity to roam with the configured test duration and roam rate.\n", 'WARN')
         
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

    def getEventGenerator(self):
        return RoamBenchmarkEventClass.Eventgenerator()
    
    def configureFlows(self):
        #Flows for the roaming clients
        roamFlowObjects = {}
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        for groupname in groupnames:
            roamFlowObjects[groupname] = {}
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

            mainflow = self.Flow(pkttype, framesize, phyrate, ratemode,
                    intendedrate, numframes, SourcePort = srcPort, DestinationPort = destPort,
                    IcmpType = type, IcmpCode = code)
            
            roamFlowObjects[groupname]["mainflow"] = mainflow
            
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

            roamFlowObjects[groupname]["learnflow"] = learnflow
            
        #Create a dictionary: groupName -> TrafficSource to be used in createFlows
        #Create a dictionary of 
        tmpGroupList = []

        for flowMap in self.roamFlowMappings:
            if self.roamTrafficSource.has_key(flowMap[1]):
                self.Print("At least two Sources are sending traffic to the roam group %s" %flowMap[1], 'Err')
                raise WE.RaiseException
            else:
                self.roamTrafficSource[flowMap[1]] = flowMap[0]
                        
        return roamFlowObjects
    
    def getRoamedClientList(self):
        return RoamBenchmarkEventClass.getRoamedClientList()
    
    def getClientData(self):
        return RoamBenchmarkEventClass.getClientStats()
    
    def getLastRoamDetails(self, clientName):
        return RoamBenchmarkEventClass.getLastRoamDetails(clientName)
    
    def _loadTestKeyAndName(self):
        self.testKey = 'roaming_benchmark'
        self.testName = 'Roaming Benchmark'
    
    def _getCommonRoamOptions(self):
    
        commonRoamOptions = ['deauth', 'preauth', 'disassociate', 'dwellTime',
                             'pmkid', 'learningFlowFlag','reassoc', 
                             'flowPacketSize', 'flowRate', 'durationUnits',
                             'learningPacketRate', 'repeatValue', 'repeatType',
                             'renewDHCP','renewDHCPonConn', 'powerProfileFlag']
        return commonRoamOptions
    
    def _updateClientGroupProfile(self, roaming_data):
        self._updateCGProfLFlowFlag(roaming_data)
        
    #The name 'nonRoamGroups' is misleading because self.nonRoamGroups is now (release 2.4)
    #Eth groups only, it was created when the app design included wlan group which would 
    #be stationary (i.e., not roam). Due to the time constraints not making changes to the 
    #variables & methods with the term 'nonRoam' as part of their name, make the changes
    #after the release
    def run(self):
        try:
            self.ExitStatus = 0
            WE.setPortInfo({})
            WE.setPortBSSID2SSID({})
            WE.OpenLogging(Path = self.LoggingDirectory,
                    Detailed = self.DetailedFilename)
            self.setRealtimeCallback(self.PrintRealtimeStats)
            RoamBenchmarkEventClass.clearStats()
            self.ConfigureData()
            self.totalRoamClients = self.getTotalRoamClients()
            self.generateClientConfig()
            self.validateInitialConfig()
            self.configurePorts()
            self.initailizeCSVfile()
            #Create and connect Eth Clients
            clientTuples = self.createNonRoamClientTuple(self.nonRoamGroups)
            (self.nonRoamClientGroups,
             clientList)             = self.createNonRoamClients(clientTuples)
            self.connectNonRoamClients(clientList)
            #Create and Connect Roam Clients
            allClientsDict = self.createAndConnectRoamClients(False)
            self.writeAPinformation(allClientsDict)            
            roamFlowObjects = self.configureFlows()
            self.createFlows(roamFlowObjects)
            self._configureClientObjectsFlows(self.FlowList)
            if self.createFlowGroups() == -1:
                raise WE.RaiseException
            self.setNATflag() 
            self.doAllArpExchanges()
            self.checkRoamOppurtunities()
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
