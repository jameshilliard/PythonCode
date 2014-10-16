# Imports
from vcl import *
from basetest import *
import RoamServiceQualityEventClass as RSQEC
#import roambenchmark
from roamLib import computeWaitTimes
import WaveEngine
from roaming_common import RoamingCommon 
from roamBenchCommon import RoamBenchCommon
from qos_common import setToS, setVoipPorts,  configureQoS
from CommonFunctions import *
import Qlib
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
import Queue
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
__metaclass__ = type

class Test(RoamBenchCommon, RoamingCommon, BaseTest):
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

        'repeatType':   Value is always 'Duration'
        'durationUnits': Values- 0: Seconds, 1: Minutes, 2:Hours
        'repeatValue':  This specifies the amount of time or number of cycles depending
                        on the 'repeatType'
                        Type- Positive Integer
        
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
                        'repeatType': 'Duration',
                        'durationUnits':0,
                        'repeatValue': 2,
                        'renewDHCPonConn': 0, 
                        'renewDHCP': 0,
                        'preauth': 0, 
                        'reassoc': 0, 
                        'deauth': 0, 
                        'disassociate': 0, 
                        'pmkid': 0, 
                       }
        
        """
        callTrafficOptions:    Holds the options for the VoIP flows
        
        voipCodec:          The codec of the VoIP flow 
                            Values: G.711, G.723, G.729
                            
        baseCallDurationUnits: The time units for the duration specified for Basecall
                                    0: seconds, 1:Minutes, 2: Hours
        baseCallDurationVal:    The time value of the Basecall
        
        callDropDelayThreshold: The roam delay threshold above which, the roam would
                                be considered as resulting in dropped call
                                
        DestPort:            Destination port of the VoIP flow
        SrcPort:             Source port of the VoIP flow
        
        QoSEnabled:        Specifies whether QoS should be enabled in the VoIP flows
                           'True': Yes, 'False': No
        UserPriority:      Userpriority field value, valid only when QoSEnabled is 'True'
          
        Type of Service field options:
        
        ToSField:          Values:  'Routine', 'Priority', 'Immediate', 'Flash', 
                                    'Flash Override', 'CRITIC/ECP', 'Internet Control',
                                    'Network Control'
        TosLowDelay, TosHighTroughput, TosHighReliability, TosLowCost, TosReserved:
                        Type: Boolean, Values: True, False
        
        TosDiffservDSCP:  If the DSCP field is set, value is integer, if not value is
                            'Default'
        """
        self.callTrafficOptions = {
                                  'voipCodec': 'G.711',
                                  'baseCallDurationUnits': 0,
                                  'baseCallDurationVal': 5, 
                                  'callDropDelayThreshold': '50', 
                                  
                                  'DestPort': 5003,
                                  'SrcPort': 5004, 
                                  
                                  'QoSEnabled': 'True', 
                                  'UserPriority': 7, 
                                  
                                  'TosField': 'Routine',
                                  'TosLowDelay': False, 
                                  'TosHighThroughput': False,
                                  'TosHighReliability': True,
                                  'TosLowCost': True,
                                  'TosReserved': False,
                                  'TosDiffservDSCP': 'Default' 
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
        self.UserPassFailCriteria = {}
        self.UserPassFailCriteria['user']='False'
        self.FinalResult=0

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
        self.CSVfilename      = 'Results_voip_roam_quality.csv'
        self.ReportFilename   = 'Report_voip_roam_quality.pdf'
        self.DetailedFilename = 'Detailed_voip_roam_quality.csv'
        self.RSSIfilename     = 'RSSI_voip_roam_quality.csv'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False


        """
        self.roamRate : The number of roams a  client roams per minute.
        """ 
        self.roamRate = 10.0
        
        self.roamInterval = 60/self.roamRate
        
        """
        self.roamFlowMappings: This contains the list of lists, with each inner 
                                list being of length 2, with first item as Etherne group 
                                engaging in VoIP traffic flow to the second item which is
                                the name of the WLAN group engaged in other end of 
                                the VoIP traffic
        """
        self.roamFlowMappings = [['Group_1', 'Group_2']]
        
        """
        Some Misc computations.
        These parameters need not be configured
        """
        self.MainFlowlist = {
                    'Flow1': 
                         {'Type': self.callTrafficOptions['voipCodec'], 
                          'Phyrate': 54.0, 
                          'Numframes': WaveEngine.MAXtxFrames,
                          'srcPort': self.callTrafficOptions['SrcPort'], 
                          'destPort': self.callTrafficOptions['DestPort'],
                          'Ratemode': 'pps'
                          }
                    }
        testTypeVal = testOptions['repeatValue']

        durationUnits = testOptions['durationUnits']
        if durationUnits == 1: #minutes
            testTypeVal *= 60
        elif durationUnits == 2: #hours
            testTypeVal *= 3600
        self.totalduration = int(testTypeVal)

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

        self.testKey = 'voip_roam_quality'
        self.testName = 'Roaming Service Quality'
        
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

        self.dummyRoamBenchDict['repeatType'] = 1
            
        self.dummyRoamBenchDict.update(groupRoamInfo)

        self.baseCallDurationVal = self.callTrafficOptions['baseCallDurationVal']
        if self.callTrafficOptions['baseCallDurationUnits'] == 1: #minutes
            self.baseCallDurationVal *= 60
        elif self.callTrafficOptions['baseCallDurationUnits'] == 2: #hours
            self.baseCallDurationVal *= 3600
        self.setCallDropDelayThreshold(self.callTrafficOptions['callDropDelayThreshold'])

                                      
#----------------------------------------------------------------------------------------
        
        self.roamSourcePorts = {}
        self.nonRoamClientGroups = {} 
        self.roamTrafficSource = {}
        self.graphPlotInterval = 1.0
        self.flowsToClientDict = {}
        self.flowsFromClientDict = {}
        self.LearnFlowList = {}
        
    def getTestName(self):
        
        return 'voip_roam_quality' 
     
    def getInfo(self):
        msg = "The Roaming Service Quality test determines the effect of roaming on call quality as measured by the R-value and dropped calls. The test measures the anticipated drop in call quality when wireless clients begin to roam from one AP to another."

        return msg
    
    def generateConfigSummary(self):
        CGnames = self.Clientgroup.keys()
        CGnames.sort()
        configSummary = {}
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
            Config['Traffic Source'] = self.roamTrafficSource[CGname]
            
            configSummary[CGname] = Config
        
        testSpecificConfig = {}
        #Pick a groups' test period
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
        testSpecificConfig['Test Period'] =  testPeriod    
        #VoIP codec is same for all the groups, pick a group and get its flow 'Type'
        for CGname in CGnames:
            if CGname in self.InvalidClientgrps:
                continue
            if CGname in self.Clientgroups.keys():
                flowname = self.Clientgroups[CGname]['MainFlow']
                if flowname in self.MainFlowlist.keys():
                    flowConfig = self.MainFlowlist[flowname]
                    voipCodec = flowConfig['Type']
                    break

        totalClients = 0
        for group in self.dummyClientGroupNumsDict:
            totalClients += self.dummyClientGroupNumsDict[group]
        testSpecificConfig['Client Roam Rate'] = (60/self.roamInterval)
        testSpecificConfig['SUT Roam Rate'] = totalClients * testSpecificConfig['Client Roam Rate']    
        testSpecificConfig['Test Duration'] = testPeriod
        testSpecificConfig['VoIP Codec'] = voipCodec
        testSpecificConfig['Call Drop Delay Threshold'] = "%s msecs"%RSQEC.getCallDropDelayThreshold()
        val, units = self.computeTimeValueAndUnits(self.baseCallDurationVal)
        testSpecificConfig['Baseline Call Duration'] = '%d %s'%(val, units)   
        
        configSummary['Test Config'] = testSpecificConfig
        
        return configSummary

    def getDetailedLogColumnNames(self):
        tmpStr = "Client Group, Network, Client Name, Flow Direction, Flow Name, \
                      R-Value, R-Value snapshot Time, Previous Roam Time, \
                      Previous Roam: Source Port--BSSID, \
                      Previous Roam: Destination Port--BSSID, AP Roam Delay, \
                      Total Roam Delay, Client Delay, \
                      Probe Request Timestamp, Probe Response Timestap, \
                      AP Probe Response Delay, 802.11 Auth Request Timestamp, \
                      802.11 Auth Response Timestamp, AP 802.11 Auth Delay, \
                      WEP Auth Request Timestamp, WEP Auth Response Timestamp, \
                      AP WEP Auth Delay, Assoc Request Timestamp, \
                      Assoc Response Timestamp, AP Assoc Delay, \
                      EAP ReqIdentity Timestamp, EAPOL Group Key Timestamp, Auth Time"
        columnNamesStr = self.stripLeftAndRight(tmpStr) 
        
        return columnNamesStr
         
    def CreateClientgroup(self, name, base_mac, base_ip, gateway, subnetmask, 
            numclients, network, ipIncr, macIncr, assocProbe):
        if network not in self.NetworkList.keys():
            self.Print("Security profile %s not found\n" % network, 'ERR')
            return
        secClass = self.getSecClass(self.NetworkList[network]['security']['Method'])
        #Adds a 'CGgroupname': ClientGroupObject (from RoamServiceQualityEventClass) 
        self.Clientgroup[name] = \
        RSQEC.RoamServiceQualityClientGroup(name, base_mac, base_ip,
                                            gateway, subnetmask, 
                                            numclients, ipIncr,
                                            macIncr, assocProbe, 
                                            self.NetworkList[network]['ssid'],
                                            self.NetworkList[network]['security'],
                                            self.NetworkList[network]['otherflags'],
                                            secClass)
    
    def CGGenclients(self):
        retList = []
        initialWaitTime = 0
        groupStartWait = {}
        CGnameList = self.Clientgroup.keys()
        CGnameList.sort()    #Make sure we do not shuffle the starttime of the clientgroups

        roamIntervalBetweenClients = (self.roamInterval/float(self.totalRoamClients))
        
        for CGname in  CGnameList:
            numClients = self.Clientgroups[CGname]['NumClients']
            groupStartWait[CGname] = initialWaitTime
            initialWaitTime += (numClients * roamIntervalBetweenClients)

        clientDwellTime = self.roamInterval

        
        maxSplitTime = 1800
        for CGname in  CGnameList:
            retVal = self.Clientgroup[CGname].splitGenClients(maxSplitTime, 
                                                              groupStartWait[CGname],
                                                              roamIntervalBetweenClients, 
                                                              clientDwellTime,
                                                              self.totalduration)
            retList.append(retVal)
        return retList

    def Generateclients(self):
        #For each CGobject, RoamServiceQualityEventClass generates a list of 
        #Client objects. This is stored as a dictionary of form
        #'clientname': ClientObject. This dictionary can be 
        #retrieved for each CGobject with GetClientdict() method.
        max_test_time = 0

        initialWaitTime = 0
        groupStartWait = {}
        CGnameList = self.Clientgroup.keys()
        CGnameList.sort()    #Make sure we do not shuffle the starttime of the clientgroups

        roamIntervalBetweenClients = (self.roamInterval/float(self.totalRoamClients))
        
        for CGname in  CGnameList:
            numClients = self.Clientgroups[CGname]['NumClients']
            groupStartWait[CGname] = initialWaitTime
            initialWaitTime += (numClients * roamIntervalBetweenClients)

        clientDwellTime = self.roamInterval
        
        for CGname in CGnameList:
            total_roam_time = self.Clientgroup[CGname].Generateclients(groupStartWait[CGname],
                                                                       roamIntervalBetweenClients, 
                                                                       clientDwellTime,
                                                                       self.totalduration)
            if total_roam_time > max_test_time:
                max_test_time = total_roam_time
        self.SetTotalDuration(max_test_time)

    def CreateRoamprofile(self, name, roamlist, clientdistrflag, 
                          timedistr,  testType, testTypeValue,
                          portbssidMapList):
        self.Roamprofiles[name] = RSQEC.RoamProfile(roamlist, 
                                                    clientdistrflag,
                                                    timedistr,
                                                    portbssidMapList, 
                                                    testType,
                                                    testTypeValue) 
    
    def createFlowGroups(self):
        if len(self.FlowList) > 0:
            self._createFlowGroup(self.FlowList, "XmitGroup")
        else:
            self.Print("No main transmit flows created\n", 'ERR')
            return -1
        #Create temporaryFlowGroup which holds the flow that needs to be
        #reinitiated
        self._createFlowGroup({}, "tmpFlowGroup")
            
    #self.AddFlow(groupname, mainflow)
    def createFlows(self, roamFlowObjects):
        #Create flows for Roam Groups
        groupnames = self.Clientgroups.keys()
        groupnames.sort()
        srcCGFlows = []
        dstCGFlows = []
        for groupName in groupnames:
            flowprof = roamFlowObjects[groupName]["mainflow"]
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
            
            #Flow options are not group specific, take them out of the loop
            self.ClientgrpFlows[groupName] = flowprof
            FlowOptions = self.FlowOptions.copy() # VPR 2983   {}
            FlowOptions['Type'] = flowprof.Type
            FlowOptions['PhyRate'] = flowprof.PhyRate
            FlowOptions['IntendedRate'] = flowprof.IntendedRate
            FlowOptions['NumFrames'] = flowprof.NumFrames
            #FlowOptions['TosField'] = 0

            Flowdict = WaveEngine.CreateFlows_PartialMesh(roamTrafficSrcDict,
                                                          ListofClientdict, 
                                                          True, FlowOptions)

            for flowName in Flowdict.keys():
                self.FlowList[flowName] = Flowdict[flowName]
                if Flowdict[flowName][1] in roamTrafficSrcDict:
                    srcCGFlows.append(flowName)
                elif Flowdict[flowName][1] in ListofClientdict:
                    dstCGFlows.append(flowName)
                    
            #Create a dict {GroupName{ClientName: UplinkFlowName}}
            self.createClientToUpflowDict(groupName)
            
            WaveEngine.ModifyFlows(Flowdict, {'Type': flowprof.Type})
    

        return (srcCGFlows, dstCGFlows)
    
    def createClientToUpflowDict(self,groupName):
        clientList = (self.Clientgroup[groupName].GetClientdict()).keys()
        #Initialisation
        self.flowsToClientDict[groupName] = {}
        self.flowsFromClientDict[groupName] = {}
            
        clientList = self.ClientgrpClients[groupName].keys()
        for clientName in clientList:
            self.flowsFromClientDict[groupName][clientName] = []
            self.flowsToClientDict[groupName][clientName] = []
            
        for flowName in self.FlowList:
            srcClientName = self.FlowList[flowName][1]
            destClientName = self.FlowList[flowName][3]
            if srcClientName in clientList:
                self.flowsFromClientDict[groupName][srcClientName].append(flowName)
            if destClientName in clientList:
                self.flowsToClientDict[groupName][destClientName].append(flowName)
    
    def addClientFlows(self):
        #We iterate over the groupNames in self.flowToClientDict, assumption is
        #flowToClientDict, flowFromClientDict have same structure
        for groupName in self.flowsToClientDict:
            flowsToClientDict = self.flowsToClientDict[groupName]
            flowsFromClientDict = self.flowsFromClientDict[groupName]
            self.Clientgroup[groupName].AddFlowsFromClient(flowsFromClientDict)
            self.Clientgroup[groupName].AddFlowsToClient(flowsToClientDict)
    
    def initialiseGlobalgClients(self):
        for groupName in self.flowsToClientDict:
            flowsToClientDict = self.flowsToClientDict[groupName]
            flowsFromClientDict = self.flowsFromClientDict[groupName]
            self.Clientgroup[groupName].initialisegClientsDicts(flowsFromClientDict,
                                                                flowsToClientDict)
    def setCallDropDelayThreshold(self, delayThreshold):
        RSQEC.setCallDropDelayThreshold(delayThreshold)
        
    def givePeriodicStatusUpdates(self, totalTime, dummyPrintInterval, printInterval = 1, 
                                  msg = '', noMsgF = False):
        """
        dummyPrintInterval is the time interval (in secs) at which an empty 
        string ('') is to be printed to avoid GUI freezing effect. printInterval 
        is the times (secs) at which the message 'msg' is to be printed. 
        'totalTime' is the total time for which this method needs to run.
        It is assumed that printInterval generally is a multiple of
        dummyPrintInterval
        """
        #Error check
        if dummyPrintInterval == 0:
            dummyPrintInterval = 0.1
        
        if printInterval < dummyPrintInterval:    #Shouldn't happen
            return
        
        i = 0

        sleepSlots = float(totalTime)/dummyPrintInterval
        numDumPrintsPerPrint = printInterval/dummyPrintInterval
        while i < sleepSlots: 
            time.sleep(dummyPrintInterval)
            i += 1
            if not noMsgF:
                if i % numDumPrintsPerPrint == 0 and i < sleepSlots: 
                    remainingTime = totalTime - i/numDumPrintsPerPrint
                    self.Print('%s. Remaining time %i minutes %i seconds\n'%
                               (msg, remainingTime/60, remainingTime%60))
            self.Print('')    #To keep the GUI from freezing
            
    def calcBaselineCallRValues(self):
        #Let the baseline call run for the specified time. Only then start roaming
        self.Print("Running the Base call for %i minute(s) %i seconds\n"%
                   ((self.baseCallDurationVal/60), (self.baseCallDurationVal % 60)))
        msg = 'Running the Base call'
        self.givePeriodicStatusUpdates(self.baseCallDurationVal, 0.25, 1, msg)
        
        #Write the heading 'Baseline Call Details'
        WaveEngine.WriteDetailedLog(["Baseline Call Details"])
        columnLabels = "'Group Name', 'Network', 'Client Name', 'Stream Direction', 'Stream Name', 'R-Value'"
        WaveEngine.WriteDetailedLog([columnLabels])
#       Calculate Baseline Call R-Value
        clientsRvalues = RSQEC.getClientsRValues()
        
        for clientGroup in clientsRvalues:
            for clientName in clientsRvalues[clientGroup]:
                for flow in clientsRvalues[clientGroup][clientName]:
                    rValue = flowStats.calcInterimRValue(flow, self.baseCallDurationVal, 0, 0)
                    if rValue < 0:
                        rValue = 0
                    RSQEC.setClientsPreviousRValueTime(clientGroup, clientName, flow, time.time())
                    RSQEC.setClientRvalue(clientGroup, clientName, flow, rValue)
        
        #Write a couple of empty lines indicating the end of Baseline Call details
        detailedLogStrList = []
        for groupName in clientsRvalues:
            ssid = self.Clientgroup[groupName].Getssid()
            for clientName in clientsRvalues[groupName]:
                for upFlow, downFlow in zip(self.flowsFromClientDict[groupName][clientName], 
                                            self.flowsToClientDict[groupName][clientName]):
                    upRValue = clientsRvalues[groupName][clientName][upFlow][-1]
                    detailedLogStrList.append(["%s, %s, %s, %s, %s, %0.2f"%
                                              (groupName,ssid, clientName,'Up',
                                               upFlow, upRValue)])
                    downRValue = clientsRvalues[groupName][clientName][downFlow][-1]
                    detailedLogStrList.append(["%s, %s, %s, %s, %s, %0.2f"%
                                              (groupName,ssid, clientName,'Down',
                                               downFlow, downRValue)])
        for logStr in detailedLogStrList:
            WaveEngine.WriteDetailedLog(logStr)
        WaveEngine.WriteDetailedLog("\n\n")
        WaveEngine.WriteDetailedLog(["Roam Details"])
        
    def settleForInitialSnapshot(self):
        #For taking initial snapshot, allow the flow for 2 seconds
        self.Print("Starting the Roams...")
        self.givePeriodicStatusUpdates(2, 0.1, noMsgF = True)
            
    def checkRoamOppurtunities(self):
        """
        
        Verify if all the Wlan clients would get an oppurtunity to roam. 
        """ 

        #When we have only one client no matter how much the test duration is
        #and roam interval is we would have that one client to roam at least
        #one step as the minimum amount of test duration configurable is 1 sec
        #and the first roam always takes place at time 0 secs
        if self.totalRoamClients > 1:
            if self.roamInterval > self.totalduration:
                self.Print("Warning: Not All the Wlan Clients would get the oppurtunity to roam with the configured test duration and roam rate.\n", 'WARN')

    def startFlows(self):
        if len(self.FlowList) > 0:
            self._startFlowGroup("XmitGroup")
        
    def stopFlows(self):
        if len(self.FlowList) > 0:
            WaveEngine.VCLtest("action.stopFlowGroup('%s')" % "XmitGroup", 
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
                WaveEngine.VCLtest("mc.read('%s')" % clientname, globals())
                for items in bssidportlist:
                    for port in items.keys():
                        WaveEngine.Setactivebssid(clientname, port,
                            items[port])
                        time.sleep(0.50)
                #bring MC back to the starting port 
                #(i.e., first port in roam list for MC)
                roamlist = clientdict[clientname].Getroameventlist()
                if len(roamlist) > 0:
                    (startport, startbssid, starttime) = roamlist[0]
                    WaveEngine.Setactivebssid(clientname, startport,
                            startbssid)
                    time.sleep(0.50)
    """
    
    def getEventGenerator(self):
        return RSQEC.RoamServiceQualityEventgenerator()
    
    def getMaxTheoriticalRvalMOS(self):
        #Pick a group's with 'MainFlow' object, all groups have same packet types
        theoriticalDict = {'VOIPG711' : [85.9, 4.226],
                           'VOIPG7231' : [72.9, 3.729],
                           'VOIPG729A' : [81.7, 4.086]
                           }
        for groupName in self.Clientgroups.keys():
            flowType = self.ClientgrpFlows[groupName].Type
            if flowType in theoriticalDict:
                return theoriticalDict[flowType]  
            else:
                self.Print("Invalid flow type (%s) theoritical values requested\n" % flowType, 'ERR')
                return 
        
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
            if 'Phyrate' in Keys:
                phyrate = self.MainFlowlist[mainflowname]['Phyrate']
            else:
                phyrate = 54
                
            if 'Type' in Keys:
                pkttype = self.MainFlowlist[mainflowname]['Type']
            else:
                pkttype = 'G.711'
            
            if pkttype == 'G.711':
                trafficType = 'VOIPG711'
                intendedrate = 50
            elif pkttype == 'G.723':
                trafficType = 'VOIPG7231'
                intendedrate = 33
            elif pkttype == 'G.729':
                trafficType = 'VOIPG729A'
                intendedrate = 50
            #VPR 4370 is not applicable now as we pass deltaT value now, and the number
            #of frames would anyhow be calculated by the product deltaT * intended rate
            #(which is specific to the codec). So, We set max frames
            numframes = WaveEngine.MAXtxFrames

            mainflow = self.Flow(trafficType, Phyrate = phyrate,Intendedrate = intendedrate, 
                                 Numframes = numframes)
            
            roamFlowObjects[groupname]["mainflow"] = mainflow
            
        #Create a dictionary: groupName -> TrafficSource to be used in createFlows
        #Create a dictionary of 
        tmpGroupList = []

        for flowMap in self.roamFlowMappings:
            if self.roamTrafficSource.has_key(flowMap[1]):
                self.Print("At least two Sources are sending traffic to the roam group %s" %flowMap[1], 'Err')
                raise WaveEngine.RaiseException
            else:
                self.roamTrafficSource[flowMap[1]] = flowMap[0]
                        
        return roamFlowObjects
    
    def configureToS(self, srcCGFlows, DstCGFlows, callTrafficOptions):
        tosOptionsList = ['TosField', 'TosReserved', 'TosLowCost', 'TosLowDelay',
                          'TosHighReliability', 'TosHighThroughput']
        tosOptions = {}
        if callTrafficOptions['TosDiffservDSCP'] != 'Default':
            Dscp = callTrafficOptions['TosDiffservDSCP']
        else:
            Dscp = None
            for option in tosOptionsList:
                tosOptions[option] = callTrafficOptions[option]
        flows = srcCGFlows + DstCGFlows
        setToS(flows, tosOptions, Dscp)
        
    def configureVoipPorts(self, srcCGFlows, DstCGFlows, callTrafficOptions):
        voipPorts = {}
        voipPorts['SrcPort'] = callTrafficOptions['SrcPort']
        voipPorts['DestPort'] = callTrafficOptions['DestPort']
        setVoipPorts(srcCGFlows, DstCGFlows, voipPorts)
    
    def configureWlanQoS(self, flows ,callTrafficOptions):
        QoSF = callTrafficOptions['QoSEnabled']
        wlanPriorityVal = None
        if QoSF in [True, 'True']:
            QoSFVal = True
            wlanPriorityVal = callTrafficOptions['UserPriority']
            configureQoS(flows, QoSF = QoSFVal, wlanPriority = wlanPriorityVal)

    class clientCallDetails:
        def __init__(self, clientName, upFlow, downFlow, baselineRValue, roamDetails,
                      noRoamsF = False ):
            """
            Client Object holds the client's roamDetails and provides methods which deliver processed data
            about the call(s) made by this client
            
            clientCallDetails(clientName = '', upStream name, downStream name, 
                              baselineRValue = [], 
                              [(flow direction, flow name, 
                              roamStatus, rValue, rValueSnapShotTime, lastRoamTime,
                              srcPort_BssidStr, destPort_BssidStr,roam_delay),
                              (flow direction, flow name, rValue, rValueSnapShotTime, 
                              lastRoamTime), roamStatus] )
            
            """
            self.name = clientName
            self.hasRoamsF = not(noRoamsF)
            self.upFlowName = upFlow
            self.downFlowName = downFlow
            self.baselineRvalue = baselineRValue
            self.avatarDict = {}
            self.avatars = []
            self.rValUpBin = {}
            self.rValDownBin = {}
            self.mosValUpBin = {}
            self.mosValDownBin = {}
            self.minRvalues = (0, 0)
            self.avgRvalues = (0, 0)
            self.maxRvalues = (0, 0)
            self.minMoSvalues = (0, 0)
            self.avgMoSvalues = (0, 0)
            self.maxMoSvalues = (0, 0)
            self.successfulRoams = 0
            self.avgDelay = 0
            self.numRoams = 0
            self.failedRoams = 0
            self.highDelayDrops = 0
            #The below methods compute the intermediate data structures (Info) as part of 
            #initialisation. 
            if self.hasRoamsF:
                self.constructAvatarDict(roamDetails)
                self.computeMinAvgMaxRvalues(roamDetails)
                self.computeRvalueBinCounts(roamDetails)
                self.computeMoSvalueBinCounts(roamDetails)
                self.computeRoamStats(roamDetails)
            
        def constructAvatarDict(self, roamDetails):
            avatar = self.name
            i = 0
            self.avatarDict[avatar] = []
            for snapShot in roamDetails:
                roamStatus = snapShot[2]
                if roamStatus in ['Fail', 'High Delay'] or snapShot[0][2] == 0 or \
                    snapShot[1][2] == 0:
                    avatar = self.name + '--' + "%s"%i
                    self.avatarDict[avatar] = []
                    self.avatarDict[avatar].append(snapShot)
                    i += 1
                    if  roamStatus == 'Fail':
                        self.failedRoams += 1
                    elif roamStatus == 'High Delay':
                        self.highDelayDrops += 1
                else:
                    self.avatarDict[avatar].append(snapShot)
                    
        def computeMinAvgMaxRvalues(self, roamDetails):
            upRValueList = []
            downRValueList = []
            for snapShot in roamDetails:
                if snapShot[0][2] != 0:
                    upRValueList.append(snapShot[0][2])
                if snapShot[1][2] != 0:
                    downRValueList.append(snapShot[1][2])
            if upRValueList != []: 
                minUp = min(upRValueList)
                avgUp = sum(upRValueList)/float(len(upRValueList))
                maxUp = max(upRValueList)
            else:
                minUp = avgUp = maxUp = 0
                                
            if downRValueList != []:
                minDown = min(downRValueList)
                avgDown = sum(downRValueList)/float(len(downRValueList))
                maxDown = max(downRValueList)
            else:
                minDown = avgDown = maxDown = 0
            
            self.minRvalues = (minUp, minDown)
            self.avgRvalues = (avgUp, avgDown)
            self.maxRvalues = (maxUp, maxDown)
       
        def computeRvalueBinCounts(self, roamDetails):
            upBin = {}
            downBin = {}
            upRvalueList = []
            downRvalueList = []
            
            for snapShot in roamDetails:
                upRvalue = snapShot[0][2]
                downRvalue = snapShot[1][2]
                upRvalueList.append(upRvalue)
                downRvalueList.append(downRvalue)
            binBounds = [0, 50, 60, 70, 80, 90]
            self.rValUpBin = computeBinCountDict(binBounds, upRvalueList)
            self.rValDownBin = computeBinCountDict(binBounds, downRvalueList)
        
        def computeMoSvalueBinCounts(self, roamDetails):
            upBin = {}
            downBin = {}
            upRvalueList = []
            downRvalueList = []
            upMoSvaluesList = []
            downMoSvaluesList = []
            
            for snapShot in roamDetails:
                upRvalue = snapShot[0][2]
                downRvalue = snapShot[1][2]
                upRvalueList.append(upRvalue)
                downRvalueList.append(downRvalue)
            
            upMoSvaluesList = computeMoSequivalent(upRvalueList)
            downMoSvaluesList = computeMoSequivalent(downRvalueList)
            
            binBounds = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5]
            self.mosValUpBin = computeBinCountDict(binBounds, upMoSvaluesList)
            self.mosValDownBin = computeBinCountDict(binBounds, downMoSvaluesList)
            
        def computeRoamStats(self, roamDetails):
            self.numRoams = len(roamDetails)
            successfulRoams = 0
            delayTotal = 0
            roamDelayDetails = []
            for roamDetail in roamDetails:
                if not isinstance(roamDetail[0][7], str):
                    successfulRoams += 1
                    delayTotal += roamDetail[0][7]
                    roamDelayDetails.append((roamDetail[0][4], roamDetail[0][7]))
                else:
                    roamDelayDetails.append((roamDetail[0][4], 0))
            if successfulRoams > 0:
                self.avgDelay = delayTotal/successfulRoams
            else:
                self.avgDelay = 0
            self.successfulRoams = successfulRoams
            self.roamDelayDetails = roamDelayDetails
            
        def getMinAvgMaxCallDuration(self, roamInterval):
            minimum = avg = maximum = 0
            if self.hasRoamsF:
                avatars = self.avatarDict.keys()
                avatars.sort()
                callLenList = []
                for avatar in avatars:
                    callLenList.append(len(self.avatarDict[avatar]) -1)
                #The first avatar would not have included a dropped call instance
                #so, -1 above is not applicable for it, so do +1
                callLenList[0] += 1
                #When the first snapshot shows a dropped call, remove it, as it is
                #anyhow counted in next avatar
                if callLenList[0] == 0:
                    callLenList.pop(0)
                minimum = (min(callLenList)) * roamInterval
                avg = (sum(callLenList)/float(len(callLenList))) * roamInterval
                maximum = (max(callLenList)) * roamInterval
            
            return (minimum, avg, maximum)
        
        def getHighDelayTimes(self):
            parseList = [key for key in self.avatarDict if key != self.name]
            highDelayTimes = []
            for avatar in parseList:
                if self.avatarDict[avatar][0][2] == 'High Delay':
                    highDelayTimes.append(self.avatarDict[avatar][0][0][3])
            return highDelayTimes
        
        def getFailedRoamTimes(self):
            parseList = [key for key in self.avatarDict if key != self.name]
            failedRoamTimes = []
            for avatar in parseList:
                if self.avatarDict[avatar][0][2] == 'Fail':
                    failedRoamTimes.append(self.avatarDict[avatar][0][0][3])
            return failedRoamTimes
        
        def getCallDropTimes(self):
            parseList = [key for key in self.avatarDict if key != self.name]
            callDropTimes = []
            for avatar in parseList:
                callDropTimes.append(self.avatarDict[avatar][0][0][3])
            return callDropTimes
        
        def getNumDroppedCalls(self):
            if self.hasRoamsF:
                return len(self.avatarDict) - 1
            else:
                return 0
            
        def getRoamFails(self):
            return self.failedRoams
        
        def getHighDelayDrops(self):
            return self.highDelayDrops
        
        def getBaselineRvalue(self):
            return self.baselineRvalue
        
        def getMinAvgMaxRvalues(self):
            return (self.minRvalues, self.avgRvalues, self.maxRvalues)
        
        def getMinAvgMaxMoSvalues(self):
            self.minMoSvalues = tuple( computeMoSequivalent(list(self.minRvalues)) )
            self.avgMoSvalues = tuple( computeMoSequivalent(list(self.avgRvalues)) )
            self.maxMoSvalues = tuple( computeMoSequivalent(list(self.maxRvalues)) )
            
            return (self.minMoSvalues, self.avgMoSvalues, self.maxMoSvalues)
            
        def getRvalueBinCounts(self):
            return (self.rValUpBin, self.rValDownBin)
        
        def getMoSvalueBinCounts(self):
            return(self.mosValUpBin, self.mosValDownBin)
            
        def getNumRoams(self):
            return self.numRoams
        
        def getAvgDelay(self):
            return self.avgDelay
        
        def getHasRoamsF(self):
            return self.hasRoamsF
         
        def getRoamDelayDetails(self): 
            return self.roamDelayDetails
        
    def computeRvalMoSvalBinGraphsData(self):
        """
        
        """
        allClientsUpRvalBin = {}
        allClientsDownRvalBin = {}
        allClientsBaseUpRvalBin = {}
        allClientsBaseDownRvalBin = {}
        allClientsUpMoSvalBin = {}
        allClientsDownMoSvalBin = {}
        allClientsBaseUpMoSvalBin = {}
        allClientsBaseDownMoSvalBin = {}
        baseUpRvalList = []
        baseDownRvalList = []
        baseUpMoSvalList = []
        baseDownMoSvalList = []
        rValueBinBounds = [50, 60, 70, 80, 90]
        mosValueBinBounds = [1.5, 2, 2.5, 3, 3.5, 4, 4.5]
        #Compute Baseline call bin values
        clientsRvalues = RSQEC.getClientsRValues()
        
        for group in clientsRvalues:
            for client in clientsRvalues[group]:
                if not self.clientCallDetialsObjs[group][client].hasRoamsF:
                    continue
                upFlowName = self.clientCallDetialsObjs[group][client].upFlowName
                downFlowName = self.clientCallDetialsObjs[group][client].downFlowName
                upRval = clientsRvalues[group][client][upFlowName][0]
                downRval = clientsRvalues[group][client][downFlowName][0]
                baseUpRvalList.append(upRval)
                baseDownRvalList.append(downRval)

        allClientsBaseUpRvalBin = computeBinCountDict(([0]+ rValueBinBounds), baseUpRvalList)
        allClientsBaseDownRvalBin = computeBinCountDict(([0]+ rValueBinBounds),
                                                        baseDownRvalList)

        #Compute Baseline call MOS bin values
        baseUpMoSvalList = computeMoSequivalent(baseUpRvalList)
        baseDownMoSvalList = computeMoSequivalent(baseDownRvalList)
        allClientsBaseUpMoSvalBin = computeBinCountDict(([1]+ mosValueBinBounds),
                                                   baseUpMoSvalList)
        allClientsBaseDownMoSvalBin = computeBinCountDict(([1]+ mosValueBinBounds),
                                                     baseDownMoSvalList)
                
        #Compute calls bin values  
        upRvaluesSnapshotsCount = downRvaluesSnapshotCount = \
        upMoSvaluesSnapshotsCount = downMoSvaluesSnapshotCount = 0    
        for key in rValueBinBounds:
            allClientsUpRvalBin[key] = 0  
            allClientsDownRvalBin[key] = 0
        for key in mosValueBinBounds:
            allClientsUpMoSvalBin[key] = 0  
            allClientsDownMoSvalBin[key] = 0  
            
        for group in self.clientCallDetialsObjs:
            for client in self.clientCallDetialsObjs[group]:
                if not self.clientCallDetialsObjs[group][client].hasRoamsF:
                    continue
                clientCallDetailsObj = self.clientCallDetialsObjs[group][client]
                (upRvalueBin, downRvalueBin) = \
                    clientCallDetailsObj.getRvalueBinCounts()
                (upMoSvalueBin, downMoSvalueBin) = \
                    clientCallDetailsObj.getMoSvalueBinCounts()
                
                upRvaluesSnapshotsCount += reduce(lambda x, y: x+y, upRvalueBin.values())
                downRvaluesSnapshotCount += reduce(lambda x, y: x+y, downRvalueBin.values())
                upMoSvaluesSnapshotsCount += reduce(lambda x, y: x+y, upMoSvalueBin.values())
                downMoSvaluesSnapshotCount += reduce(lambda x, y: x+y, downMoSvalueBin.values())
                
                for bin in rValueBinBounds:    
                    allClientsUpRvalBin[bin] += upRvalueBin[bin]
                    allClientsDownRvalBin[bin] += downRvalueBin[bin]
                
                for bin in mosValueBinBounds:
                    allClientsUpMoSvalBin[bin] += upMoSvalueBin[bin]
                    allClientsDownMoSvalBin[bin] += downMoSvalueBin[bin]
                    
        #Convert to percentage values
        valuesCountList = [len(baseUpRvalList), len(baseDownRvalList),
                           upRvaluesSnapshotsCount, downRvaluesSnapshotCount]
        binsDictList = [allClientsBaseUpRvalBin, allClientsBaseDownRvalBin, 
                        allClientsUpRvalBin, allClientsDownRvalBin]
        for valuesCount, binsDict in zip(valuesCountList, binsDictList):
            for bin in rValueBinBounds:
                binsDict[bin] = (binsDict[bin] * 100.0) / valuesCount
    
        #Convert to percentage values
        valuesCountList = [len(baseUpMoSvalList), len(baseDownMoSvalList),
                           upMoSvaluesSnapshotsCount, downMoSvaluesSnapshotCount]
        binsDictList = [allClientsBaseUpMoSvalBin, allClientsBaseDownMoSvalBin, 
                        allClientsUpMoSvalBin, allClientsDownMoSvalBin]
        for valuesCount, binsDict in zip(valuesCountList, binsDictList):
            for bin in mosValueBinBounds:
                binsDict[bin] = (binsDict[bin] * 100.0) / valuesCount
                        
        rValueBinGraphData = (allClientsBaseUpRvalBin, allClientsBaseDownRvalBin, 
                              allClientsUpRvalBin, allClientsDownRvalBin)
        
        
        mosValueBinGraphData = (allClientsBaseUpMoSvalBin, allClientsBaseDownMoSvalBin, 
                                allClientsUpMoSvalBin, allClientsDownMoSvalBin)
        
        return (rValueBinGraphData, mosValueBinGraphData)
    
    def constructRoamDelayVsTimeGraphInfo(self):
        clientRoamDelayTimes = {}
        for group in self.clientCallDetialsObjs:
            for client in self.clientCallDetialsObjs[group]:
                if not self.clientCallDetialsObjs[group][client].hasRoamsF:
                    continue
                clientCallDetailsObj = self.clientCallDetialsObjs[group][client]
                clientRoamDelayTimes[client] = clientCallDetailsObj.getRoamDelayDetails()

        #We divide the Time line (X-axis) into 20 intervals and draw the line graph
        #with cumulative dropped calls in those intervals
        scale = self.totalduration
        interval = scale/20.0
        timeBinEnd = 0
        roamDelayVsTimeXvals = []
        roamDelayVsTimeYvals = []
        roamDelayVsTimeLegends = []
        while timeBinEnd <= scale:
            roamDelayVsTimeXvals.append(timeBinEnd)
            timeBinEnd += interval

        for client in clientRoamDelayTimes:
            clientRoamDelayTimes[client].sort()
            roamDelayVsTimeLegends.append(client)
            #First time bin
            timeBinStart = 0.0
            timeBinEnd = interval
            latestRoamDelay = 0
            i = 0
            #roamDelayVsTimeYvals = [[][][]] where each inner [] corresponds to a group
            #Initial drop count 0 when time is 0 (i.e., there is not previous bin)
            prevBinDelay = 0
            roamDelayVsTimeYvals.append([])
            while timeBinEnd <= scale: 
                totalRoamDelayInBin = 0
                roamCountInBin  = 0
                roamEventInBinF = False
                while i < len(clientRoamDelayTimes[client]):
                    if timeBinStart <= clientRoamDelayTimes[client][i][0] < timeBinEnd:
                        roamEventInBinF = True
                        totalRoamDelayInBin += clientRoamDelayTimes[client][i][1]
                        roamCountInBin += 1
                        i += 1
                    else:
                        break
                    
                #The graph plotted is a trend analysis, withe the existing architecture for 
                #a line graph we have to have same x-values for all the entities represented
                #by a line (client, client group etc), so, we have to have a value for a client
                #at a point x where it actually didn't roam, since we try to plot a trend analysis
                #we chose a method where, whenever we don't have a roam event 
                #we pick the previous roam events value, when we have a roam event and the
                #roam event succeeds we pick the (avg) roam delay in that time interval and if
                #the roam fails we indicate that by value (ironically) '0' (not a large value)
                if not roamEventInBinF:
                    avgDelayInBin = latestRoamDelay
                else:
                    avgDelayInBin = totalRoamDelayInBin/roamCountInBin
                    latestRoamDelay = avgDelayInBin
                    
                roamDelayVsTimeYvals[-1].append(avgDelayInBin)
                timeBinStart = timeBinEnd
                timeBinEnd += interval
        return (roamDelayVsTimeXvals, roamDelayVsTimeYvals, roamDelayVsTimeLegends)
    
    def constructCumulDropsOverTimeGraphInfo(self):
        allClientsCallDropTimes = {}
        allClientsHighDelayDropTimes = {}
        allClientsFailedRoamDropTimes = {}
        for group in self.clientCallDetialsObjs:
            allClientsCallDropTimes[group] = []
            allClientsHighDelayDropTimes[group] = []
            allClientsFailedRoamDropTimes[group] = []
            for client in self.clientCallDetialsObjs[group]:
                if not self.clientCallDetialsObjs[group][client].hasRoamsF:
                    continue
                clientCallDetailsObj = self.clientCallDetialsObjs[group][client]
                highDelayCallDropTimes = clientCallDetailsObj.getHighDelayTimes()
                failedRoamCallDropTimes = clientCallDetailsObj.getFailedRoamTimes()
                callDropTimes = clientCallDetailsObj.getCallDropTimes()
                allClientsCallDropTimes[group] += callDropTimes
                allClientsHighDelayDropTimes[group] += highDelayCallDropTimes
                allClientsFailedRoamDropTimes[group] += failedRoamCallDropTimes
            #allClientsCallDropTimes contains time points at which, roams which
            #resulted in call drops occured
            allClientsCallDropTimes[group].sort()
            allClientsHighDelayDropTimes[group].sort()
            allClientsFailedRoamDropTimes[group].sort()
        #We divide the Time line (X-axis) into 20 intervals and draw the line graph
        #with cumulative dropped calls in those intervals
        scale = self.totalduration
        bucketCount = 20.0
        interval = scale/bucketCount
        timeBinEnd = 0
        cumulDropsOverTimeXvals = []
        cumulDropsOverTimeYvals = []
        cumulDropsOverTimeLegends = []
        while timeBinEnd <= scale:
            cumulDropsOverTimeXvals.append(timeBinEnd)
            timeBinEnd += interval
        groupList = self.clientCallDetialsObjs.keys()
        for group in groupList:
            legendList = [['%s Call Drops'%group], 
                          ['%s Over Threshold'%group], 
                          ['%s Failed Roams'%group]]
            cumulDropsOverTimeLegends += legendList
            cumulCallDropsOverTime = self.overTimeGraphYvals(scale, bucketCount, 
                                                        allClientsCallDropTimes[group])
            cumulOverThresholdOverTime = self.overTimeGraphYvals(scale, bucketCount, 
                                                            allClientsHighDelayDropTimes[group])
            cumulFailedRoamsOverTime = self.overTimeGraphYvals(scale, bucketCount, 
                                                          allClientsFailedRoamDropTimes[group])
            cumulDropsOverTimeYvals += [cumulCallDropsOverTime,
                                        cumulOverThresholdOverTime,
                                        cumulFailedRoamsOverTime]

        return (cumulDropsOverTimeXvals, cumulDropsOverTimeYvals,
                cumulDropsOverTimeLegends)
        
    def overTimeGraphYvals(self, scale, bucketCount, timePoints):
        """
        
        Given (i) a list of values (time1, time2,...) when an event (e.g., roam fail) has 
        occured, (ii)a time scale and (iii) number of buckets, it retunrs the avg y-value
        at each bucket (x-val)
        """
        interval = scale/bucketCount

        #First time bin
        timeBinStart = 0.0
        timeBinEnd = interval
        i = 0
        prevBinDropCount = 0
        yVals = [0]
        #Initial drop count 0 when time is 0 (i.e., there is not previous bin)
        while timeBinEnd <= scale: 
            while i < len(timePoints):
                if timeBinStart <= timePoints[i] < timeBinEnd:
                    yVals[-1] += 1
                    i += 1
                else:
                    break
            timeBinStart = timeBinEnd
            timeBinEnd += interval
            prevBinDropCount = yVals[-1]
            yVals.append(prevBinDropCount)
                
        return yVals
    
    def computePercents(self, valsList, results):
        """
        Given a list containing lists recurrently, return the equivalent % values
        for each innermost item (assume that the sum in the innermost list is 100%).
        If new to python, note that results value passed initially (when this method is 
        called from outside) is a list object, and it is this passed object that 
        is manipulated in each iteration, thus the callee would have access to 
        this variable 'results' in its local name space
        """

        if len(valsList) > 0:
            if isinstance(valsList[0], list):
                for vals in valsList:
                    results = self.computePercents(vals, results)
                return results
            else:
                 total = sum(valsList)
                 percents = [x*100.0/total for x in valsList]
                 results.append(percents)
                 return results
        else:
            results.append([])
            return results

            
    def _getPieChartLabels(self, rValueBinVals, mosValueBinVals):
        """
        Append the percentage values of each bin with the label name and 
        return these lists. This is useful when 3d pie charts (which don't
        have legends) are desired 
        """
        rValBaseLabels = ['0-50','51-60','61-70','71-80','81-90']
        mosValBaseLabels = ['1-1.5','1.5-2','2-2.5','2.5-3', '3-3.5','3.5-4','4-4.5']
        rValPercents = []
        if rValueBinVals == []:
            pass
        else:
            self.computePercents(rValueBinVals, rValPercents)
            
        rValLabels = []
        for chart in rValPercents:
            lablList = []
            for i, labl in enumerate(rValBaseLabels):
                lablList.append((labl + " (%0.1f%%)"%chart[i]))
            rValLabels.append(lablList)
            
        mosValPercents = []
        if mosValueBinVals == []:
            pass
        else:
            self.computePercents(mosValueBinVals, mosValPercents)
        
        mosValLabels = []
        for chart in mosValPercents:
            lablList = []
            for i, labl in enumerate(mosValBaseLabels):
                lablList.append((labl + " (%0.1f%%)"%chart[i]))
            mosValLabels.append(lablList)
            
        return (rValLabels, mosValLabels)
    
    def computeRvalMoSvalBinGraphsInfo(self, rValueBinGraphData, mosValueBinGraphData):
        rValueBinsGraphDetails = []
        mosValueBinsGraphDetails = []
        
        (allClientsBaseUpRvalBin, allClientsBaseDownRvalBin, 
                allClientsUpRvalBin, allClientsDownRvalBin) = rValueBinGraphData
        (allClientsBaseUpMoSvalBin, allClientsBaseDownMoSvalBin, 
                allClientsUpMoSvalBin, allClientsDownMoSvalBin)  = mosValueBinGraphData
                
        #We can't take dict.values() as the dict won't be sorted on key.
        #So, collect the bin values  based on a sorted list [50, 60, 70, 80, 90]
        baseupRvalBin = []
        basedownRvalBin = []
        upRvalBin = []
        downRvalBin = []
        for bin in [50, 60, 70, 80, 90]:
            baseupRvalBin.append(allClientsBaseUpRvalBin[bin])
            upRvalBin.append(allClientsBaseDownRvalBin[bin])
            basedownRvalBin.append(allClientsUpRvalBin[bin])
            downRvalBin.append(allClientsDownRvalBin[bin])
        rValueBinVals = [baseupRvalBin, upRvalBin, basedownRvalBin,  downRvalBin]
        
        baseupMoSvalBin = []
        basedownMoSvalBin = []
        upMoSvalBin = []
        downMoSvalBin = []
        for bin in [1.5, 2, 2.5, 3, 3.5, 4, 4.5]:
            baseupMoSvalBin.append(allClientsBaseUpMoSvalBin[bin])
            upMoSvalBin.append(allClientsBaseDownMoSvalBin[bin])
            basedownMoSvalBin.append(allClientsUpMoSvalBin[bin])
            downMoSvalBin.append(allClientsDownMoSvalBin[bin])    
        mosValueBinVals = [baseupMoSvalBin, upMoSvalBin, basedownMoSvalBin, downMoSvalBin]

        #Collect the details into lists
        
        #rValLabels, mosValLabels = self._getPieChartLabels(rValueBinVals, mosValueBinVals)
        
        rValueBinsTitles = ['Baseline Upstream','Upstream', 
                            'Baseline Downstream', 'Downstream']
        rValLabels = ['0-50','51-60','61-70','71-80','81-90']

        for i, graph in enumerate(rValueBinsTitles):
            graphDetails = [graph, rValueBinVals[i], rValLabels]
            rValueBinsGraphDetails.append(graphDetails)
        
        mosValueBinsTitles = ['Baseline Upstream','Upstream',
                              'Baseline Downstream', 'Downstream']  
        mosValLabels = ['1-1.5','1.5-2','2-2.5','2.5-3', '3-3.5',
                            '3.5-4','4-4.5']
  
        for i, graph in enumerate(mosValueBinsTitles):
            graphDetails = [graph, mosValueBinVals[i], mosValLabels]
            mosValueBinsGraphDetails.append(graphDetails)
        
        self.ResultsForCSVfile += [('Graph: R-Values percentage Observed in Various R-Value Bins',),
                                   ('X-Axis values',)]
        self.ResultsForCSVfile += [('0-50','50-60','60-70','70-80','80-90'),
                                   ('Y-Axis values',), ('Legends',)]


        for i, legend in enumerate(rValueBinsTitles):
            self.ResultsForCSVfile.append((legend,))
            self.ResultsForCSVfile.append(rValueBinVals[i])
            
        self.ResultsForCSVfile += [('Graph: MOS scores percentage Observed in Various MOS score Bins',),
                                   ('X-Axis values',)]
        self.ResultsForCSVfile += [('1-1.5','1.5-2','2-2.5','2.5-3','3-3.5','3.5-4','4-4.5'),
                                   ('Y-Axis values',), ('Legends',)]


        for i, legend in enumerate(mosValueBinsTitles):
            self.ResultsForCSVfile.append((legend,))
            self.ResultsForCSVfile.append(mosValueBinVals[i])
    
        return (rValueBinsGraphDetails, mosValueBinsGraphDetails)

    def settleSUT(self):
        msg = 'Settling the SUT'
        self.givePeriodicStatusUpdates(5, 0.25, 1,  msg)


    def processStats(self):
        """
        
        Collect the info required for the graphs and tables in the report.
        While collecting write that info in to self.ResultsForCSVfile
        """
        #Create Summary Table list of tuples
        self.clientCallDetialsObjs = {}
        if  self.UserPassFailCriteria['user'] == "True":
                 summTableCommonColumNames = ["SSID", "Num Roams", "Drop threshold exceed count",
                                     "Failed Roams",  "Avg Roam Delay (msecs)",
                                     "Baseline Call Quality (UpStream , DownStream)",
                                     "Avg. Roam Call Quality (UpStream , DownStream)","USC:DC","USC:RV"]
        else: 
                 summTableCommonColumNames = ["SSID", "Num Roams", "Drop threshold exceed count", 
                                     "Failed Roams",  "Avg Roam Delay (msecs)", 
                                     "Baseline Call Quality (UpStream , DownStream)",
                                     "Avg. Roam Call Quality (UpStream , DownStream)"]
        summaryTableDetails = []
        rValueBarGraphXYDetails = [[], [], [], None] 
        mosValueBarGraphXYDetails = [[], [], [], None] 
        roamDelayVsTimeDetails = [[], [], []] 
        rValueBinsGraphDetails = []
        mosValueBinsGraphDetails = []
        cumulCallDropsVsTimeDetails = []

        #Write the data to be written to the Results csv file into the list
        #self.ResultsForCSVfile. SaveResults() in basetest.py writes the data from this list
        #into the .csv file by calling WaveEngine.CreateCSVFile()
        
        if self.totalClientsRoamed <= 25:
            summaryTableColumnNames = ["Client"] + summTableCommonColumNames
            upFlowBaseRvalList =[]
            minUpRvaluesList = []
            avgUpRvaluesList = []
            maxUpRvaluesList = []
            downFlowBaseRValsList = []
            minDownRvaluesList = []
            avgDownRvaluesList = []
            maxDownRvaluesList = []
            
            upFlowBaseMoSvaluesList =[]
            minUpMoSvaluesList = []
            avgUpMoSvaluesList = []
            maxUpMoSvaluesList = []
            downFlowBaseMoSvaluesList = []
            minDownMoSvaluesList = []
            avgDownMoSvaluesList = []
            maxDownMoSvaluesList = []
        else:
            summaryTableColumnNames = ["Client Group"] + summTableCommonColumNames
            
        summaryTableDetails.append(summaryTableColumnNames)
        self.ResultsForCSVfile.append(('Summary Table Details',))
        if  self.UserPassFailCriteria['user'] == "True":
                 self.ResultsForCSVfile.append(summaryTableColumnNames[0:5] + \
                                      ["Avg Roam Delay (msecs)",
                                       "Baseline Call UpStream quality",
                                       "Baseline Call DownStream quality",
                                       "Avg. Roam Call UpStream Quality",
                                       "Avg. Roam Call DownStream Quality",
                                       "USC:DC","USC:RV"])
        else: 
                 self.ResultsForCSVfile.append(summaryTableColumnNames[0:5] + \
                                      ["Avg Roam Delay (msecs)",
                                       "Baseline Call UpStream quality",
                                       "Baseline Call DownStream quality",
                                       "Avg. Roam Call UpStream Quality",
                                       "Avg. Roam Call DownStream Quality"])
    #Create clientCallDetails objects which contain data processing methods
        clientsRvalues = RSQEC.getClientsRValues()
        clientStats = RSQEC.getClientStats()
        
        for clientGroup in clientStats:
            self.clientCallDetialsObjs[clientGroup] = {}
            totalGroupDrops = 0
            totalGroupRoams = 0
            totalGroupHighDelayDrops = 0
            totalGroupRoamFailDrops = 0
            totalGroupDelaySum = 0
            totalGroupClients = 0
            groupMinCallDurationList = []
            groupMaxCallDurationList = []
            groupAvgCallDurationSumList = []
            groupUpFlowBaseRvalueList = []
            groupDownFlowBaseRvalueList = []
            upRvalSumList = []
            downRvalSumList = []
            for client in clientStats[clientGroup]:
                roamDetails = []
                ssid = clientStats[clientGroup][client][0][0]
                #Here assuming that there is only one upFlow, 
                #Change to accomodate the general structure which assumes more 
                #than one flow
                upFlowName = clientStats[clientGroup][client][0][1][1]
                downFlowName = clientStats[clientGroup][client][0][2][1]
                upFlowBaseRValue = \
                    clientsRvalues[clientGroup][client][upFlowName][0]
                downFlowBaseRValue = \
                    clientsRvalues[clientGroup][client][downFlowName][0]
                
                #Hack, to find out if the client had at least one roam
                #If it didn't it would have been added to RSQEC.gClientStats through 
                #addNullStatsToNoRoamClients()
                noRoamsFval = False
                if len(clientStats[clientGroup][client][0][1]) == 2:
                    noRoamsFval = True
                    
                for details in clientStats[clientGroup][client]:
                    roamDetails.append((details[1], details[2], details[3]))
                
                clientCallDetailsObj = self.clientCallDetails(client, upFlowName,
                                                              downFlowName, 
                                                              (upFlowBaseRValue, 
                                                               downFlowBaseRValue),
                                                               roamDetails, noRoamsFval)
                #CHB DEBUG
                #print "Roam Details", roamDetails
                #print "no RoamsFval", noRoamsFval
                self.clientCallDetialsObjs[clientGroup][client] = clientCallDetailsObj
                highDelayDrops = clientCallDetailsObj.getHighDelayDrops()
                failedRoamDrops = clientCallDetailsObj.getRoamFails()
                numDrops = clientCallDetailsObj.getNumDroppedCalls()
                numRoams = clientCallDetailsObj.getNumRoams()
                avgDelay = clientCallDetailsObj.getAvgDelay()
                clientHasRoamsF = clientCallDetailsObj.getHasRoamsF()
                #minAvgMaxCallDurations = clientCallDetailsObj.getMinAvgMaxCallDuration(self.roamInterval)
                (minRvalues, avgRvalues, maxRvalues) = \
                    clientCallDetailsObj.getMinAvgMaxRvalues() 
                (minMoSvalues, avgMoSvalues, maxMoSvalues) = \
                    clientCallDetailsObj.getMinAvgMaxMoSvalues()
                #CHB DEBUG
                #print "MIN RVALS", minRvalues
                #Format avg R-values limiting the decimal precision to 2 digits
                formattedAvgRvalues = "%0.2f, %0.2f"%(avgRvalues[0], avgRvalues[1])
                #formattedMinAvgMaxCallDurations = "%0.2f, %0.2f, %0.2f"%(minAvgMaxCallDurations)
                if self.totalClientsRoamed <= 25:
                    if  self.UserPassFailCriteria['user'] == "True":
                             TestResult={}
                             TestResult[client]={}  
                             #print "fjkgsj %s" %clientGroup 
                             #print "the hgsdh is %s" %self.UserPassFailCriteria
                             #print "fjgf %s" %self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']
                             WaveEngine.OutputstreamHDL("\nThe Results Summary For Client-%s w.r.t P/F criterion are::\n " %client,WaveEngine.MSG_SUCCESS)
                             if numRoams != 0:
                                if float(highDelayDrops)/numRoams <= float (self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']): 
                                        TestResult[client]['USC:DC']= 'PASS'
                                        WaveEngine.OutputstreamHDL("---Test Has achieved the Pass/Fail criteria configured by the User:: User-%s,Achieved-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']*100,(highDelayDrops* 100)/numRoams),WaveEngine.MSG_SUCCESS)
                                else:
                                        TestResult[client]['USC:DC']= 'FAIL'
                                        WaveEngine.OutputstreamHDL("---Test Has failed to achieve the Pass/Fail criteria configured by the User:: User-%s,Achieved-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']*100,(highDelayDrops* 100)/numRoams),WaveEngine.MSG_WARNING) 
                                temp_r=0 
                                for each in minRvalues:
                                   if each < float(self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']): 
                                       temp_r= temp_r+1
                                if temp_r == 0:
                                   TestResult[client]['USC:RV']='PASS'
                                   WaveEngine.OutputstreamHDL("---Test Has achieved the Pass/Fail criteria configured by the User:: User-%s,all the achieved R-values are above that Min R-value\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']),WaveEngine.MSG_SUCCESS)
                                else:
                                   TestResult[client]['USC:RV']='FAIL'
                                   WaveEngine.OutputstreamHDL("---Test Has failed to achieve the Pass/Fail criteria configured by the User:: User-%s,at least one of the achieved R-values are below that Min R-value\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']),WaveEngine.MSG_WARNING) 
                             else:
                                   TestResult[client]['USC:DC']= 'INVALID'
                                   TestResult[client]['USC:RV']= 'INVALID'
                                   WaveEngine.OutputstreamHDL("---Total Number of Roams for this client is Zero:: Results are Invalid for P/F criteria:: \n" ,WaveEngine.MSG_WARNING)
                             self.ResultsForCSVfile.append([client, ssid, numRoams,
                                                   highDelayDrops, failedRoamDrops,
                                                   avgDelay,
                                                   #"%0.2f"%minAvgMaxCallDurations[0],
                                                   #"%0.2f"%minAvgMaxCallDurations[1],
                                                   #"%0.2f"%minAvgMaxCallDurations[2],
                                                   "%0.2f"%upFlowBaseRValue,
                                                   "%0.2f"%downFlowBaseRValue,
                                                   "%0.2f"%avgRvalues[0],
                                                   "%0.2f"%avgRvalues[1],
                                                   TestResult[client]['USC:DC'],
                                                   TestResult[client]['USC:RV']]
                                                     )
                             clientDetails = (client, ssid, numRoams,
                                     highDelayDrops, failedRoamDrops,
                                     avgDelay,
                                     #formattedMinAvgMaxCallDurations,
                                     "%0.2f, %0.2f"%(upFlowBaseRValue,
                                                       downFlowBaseRValue),
                                     formattedAvgRvalues,
                                     TestResult[client]['USC:DC'],
                                     TestResult[client]['USC:RV'] )

                    else: 
                             clientDetails = (client, ssid, numRoams,
                                     highDelayDrops, failedRoamDrops,
                                     avgDelay,
                                     #formattedMinAvgMaxCallDurations,
                                     "%0.2f, %0.2f"%(upFlowBaseRValue,
                                                       downFlowBaseRValue),
                                     formattedAvgRvalues)
 
                             self.ResultsForCSVfile.append([client, ssid, numRoams, 
                                                   highDelayDrops, failedRoamDrops,
                                                   avgDelay, 
                                                   #"%0.2f"%minAvgMaxCallDurations[0],
                                                   #"%0.2f"%minAvgMaxCallDurations[1],
                                                   #"%0.2f"%minAvgMaxCallDurations[2],
                                                   "%0.2f"%upFlowBaseRValue,
                                                   "%0.2f"%downFlowBaseRValue,
                                                   "%0.2f"%avgRvalues[0],
                                                    "%0.2f"%avgRvalues[1]])
                    summaryTableDetails.append(clientDetails)
                    if clientHasRoamsF:
                        rValueBarGraphXYDetails[0].append(client)
                        upFlowBaseRvalList.append(upFlowBaseRValue)
                        minUpRvaluesList.append(minRvalues[0])
                        avgUpRvaluesList.append(avgRvalues[0])
                        maxUpRvaluesList.append(maxRvalues[0])
                        downFlowBaseRValsList.append(downFlowBaseRValue)
                        minDownRvaluesList.append(minRvalues[1])
                        avgDownRvaluesList.append(avgRvalues[1])
                        maxDownRvaluesList.append(maxRvalues[1])
                        
                        mosValueBarGraphXYDetails[0].append(client)
                        upFlowBaseMoSvaluesList.append(computeMoSequivalent(upFlowBaseRValue))
                        minUpMoSvaluesList.append(minMoSvalues[0])
                        avgUpMoSvaluesList.append(avgMoSvalues[0])
                        maxUpMoSvaluesList.append(maxMoSvalues[0])
                        downFlowBaseMoSvaluesList.append(computeMoSequivalent(upFlowBaseRValue))
                        minDownMoSvaluesList.append(minMoSvalues[1])
                        avgDownMoSvaluesList.append(avgMoSvalues[1])
                        maxDownMoSvaluesList.append(maxMoSvalues[1])
                    
                else:    #Collect group based statistics
                    if clientHasRoamsF:
                        totalGroupHighDelayDrops += highDelayDrops
                        totalGroupRoamFailDrops += failedRoamDrops
                        totalGroupDrops += numDrops
                        totalGroupRoams += numRoams
                        totalGroupDelaySum += (numRoams-numDrops) * avgDelay
#                        groupMinCallDurationList.append(minAvgMaxCallDurations[0])
#                        groupMaxCallDurationList.append(minAvgMaxCallDurations[2])
#                        groupAvgCallDurationSumList.append(minAvgMaxCallDurations[1] * 
#                                                           (numDrops+1))
                        
                        
                        #We need the Average upFlow, downFlow R-values
                        #Since we have averages (sum/count) already for each client, 
                        #we extract 'sum' here, later use it to get group based average
                        upRvalSumList.append(avgRvalues[0] * (numDrops+1))
                        downRvalSumList.append(avgRvalues[1] * (numDrops+1))
                        totalGroupClients += 1
                    groupUpFlowBaseRvalueList.append(upFlowBaseRValue)
                    groupDownFlowBaseRvalueList.append(downFlowBaseRValue)
                    
            if self.totalClientsRoamed > 25:
                if totalGroupRoams > 0:
#                    groupMinCallDuration = min(groupMinCallDurationList)
#                    groupMaxCallDuration = max(groupMaxCallDurationList)
#                    groupAvgCallDuration = (sum(groupAvgCallDurationSumList)/
#                                            (totalGroupClients + totalGroupDrops))

                    avgUpRval = sum(upRvalSumList)/(totalGroupDrops + totalGroupClients)
                    avgDownRval = sum(downRvalSumList)/(totalGroupDrops + totalGroupClients)
                    
                    if (totalGroupRoams - totalGroupDrops) > 0:
                        groupAvgDelay = totalGroupDelaySum/(totalGroupRoams - totalGroupDrops)
                    else:
                        groupAvgDelay = 0
                else:
                    #groupMinCallDuration = groupMaxCallDuration = groupAvgCallDuration = 0
                    avgUpRval = avgDownRval = totalGroupDrops = groupAvgDelay = 0
                
                avgBaseUpRval = (sum(groupUpFlowBaseRvalueList)/
                                float(len(groupUpFlowBaseRvalueList)))
                avgBaseDownRval = (sum(groupDownFlowBaseRvalueList)/
                                    float(len(groupDownFlowBaseRvalueList)))
                
                baselineRvaluesStr = "%0.2f, %0.2f"%(avgBaseUpRval,avgBaseDownRval)
                avgRvalsStr = "%0.2f, %0.2f"%(avgUpRval, avgDownRval)
                
#                minAvgMaxCallDurationStr = "%0.2f, %0.2f, %0.2f"%(groupMinCallDuration,
#                                                                    groupMaxCallDuration,
#                                                                    groupAvgCallDuration)
                if  self.UserPassFailCriteria['user'] == "True":
                             # minrval_up.append(minRvalues[0] * (numDrops+1))
                             #minrval_down.append(minRvalues[1]* (numDrops+1)) 
                             minRvalues_l=[]
                             #print "the value of R- ar  %s\n"
                             #print minRvalues  
                             #print groupUpFlowBaseRvalueList
                             #print groupDownFlowBaseRvalueList
                             minRvalues_l=[minRvalues[0],minRvalues[1]]
                             minRvalues_l.sort()
                             groupUpFlowBaseRvalueList.sort()
                             groupDownFlowBaseRvalueList.sort()
                             minbaserval_up=groupUpFlowBaseRvalueList[0]
                             minbaserval_down=groupDownFlowBaseRvalueList[0]
                             minRValList=minRvalues_l+groupUpFlowBaseRvalueList+groupDownFlowBaseRvalueList
                             TestResult={}
                             TestResult[clientGroup]={}
                             WaveEngine.OutputstreamHDL("\nThe Results Summary For ClientGroup-%s w.r.t P/F criterion are::\n " %clientGroup,WaveEngine.MSG_SUCCESS)
                             if totalGroupRoams != 0:
                                if float(totalGroupHighDelayDrops)/totalGroupRoams <= float (self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']):
                                        TestResult[clientGroup]['USC:DC']= 'PASS'
                                        WaveEngine.OutputstreamHDL("---Test Has achieved the Pass/Fail criteria configured by the User:: User-%s,Achieved-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']*100,(totalGroupHighDelayDrops*100)/totalGroupRoams),WaveEngine.MSG_SUCCESS)
                                else:
                                        TestResult[clientGroup]['USC:DC']= 'FAIL'
                                        WaveEngine.OutputstreamHDL("---Test Has failed to achieve the Pass/Fail criteria configured by the User:: User-%s,Achieved-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_drop_calls']*100,(totalGroupHighDelayDrops*100)/totalGroupRoams),WaveEngine.MSG_WARNING)
                                temp_r=0
                                for each in minRValList:
                                   if each < self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']:
                                      temp_r= temp_r+1
                                if temp_r == 0:
                                   TestResult[clientGroup]['USC:RV']='PASS'
                                   WaveEngine.OutputstreamHDL("---All the achieved R-vlaue are greater than that of set by the user::User-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']),WaveEngine.MSG_SUCCESS)
                                else:
                                   TestResult[clientGroup]['USC:RV']='FAIL'
                                   WaveEngine.OutputstreamHDL("---Atleast one of the achieved R-vlaue are lesser than that of set by the user::User-%s\n" %(self.UserPassFailCriteria[clientGroup]['ref_min_rvalue']),WaveEngine.MSG_WARNING)
                             else:
                                  
                                 TestResult[client]['USC:DC']= 'INVALID'
                                 TestResult[client]['USC:RV']= 'INVALID'
                             self.ResultsForCSVfile.append([clientGroup, ssid, totalGroupRoams,
                                               totalGroupHighDelayDrops,
                                               totalGroupRoamFailDrops,
                                               groupAvgDelay,
                                              "%0.2f"%avgBaseUpRval,"%0.2f"%avgBaseDownRval,
                                              "%0.2f"%avgUpRval, "%0.2f"%avgDownRval,
                                              TestResult[client]['USC:DC'],
                                              TestResult[client]['USC:RV']])
                             cgDetails = (clientGroup, ssid, totalGroupRoams,
                                            totalGroupHighDelayDrops, totalGroupRoamFailDrops,
                                            groupAvgDelay, baselineRvaluesStr,
                                            avgRvalsStr,TestResult[client]['USC:DC'],
                                            TestResult[client]['USC:RV'])

                else:   
                            cgDetails = (clientGroup, ssid, totalGroupRoams,
                             totalGroupHighDelayDrops, totalGroupRoamFailDrops,
                             groupAvgDelay, baselineRvaluesStr,
                             avgRvalsStr)
  
                            self.ResultsForCSVfile.append([clientGroup, ssid, totalGroupRoams,
                                               totalGroupHighDelayDrops,
                                               totalGroupRoamFailDrops, 
                                               groupAvgDelay,
#                                              "%0.2f"%groupMinCallDuration,
#                                              "%0.2f"%groupMaxCallDuration, 
#                                              "%0.2f"%groupAvgCallDuration, 
                                              "%0.2f"%avgBaseUpRval,"%0.2f"%avgBaseDownRval,
                                              "%0.2f"%avgUpRval, "%0.2f"%avgDownRval])
                summaryTableDetails.append(cgDetails)
    #Min/Avg/Max R-value bar chart
        if self.totalClientsRoamed <= 25:
            rValueBarGraphXYDetails[1] = [upFlowBaseRvalList, minUpRvaluesList, 
                                          avgUpRvaluesList, maxUpRvaluesList] 
                                          
            rValueBarGraphXYDetails[2] = [downFlowBaseRValsList, minDownRvaluesList,
                                          avgDownRvaluesList, maxDownRvaluesList]
            theoriticalMaxRval = self.getMaxTheoriticalRvalMOS()[0]
            rValueBarGraphXYDetails[3] = theoriticalMaxRval

            mosValueBarGraphXYDetails[1] = [upFlowBaseMoSvaluesList, minUpMoSvaluesList,
                                            avgUpMoSvaluesList,maxUpMoSvaluesList]
            mosValueBarGraphXYDetails[2] = [downFlowBaseMoSvaluesList, minDownMoSvaluesList,
                                            avgDownMoSvaluesList, maxDownMoSvaluesList]
            theoriticalMaxMOS = self.getMaxTheoriticalRvalMOS()[1]
            mosValueBarGraphXYDetails[3] = theoriticalMaxMOS
            
            #Write data to Results csv file
            self.ResultsForCSVfile.append(('Graph:Min/Avg/Max R-value bar graph',))
            self.ResultsForCSVfile.append(('X-Axis values',))
            self.ResultsForCSVfile.append(rValueBarGraphXYDetails[0])
            self.ResultsForCSVfile.append(('Y-Axis values',))
            self.ResultsForCSVfile.append(('Legends',))
            rValMinAvgMaxLegends = ['UpStreamBaselineRvalue', 'UpStreamMinRvalue',
                                   'UpStreamAvgRvalue', 'UpStreamMaxRvalue', 
                                   'DownStreamBaselineRvalue', 'DownStreamMinRvalue', 
                                   'DownStreamAvgRvalue','DownStreamMaxRvalue']

            rValMinAvgMaxValues = [upFlowBaseRvalList, minUpRvaluesList, avgUpRvaluesList,
                                   maxUpRvaluesList, downFlowBaseRValsList, 
                                   minDownRvaluesList, avgDownRvaluesList, 
                                   maxDownRvaluesList, upFlowBaseRvalList, 
                                   minUpRvaluesList, avgUpRvaluesList, 
                                   maxUpRvaluesList, downFlowBaseRValsList, 
                                   minDownRvaluesList, avgDownRvaluesList, 
                                   maxDownRvaluesList]
            for i, legend in enumerate(rValMinAvgMaxLegends):
                self.ResultsForCSVfile.append((legend,))
                #for val in rValMinAvgMaxValues[i]:
                self.ResultsForCSVfile.append(["%0.2f"%val for val in 
                                               rValMinAvgMaxValues[i]]) 

            self.ResultsForCSVfile.append(('Graph:Min/Avg/Max MOS value bar graph',))
            self.ResultsForCSVfile.append(('X-Axis values',))
            self.ResultsForCSVfile.append(mosValueBarGraphXYDetails[0])
            self.ResultsForCSVfile.append(('Y-Axis values',))
            self.ResultsForCSVfile.append(('Legends',))    
            mosValLegends = ['UpStreamBaselineMoSvalue', 'UpStreamMinMoSvalue',
                             'UpStreamAvgMoSvalue', 'UpStreamMaxMoSvalue',
                             'DownStreamBaselineMoSvalue', 'DownStreamMinMoSvalue', 
                             'DownStreamAvgMoSvalue','DownStreamMaxMoSvalue']
            mosValMinAvgMaxValues = [upFlowBaseMoSvaluesList, minUpMoSvaluesList, 
                                     avgUpMoSvaluesList, maxUpMoSvaluesList, 
                                     downFlowBaseMoSvaluesList, minDownMoSvaluesList,
                                     avgDownMoSvaluesList, maxDownMoSvaluesList]
            for i, legend in enumerate(mosValLegends):
                self.ResultsForCSVfile.append((legend,))
                #for val in rValMinAvgMaxValues[i]:
                self.ResultsForCSVfile.append(["%0.2f"%val for val in 
                                               mosValMinAvgMaxValues[i]])   
            """
            RoamDelay Vs Time Graph to be hidden for now
            
            (roamDelayVsTimeXvals, roamDelayVsTimeYvals, roamDelayVsTimeLegends) = \
                self.constructRoamDelayVsTimeGraphInfo()
            roamDelayVsTimeDetails = (roamDelayVsTimeXvals, roamDelayVsTimeYvals, 
                                       roamDelayVsTimeLegends)
            
            self.ResultsForCSVfile += [("Graph: Roaming Delay Vs Time (for Clients)",),
                                   ('X-Axis values',), (roamDelayVsTimeXvals),
                                   ('Y-Axis values',), ('Legends',)]
            for clientName, roamDelays in  zip(roamDelayVsTimeLegends, 
                                                   roamDelayVsTimeYvals):
                self.ResultsForCSVfile.append((clientName,))
                self.ResultsForCSVfile.append((roamDelays))
            """    

        if self.totalClientsRoamed > 25:
    #R-Value bin counts bar chart    
            #Initialisation
            rValueBinGraphData, mosValueBinGraphData = self.computeRvalMoSvalBinGraphsData()
            
            rValueBinsGraphDetails, mosValueBinsGraphDetails = \
                self.computeRvalMoSvalBinGraphsInfo(rValueBinGraphData, 
                                                    mosValueBinGraphData)
            


                    
    #Construct data for CallDrop Vs Time line graph
        (cumulDropsOverTimeXvals, cumulDropsOverTimeYvals, cumulDropsOverTimeLegends) = \
                        self.constructCumulDropsOverTimeGraphInfo()
            
        cumulCallDropsVsTimeDetails = (cumulDropsOverTimeXvals, cumulDropsOverTimeYvals,
                                       cumulDropsOverTimeLegends)  
        
        self.ResultsForCSVfile += [("Graph: Cumulative Dropped Calls Vs Time (for Groups)",),
                                   ('X-Axis values',), (cumulDropsOverTimeXvals),
                                   ('Y-Axis values',), ('Legends',)]
        for groupNameinList, groupList in  zip(cumulDropsOverTimeLegends, cumulDropsOverTimeYvals):
            self.ResultsForCSVfile.append((groupNameinList[0],))
            self.ResultsForCSVfile.append((groupList))
            
    #store the info into 'results' and return it
        results = []    
        results.append(summaryTableDetails)
        results.append(rValueBarGraphXYDetails)
        results.append(mosValueBarGraphXYDetails)
        results.append(roamDelayVsTimeDetails)
        results.append(rValueBinsGraphDetails)
        results.append(mosValueBinsGraphDetails)
        results.append(cumulCallDropsVsTimeDetails)
        
        return results
    
    def PrintReport(self, results):                
        """
        
        ProcessStats provides the data to be written to the report. Take the data, write
        it into report and also Results_roaming_service_quality.csv file
        
        """

        summaryTableDetails = results[0]
        roamEffectRvalBarGraphXYDetails = results[1]
        roamEffectMoSvalBarGraphXYDetails = results[2]
        roamDelayVsTimeDetails = results[3]
        rValueBinsGraphDetails = results[4]
        mosValueBinsGraphDetails = results[5]
        cumulCallDropsVsTimeDetails = results[6]
        
        overview = "The Roaming Service Quality test determines the effect of roaming \
                    on call quality as measured by the R-value and dropped calls. The \
                    test measures the anticipated drop in call quality when wireless \
                    clients begin to roam from one AP to another."
                    
        self.Print("Generating the Report. Please wait..\n")
        
        self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, 
                                                self.ReportFilename))
        if self.MyReport.Story == None:
            return
        self.MyReport.Title("Roaming Service Quality Report", self.DUTinfo, self.TestID)
        self.MyReport.InsertHeader("Overview")
        self.MyReport.InsertParagraph(overview)

        self.MyReport.InsertHeader("Results Summary")
        self._insertSummaryTable(summaryTableDetails)

        if self.totalClientsRoamed <= 25:
            self._insertMinAvgMaxGraphs(roamEffectRvalBarGraphXYDetails,
                                        roamEffectMoSvalBarGraphXYDetails)
            self._insertDelayVsTimeGraph(roamDelayVsTimeDetails)
        elif self.totalClientsRoamed > 25:
            self._insertPieCharts(rValueBinsGraphDetails, mosValueBinsGraphDetails)
            #self._insertBinGraphs()

        self._insertCumulDropsVsTimeGraph(cumulCallDropsVsTimeDetails)

        configSummary = self.generateConfigSummary()
        self._insertTestConfigIntoReport(configSummary)
        
        self._insertTestMethodology()
        
        self.insertAPinfoTable(self.RSSIfilename)
        
        self._insertOtherInfoTable()
        
        self.MyReport.Print()                               
   
    def _insertSummaryTable(self, summaryTableDetails):
        #self.MyReport.InsertHeader("Summary Table")
        tableDescription = "The following table summarizes the results of the \
                            Roaming Service Quality Test. It compares the call quality \
                            experienced by clients before and after roaming. The table \
                            shows the total number of roams that were executed by the \
                            roaming clients, the number of calls that exceeded the call\
                            delay threshold set by the user, the number of calls that \
                            failed to roam successfully, the average roam delay \
                            experienced by the roaming clients, the quality of calls \
                            before clients roam and finally the average quality of calls \
                            of the roaming clients."
        self.MyReport.InsertParagraph(tableDescription)
        if self.totalClientsRoamed <= 25:
            if  self.UserPassFailCriteria['user'] == "True":
                     self.MyReport.InsertDetailedTable(summaryTableDetails,
                                              [1.25*inch, 1.25*inch, 0.5*inch,
                                               0.6*inch, 0.5*inch, 0.5*inch,
                                               0.95*inch, 0.95*inch,0.6*inch,0.6*inch])
            else:
                     self.MyReport.InsertDetailedTable(summaryTableDetails,
                                              [1.25*inch, 1.25*inch, 0.5*inch,
                                               0.6*inch, 0.5*inch, 0.5*inch,
                                               0.95*inch, 0.95*inch])
        else: 
            self.MyReport.InsertDetailedTable(summaryTableDetails, 
                                              [1.25*inch, 1.25*inch, 0.5*inch,
                                               0.6*inch, 0.5*inch, 0.5*inch,
                                               0.95*inch, 0.95*inch])
        if  self.UserPassFailCriteria['user'] == "True":
            iteration_count=0
            pass_count_dc =0
            pass_count_rf=0
            pass_perc  =0
            ConfigParameters=[]
            NoteText=""" Note: Abbreviations used: USC-User Spefied Criteria,DC-Dropped Calls and RV- R-value  """
            self.MyReport.InsertParagraph(NoteText)
            self.MyReport.InsertHeader( "User Specified P/F criteria" )
            ConfigParameters.append(( 'Parameter', 'User defined Value', 'Overall Result' ))
            #print "SUmmart details are %s\n" %summaryTableDetails  
            for each_cg in summaryTableDetails[1:]:
               iteration_count=iteration_count+1
               if each_cg[-1] == 'PASS':
                     pass_count_rf=pass_count_rf+1
               if each_cg[-2]== 'PASS':
                     pass_count_dc=pass_count_dc+1
              # for each_value in each_cg:
              #      if each_value == 'PASS':
              #          pass_count=pass_count+1
            ConfigParameters.append(( 'Minimum Dropped Call Percentage',"%s" %self.UserPassFailCriteria[each_cg[0].split("-")[0]]['ref_min_drop_calls'],"Total:%s, PASS:%s and FAIL:%s"%(iteration_count,pass_count_dc,(iteration_count-pass_count_dc)))) 
            ConfigParameters.append(( 'Minimum R-value',"%s" %self.UserPassFailCriteria[each_cg[0].split("-")[0]]['ref_min_rvalue'],"Total:%s, PASS:%s and FAIL:%s"%(iteration_count,pass_count_rf,(iteration_count-pass_count_rf))))
            if (pass_count_rf != iteration_count) or (pass_count_dc != iteration_count):
                        self.FinalResult =3
            self.MyReport.InsertParameterTable( ConfigParameters, columns = [ 3.0*inch, 1.25*inch, 1.75*inch ] ) # 6-inch total
    
    def _insertMinAvgMaxGraphs(self, roamEffectRvalBarGraphXYDetails,
                               roamEffectMoSvalBarGraphXYDetails):
        legendVals = [['Baseline'], ['Min'],
                      ['Avg'], ['Max']] 
        theoriticalMaxRval = roamEffectRvalBarGraphXYDetails[3]
        theoriticalMaxMOS = roamEffectMoSvalBarGraphXYDetails[3]
        #R-value bar graph
        self.MyReport.InsertParagraph("The following graphs show the R-Value \
                                       distribution across all calls made \
                                       during the test")
        #Up Streams bar graph
        if len(roamEffectRvalBarGraphXYDetails[0]) > 0 and \
            len(roamEffectRvalBarGraphXYDetails[1]) > 0:
            roamEffectBarGraph1 = Qlib.GenericGraph(roamEffectRvalBarGraphXYDetails[0],
                                                    "",
                                                   roamEffectRvalBarGraphXYDetails[1], 
                                                   "R-value",
                                                   "Upstream Min/Avg/Max R-value", 
                                                   ['Bar'], legends = legendVals, 
                                                   splitgraph = False, dataLblDigits = 2,
                                                   xValsDisplayAngle = 80,
                                                   strictYbounds = {'lower':50.0,
                                                                     'upper': 100.0},
                                                   additionalLine = [0, 
                                                                     theoriticalMaxRval, 
                                                                     'END',
                                                                     theoriticalMaxRval,
                                                                     'Theoritical Max'])
            self.MyReport.InsertObject(roamEffectBarGraph1)
            self.testCharts["Upstream Min/Avg/Max R-value"] = roamEffectBarGraph1
        #Down Streams bar graph
        if len(roamEffectRvalBarGraphXYDetails[0]) > 0 and \
            len(roamEffectRvalBarGraphXYDetails[2]) > 0:
            roamEffectBarGraph2 = Qlib.GenericGraph(roamEffectRvalBarGraphXYDetails[0],
                                                    "",
                                                   roamEffectRvalBarGraphXYDetails[2], 
                                                   "R-value",
                                                   "Downstream Min/Avg/Max R-value", 
                                                   ['Bar'], legends = legendVals,
                                                   splitgraph = False, dataLblDigits = 2,
                                                   xValsDisplayAngle = 80,
                                                   strictYbounds = {'lower':50.0,
                                                                     'upper': 100.0},
                                                   additionalLine = [0, 
                                                                     theoriticalMaxRval, 
                                                                     'END',
                                                                     theoriticalMaxRval,
                                                                     'Theoritical Max'])
            self.MyReport.InsertObject(roamEffectBarGraph2)
            self.testCharts["Downstream Min/Avg/Max R-value"] = roamEffectBarGraph2
        #MOS score bar graphs
        self.MyReport.InsertParagraph("The following graphs show the MOS \
                                        distribution across all calls made \
                                        during the test")
        #Up Streams bar graph
        if len(roamEffectMoSvalBarGraphXYDetails[0]) > 0 and \
            len(roamEffectMoSvalBarGraphXYDetails[1]) > 0:
            roamEffectBarGraph3 = Qlib.GenericGraph(roamEffectMoSvalBarGraphXYDetails[0],
                                                    "",
                                                   roamEffectMoSvalBarGraphXYDetails[1],
                                                   "MOS",
                                                   "Upstream Min/Avg/Max MOS score", 
                                                   ['Bar'], legends = legendVals, 
                                                   splitgraph = False, dataLblDigits = 2,
                                                   xValsDisplayAngle = 80,
                                                   strictYbounds = {'lower':2.5,
                                                                    'upper': 5.0},
                                                    additionalLine = [0, 
                                                                     theoriticalMaxMOS, 
                                                                     'END',
                                                                     theoriticalMaxMOS,
                                                                     'Theoritical Max'])
            self.MyReport.InsertObject(roamEffectBarGraph3)
            self.testCharts["Upstream Min/Avg/Max MOS score"] = roamEffectBarGraph3
        #Down Streams bar graph
        if len(roamEffectMoSvalBarGraphXYDetails[0]) > 0 and \
            len(roamEffectMoSvalBarGraphXYDetails[2]) > 0:
            roamEffectBarGraph4 = Qlib.GenericGraph(roamEffectMoSvalBarGraphXYDetails[0],
                                                    "",
                                                   roamEffectMoSvalBarGraphXYDetails[2], 
                                                   "MOS",
                                                   "Downstream Min/Avg/Max MOS score", 
                                                   ['Bar'], legends = legendVals,
                                                   splitgraph = False, dataLblDigits = 2,
                                                   xValsDisplayAngle = 80,
                                                   strictYbounds = {'lower':2.5,
                                                                    'upper': 5.0},
                                                    additionalLine = [0, 
                                                                     theoriticalMaxMOS, 
                                                                     'END',
                                                                     theoriticalMaxMOS,
                                                                     'Theoritical Max'])
            self.MyReport.InsertObject(roamEffectBarGraph4)
            self.testCharts["Downstream Min/Avg/Max MOS score"] = roamEffectBarGraph4
    
    def _insertDelayVsTimeGraph(self, roamDelayVsTimeDetails):
        if len(roamDelayVsTimeDetails[0]) > 0 and \
            len(roamDelayVsTimeDetails[1]) > 0:
            self.MyReport.InsertParagraph("The following graph shows the \
                                            variation of roaming delay over \
                                            time during the test")
            roamDelayVsTimeGraph = Qlib.GenericGraph(roamDelayVsTimeDetails[0], "Time",
                                                     roamDelayVsTimeDetails[1], "Roam Delay",
                                                     "Roam Delay Vs Time", 
                                                     ['Line'])
            self.MyReport.InsertObject(roamDelayVsTimeGraph)
            self.testCharts["Roam Delay Vs Time"] = roamDelayVsTimeGraph
    
    def _insertPieCharts(self, rValueBinsGraphDetails, mosValueBinsGraphDetails):
        chartHeight = 1.5*inch
        chartWidth = 1.5*inch
        if len(rValueBinsGraphDetails) > 0:
            #self.MyReport.InsertHeader('R-Value Distribution')
            chartBaseUpRval = [rValueBinsGraphDetails[0][1], 
                               rValueBinsGraphDetails[0][2], 
                               rValueBinsGraphDetails[0][0], 
                               chartHeight, chartWidth]
            chartUpRval = [rValueBinsGraphDetails[1][1], 
                           rValueBinsGraphDetails[1][2],
                           rValueBinsGraphDetails[1][0], 
                           chartHeight, chartWidth]
            chartBaseDownRval = [rValueBinsGraphDetails[2][1], 
                                 rValueBinsGraphDetails[2][2], 
                                 rValueBinsGraphDetails[2][0], 
                                 chartHeight, chartWidth]
            chartDownRval = [rValueBinsGraphDetails[3][1], 
                             rValueBinsGraphDetails[3][2], 
                             rValueBinsGraphDetails[3][0], 
                             chartHeight, chartWidth]
            
            self.MyReport.InsertParagraph("The below graph shows R-Value \
                                           distribution across all calls made \
                                           during the test.")
            rValueUpStreamCharts = Qlib.Chart(data = [chartBaseUpRval, 
                                                      chartUpRval])
            rValueDownStreamCharts = Qlib.Chart(data = [chartBaseDownRval, 
                                                        chartDownRval])
            self.MyReport.InsertObject(rValueUpStreamCharts)
            self.testCharts["R-value: Baseline UpStream & UpStream"] = rValueUpStreamCharts
            
            self.MyReport.InsertObject(rValueDownStreamCharts)
            self.testCharts["R-value: Baseline DownStream & DownStream"] = rValueDownStreamCharts
                
        if len(mosValueBinsGraphDetails) > 0:
            #self.MyReport.InsertHeader('MOS score Distribution')
            #labels = mosValueBinsGraphDetails[0]
            chartBaseUpRval = [mosValueBinsGraphDetails[0][1], 
                               mosValueBinsGraphDetails[0][2], 
                               mosValueBinsGraphDetails[0][0], 
                               chartHeight, chartWidth]
            chartUpRval = [mosValueBinsGraphDetails[1][1], 
                           mosValueBinsGraphDetails[1][2], 
                           mosValueBinsGraphDetails[1][0], 
                           chartHeight, chartWidth]
            chartBaseDownRval = [mosValueBinsGraphDetails[2][1], 
                                 mosValueBinsGraphDetails[2][2], 
                                 mosValueBinsGraphDetails[2][0], 
                                 chartHeight, chartWidth]
            chartDownRval = [mosValueBinsGraphDetails[3][1],
                             mosValueBinsGraphDetails[3][2], 
                             mosValueBinsGraphDetails[3][0], 
                             chartHeight, chartWidth]
            self.MyReport.InsertParagraph("The below graph shows MOS Score \
                                           distribution across all calls made \
                                           during the test.")

            mosScoreUpStreamCharts = Qlib.Chart(data = [chartBaseUpRval, 
                                                        chartUpRval])
            mosScoreDownStreamCharts = Qlib.Chart(data = [chartBaseDownRval, 
                                                          chartDownRval])
            self.MyReport.InsertObject(mosScoreUpStreamCharts)
            self.testCharts["MOS score: Baseline UpStream & UpStream"] = mosScoreUpStreamCharts
            
            self.MyReport.InsertObject(mosScoreDownStreamCharts)
            self.testCharts["MOS score: Baseline DownStream & DownStream"] = mosScoreDownStreamCharts
    """
    def _insertBinGraphs(self):
        #Inser R-Value bins graph
        if len(rValueBinsGraphDetails[0]) > 0 and \
            len(rValueBinsGraphDetails[1]) > 0:
            legendVals = [['Baseline Upstream'],['Upstream'],['Baseline Downstream'],
                          ['Downstream']]
            self.MyReport.InsertParagraph("The below graph shows R-Value \
                                           distribution across all calls made \
                                           during the test.")
            rValueBinsGraph = Qlib.GenericGraph(rValueBinsGraphDetails[0], "R-Value Bins",
                                                rValueBinsGraphDetails[1], 
                                                "Percentage of Observations",
                                                "R-Value Distribution",
                                                ['Bar'], legends = legendVals, 
                                                splitgraph = False, dataLblDigits = 2,
                                                dataLabelAngle = 80, 
                                                strictYbounds = {'upper': 100.0})
            self.MyReport.InsertObject(rValueBinsGraph)
            
        
        #Insert MOS score bins graph
        if len(mosValueBinsGraphDetails[0]) > 0 and \
            len(mosValueBinsGraphDetails[1]) > 0:
            legendVals = [['Baseline Upstream'],['Upstream'],['Baseline Downstream'],
                          ['Downstream']]
            self.MyReport.InsertParagraph("The below graph shows MOS Score \
                                           distribution across all calls made \
                                           during the test.")
            mosScoresBinsGraph = Qlib.GenericGraph(mosValueBinsGraphDetails[0], 
                                                   "MOS score bins",
                                                   mosValueBinsGraphDetails[1],
                                                   "Percentage of Observations",
                                                   "MOS Score Distribution",
                                                   ['Bar'], legends = legendVals, 
                                                   splitgraph = False, dataLblDigits = 2,
                                                   dataLabelAngle = 80, 
                                                   strictYbounds = {'upper': 100.0})
            self.MyReport.InsertObject(mosScoresBinsGraph)
    """
    def _insertCumulDropsVsTimeGraph(self, cumulCallDropsVsTimeDetails):
        if len(cumulCallDropsVsTimeDetails[0]) > 0 and \
            len(cumulCallDropsVsTimeDetails[1]) > 0:
            self.MyReport.InsertParagraph("The below graph shows the accumulation of \
                                           dropped calls over time during the test.")
            cumulCallDropVsTimeGraph = Qlib.GenericGraph(cumulCallDropsVsTimeDetails[0],
                                                         "Time (secs)",
                                                         cumulCallDropsVsTimeDetails[1], 
                                                         "Cumulative Dropped Calls",
                                                         "Cumulative Dropped Calls",
                                                         ['Line'], 
                                                         legends = cumulCallDropsVsTimeDetails[2],
                                                         splitgraph = False,
                                                         dataLblDigits = 0,
                                                         yAxisDigits = 0)
            self.MyReport.InsertObject(cumulCallDropVsTimeGraph)
            self.testCharts["Cumulative Dropped Calls"] = cumulCallDropVsTimeGraph
            
    def _insertTestMethodology(self):
        #The Paragraph class of report object doesn't respect the '\n' in the text, 
        #so sub paragraphs won't exist, insert paragraphs instead
        testMethodologySub1 = "The test emulates several groups of clients roaming \
                                in specified roam patterns at a specified roam rate. \
                                Each client group has a roam pattern and all the \
                                clients in a group roam at the same rate. The clients \
                                in a group are distributed among the APs in that \
                                group's roam pattern."
                           
        testMethodologySub2 = "Clients within a group roam sequentially. The roam \
                                pattern of the group is cyclical. If a client reaches \
                                the end of a cycle or the starting point, it continues \
                                to roam using the same roam pattern. For every group \
                                the clients in that group roam one step-at-a-time \
                                until all the clients in the group execute one roam. \
                                All clients in a group complete one roam step before \
                                the clients in next group start roaming. This roam \
                                pattern repeats until the end of test duration."

        testMethodologySub3 = "At the start of the test, each client stays at their \
                                starting port for the baseline amount of time, making \
                                a VoIP call. The R-Value of this call is calculated \
                                and forms the baseline R-Value for the client. At \
                                every roam event, the test captures the R-value. \
                                The R-value calculated just before the first roam of \
                                any client (which comes after the baseline call \
                                R-value) is ignored because this R-value is a snapshot \
                                for a very short time period."
                               
        testMethodologySub4 = "When the roam delay of a client's roam is more than \
                                the specified threshold, the client's call is \
                                considered dropped. When a call is dropped, the \
                                test establishes a new call for that client."
                                
        self.MyReport.InsertHeader("Test Methodology")
        self.MyReport.InsertParagraph(testMethodologySub1)
        self.MyReport.InsertParagraph(testMethodologySub2)
        self.MyReport.InsertParagraph(testMethodologySub3)
        self.MyReport.InsertParagraph(testMethodologySub4)
        
    def _insertTestConfigIntoReport(self, configSummary):
        self.MyReport.InsertHeader("Test Configuration")
        roamSummary = [('Group', 'Network', 'Security', '#Clients',
                        'Roam Sequence' , 'Traffic Source')] 
        columnsList = [0.65*inch, 1.0*inch, 1.0*inch, 0.6*inch, 2.5*inch, 0.65*inch]
        for CG in [x for x in configSummary.keys() if x != 'Test Config']:
            Config = configSummary[CG]
            resultTuple = (CG, Config['Network'], Config['Security'], 
                           Config['#Clients'], Config['Roam Sequence'],
                           Config['Traffic Source'])
            roamSummary.append(resultTuple)
        
        self.MyReport.InsertDetailedTable(roamSummary, columns = columnsList)
        
        testSpecificConfigTuple = [('Test Duration', 'Client Roam Rate (per min)',
                                    'SUT Roam Rate (per min)', 'VoIP Codec', 
                                    'Call Drop Delay Threshold',
                                   'Baseline Call Duration')]
        columnList = [1.0*inch, 1.0*inch, 1.0*inch, 0.75*inch, 1.25*inch, 1.0*inch]
        testSpecificConfig = configSummary['Test Config']
        testSpecificConfigTuple.append( (testSpecificConfig['Test Duration'],
                                         testSpecificConfig['Client Roam Rate'],
                                         testSpecificConfig['SUT Roam Rate'],
                                         testSpecificConfig['VoIP Codec'],
                                         testSpecificConfig['Call Drop Delay Threshold'],
                                         testSpecificConfig['Baseline Call Duration']))
        self.MyReport.InsertDetailedTable(testSpecificConfigTuple, 
                                          columns = columnList)

        
    def _insertOtherInfoTable(self):
        self.MyReport.InsertHeader("Other Info")
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        for item in self.OtherInfoData.items():
            OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        self.MyReport.InsertGenericTable( OtherParameters , 
                                          columns = [ 1.5*inch, 4.5*inch ] )
        
    def getCharts(self):
        """ Returns test-specific chart objects in a dictionary."""
        
        return self.testCharts
        
    def collectLastRoamDetails(self):
        self.totalClientsRoamed = 0
        for cgName in self.Clientgroup:
            clientDict = self.Clientgroup[cgName].GetClientdict()
            for clientName in clientDict:
                upFlows = clientDict[clientName].getUpFlowList()
                downFlows = clientDict[clientName].getDownFlowList()
                secMethod = clientDict[clientName].GetSecurity()['Method']
                ssid = clientDict[clientName].Getssid()
                noStatsF, roamDelay, failedStep = RSQEC.processPreviousRoamStats(cgName, clientName, 
                                                              upFlows, downFlows,
                                                              secMethod, ssid, 
                                                              returnNoStatsF = True)
                RSQEC.reportPreviousRoamStatus(clientName, roamDelay, failedStep)

                if noStatsF:
                    RSQEC.addNullStatsToNoRoamClients(cgName, clientName, ssid,
                                                      upFlows, downFlows)
                else:
                    #The client had at least one roam
                    self.totalClientsRoamed += 1
                    
    def _loadTestKeyAndName(self):
        self.testKey = 'voip_roam_quality'
        self.testName = 'Roaming Service Quality'
    
    def _getCommonRoamOptions(self):
        commonRoamOptions = ['deauth', 'preauth', 'disassociate', 'dwellTime',
                             'pmkid', 'reassoc', 'durationUnits','repeatValue',
                             'repeatType', 'renewDHCP','renewDHCPonConn', 
                             'powerProfileFlag']
        return commonRoamOptions
    
    
    def _loadTestSpecificData(self, waveClientTableStore, waveTestSpecificStore,
                              waveSecurityStore, roaming_data, 
                              enabledGroups, wlanGroups, roamGroups):
        RoamBenchCommon._loadTestSpecificData(self, waveClientTableStore, 
                                              waveTestSpecificStore,
                                              waveSecurityStore, roaming_data, 
                                              enabledGroups, wlanGroups, roamGroups)
        
        self.roamInterval *= 60    #The unit is 'minutes' not 'seconds'
        baseCallDurationUnits = (waveTestSpecificStore['voip_roam_quality']
                                 ['callTrafficOptions']['baseCallDurationUnits'])
        self.baseCallDurationVal = int(waveTestSpecificStore['voip_roam_quality']
                                       ['callTrafficOptions']
                                       ['baseCallDurationVal'])
        if int(baseCallDurationUnits) == 1: #minutes
            self.baseCallDurationVal *= 60
        elif int(baseCallDurationUnits) == 2: #hours
            self.baseCallDurationVal *= 3600
        self.setCallDropDelayThreshold(float(waveTestSpecificStore['voip_roam_quality']
                                             ['callTrafficOptions']
                                             ['callDropDelayThreshold']))
        
        #Load CallTrafficOptions
        self.callTrafficOptions = waveTestSpecificStore[self.testKey]['callTrafficOptions']
    
    
    def _createMainFlowList(self, roamGroups, roaming_data, waveClientTableStore, 
                            waveTestStore, waveTestSpecificStore):
        profMap = {}
        for i, clientgroupName in enumerate(roamGroups):
            MflowName = 'Flow' + str(i+1)
            Mprofile = {}
            Mprofile['Type'] = (waveTestSpecificStore[self.testKey]['callTrafficOptions']
                                                                    ['voipCodec'])
            
            self.MainFlowlist[MflowName] = Mprofile
            
            profMap[clientgroupName] = MflowName
        return profMap
    
    def _updateClientGroupProfile(self, roaming_data):
        
        for group in self.Clientgroups:
            clientGrpProfile = self.Clientgroups[group]
            clientGrpProfile['QoSenabledF'] = False
            if self.callTrafficOptions['QoSEnabled'] in [True, 'True']:
                clientGrpProfile['QoSenabledF'] = True
    
    #The name 'nonRoamGroups' is misleading because self.nonRoamGroups is now (release 2.4)
    #Eth groups only, it was created when the app design included wlan group which would 
    #be stationary (i.e., not roam). Due to the time constraints not making changes to the 
    #variables & methods with the term 'nonRoam' as part of their name, make the changes
    #after the release
    def run(self):
        try:
            self.ExitStatus = 0
            WaveEngine.setPortInfo({})
            WaveEngine.setPortBSSID2SSID({})
            WaveEngine.OpenLogging(Path = self.LoggingDirectory,
                                   Detailed = self.DetailedFilename)
            self.setRealtimeCallback(self.PrintRealtimeStats)
            RSQEC.clearRoamServGlobals()
            self.ConfigureData()
            self.totalRoamClients = self.getTotalRoamClients()
            self.generateClientConfig()
            self.validateInitialConfig()
            self.configurePorts()
            self.initailizeCSVfile()
            #Create and connect Eth Clients
            clientTuples = self.createNonRoamClientTuple(self.nonRoamGroups)
            (self.nonRoamClientGroups,
            clientList)            = self.createNonRoamClients(clientTuples)
            self.connectNonRoamClients(clientList)
            #Create and Connect Roam Clients
            allClientsDict = self.createAndConnectRoamClients(True)
            self.writeAPinformation(allClientsDict)
            roamFlowObjects = self.configureFlows()
            (srcCGFlows, DstCGFlows) = self.createFlows(roamFlowObjects)
            self._configureClientObjectsFlows(self.FlowList)
            self.configureToS(srcCGFlows, DstCGFlows, self.callTrafficOptions)
            self.configureVoipPorts(srcCGFlows, DstCGFlows, self.callTrafficOptions)
            self.configureWlanQoS(self.FlowList, self.callTrafficOptions)
            if self.createFlowGroups() == -1:
                raise WaveEngine.RaiseException
            self.addClientFlows()
            self.setNATflag() 
            self.doAllArpExchanges()
            self.checkRoamOppurtunities()
            self.initialiseGlobalgClients()
            WaveEngine.ClearAllCounter(self.CardList)
            self.startFlows()
            self.calcBaselineCallRValues()
            self.settleForInitialSnapshot()

            if self.splitRunF == False:
                self.Generateclients()
                self.validateRoamConfig()
                self.startTest(self.RealtimeCallback)
            else:
                self.startSplitTest()
            self.settleSUT()
            self.collectLastRoamDetails()
            self.stopFlows()
            results = self.processStats()
            self.SaveResults()    #Save the results in to self.CSVFilename .csv file
            if self.generatePdfReportF:
                self.PrintReport(results)
            #Update the csv results, pdf charts (if opted by the user) in the GUI
            #'Results' page
            self.ExitStatus=self.FinalResult 
            self.updateGUIresultsPage()
            #self.PrintReport()
            #self.SaveResults()
        except WaveEngine.RaiseException:
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
            
def computeBinCountDict(binBounds, valuesList):
    """
    
    Given a list of values, return the % of those values which fall
    into bins defined by the elements in binBounds, binBounds[0] is only for computational
    purposes, the dictionary to be returned wouldn't contain an element with key 
    binBounds[0] but all other elements in binBounds
    """
    binsDict = {}
    binBounds.sort()
    for key in binBounds:
        binsDict[key] = 0
    
    for value in valuesList:
        for i, bound in enumerate(binBounds):
            if i > 0:
                if binBounds[i-1] <= value < binBounds[i]:
                    bin = binBounds[i]
                    break
            else:
                #Dummy value, which would be deleted
                bin = binBounds[0]
                
        binsDict[bin] += 1
    
    #binsDict is mapped with upper bounds of the bins as the key, so we won't be using
    #the first value given in binBounds
    del binsDict[binBounds[0]]
    
    return binsDict
    
def computeMoSequivalent(rValue):
    """
    mosValue = computeMoSequivalent(rValue) , rValue could be a single float or
    a list of floats. mosValue would be the MOS equivalent of the rValue if rValue 
    is a float, mosValue would be a list of MOS equivalents of the values in rValue
    if rValue is a list
    
    """
    mosValueList = []
    if not isinstance(rValue, list):
        rValueList = [rValue]
        notListF = True
    else:
        rValueList = rValue
        notListF = False
        
    for rValue in rValueList:
        mosValue = (1.0 - (7.0 * rValue / 1000.0) +  
                    (7.0 * (rValue ** 2.0) / 6250.0) - 
                    (7.0 * (rValue ** 3.0)/ 1000000.0))
        mosValueList.append(mosValue)
    
    if notListF:
        return  mosValueList[0]   
    else:
        return mosValueList
    
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

    WaveEngine.SetOutputStream(PrintToConsole)
    if options.filename != None:
        retval = userTest.loadFile( options.filename )
    if options.logs:
        userTest.SavePCAPfile = True

    userTest.run()
    sys.exit(userTest.ExitStatus)
