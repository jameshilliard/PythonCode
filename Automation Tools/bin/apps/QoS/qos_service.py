from vcl import *
import WaveEngine as WE
import Qlib
from basetest import *
from qos_common import setVoipPorts, comupteToSByte
from qos_common import QosCommon
from optparse import OptionParser
from socket import inet_ntoa
import struct
from odict import *
import traceback
import time
import math
import os
import os.path
import sched
import copy

class Test(QosCommon, BaseTest):
    
    def __init__(self):
        BaseTest.__init__(self)

        #-------------- Test Timings ----------------------
        """
        numTrials      - Number of trials to be run.
        settleTime      - Number of seconds to wait between each trial.
        """
        self.Trials        = 2
        self.TransmitTime  = 10
        self.SettleTime    = 2
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
        self.CardMap = { 'WT90_E1': ( 'wt-tga-xx-xx', 4, 0, 'on', 100, 'full' ),
                         'WT90_W1': ( 'wt-tga-xx-xx', 9, 0,  10 ),
                         'WT90_W2': ( 'wt-tga-xx-xx', 2, 0,  11 )
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
          'bssid': <bssid>     - Type : string
          'security' : <security options> - Type : dictionary.
        """
        self.NetworkList = {
                           'CiscoSec': {'ssid': 'cisco_sec',
                           'bssid' : '00:12:44:b1:7e:b0',
                           'security': self.Security_WPA2}, 

                           'Cisco1': {'ssid': 'cisco',
                           'bssid' : '00:12:7f:47:e1:c0',
                           'security': self.Security_None}, 

                           'Cisco3': {'ssid': 'cisco',
                           'bssid' : '00:12:44:b1:7e:b0',
                           'security': self.Security_None}, 

                           'Cisco2': {'ssid': 'cisco',
                           'bssid' : '00:13:5f:0e:cb:10',
                           'security': self.Security_None}, 

                           'Trapeze' : {'ssid': 'Trapeze',
                           'bssid' : '00:0b:0e:1c:e4:00',
                           'security': self.Security_None},

                           'Colubris_NONE': {'ssid': 'roam_ap', 
                           'security': self.Security_None},
                           
                           'Symbol': {'ssid': 'OPEN',
                           'bssid' : '00:15:70:00:82:b0',
                           'security': self.Security_None},
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
        associate clients with the SUT. This includes the time required to 
        complete .1X authentications.  Units: associations/second.
        AssociateTimeout -  Amount of time the test will wait for a client 
        association to complete before considering iteration a failed 
        connection. Units: seconds; 
        AssociateRetries -  Number of attempts to retry the complete 
        association process for each client in the test.
        """
        self.BSSIDscanTime    = 1.5
        self.AssociateRate    = 10
        self.AssociateTimeout = 10 
        self.AssociateRetries = 0

        self.UserPassFailCriteria = {}
        self.UserPassFailCriteria['user']='False'
        self.TestResult= {}
        self.FinalResult=0
        #---------------------- Learning parameters --------------
        """
        These paramters are used to train the DUT/SUT about the clients and 
        flows that are used during the test.   Loss is not
        an issue during learning, only during the actual measurement.
        
        ClientLearningTime - The number of seconds that a Client will flood a 
        DNS request with its source IP address.  This is used to teach the AP 
        about the existance of a client if Security or DHCP is not suffiecient.
        ClientLearningRate - The rate of DNS request the client will learn with 
        in units of frames per second.
        FlowLearningTime   - The number of seconds that the actual test flows 
        will send out learning frames to populate the DUT/SUT forwarding table.
        The rate is at the configure test rate. 
        FlowLearningRate   - The rate of flow learning frames are transmitted 
        in units of frames per second.  This should be set lower than the 
        actual offered loads.
        """
        self.ClientLearningTime = 1
        self.ClientLearningRate = 10
        self.FlowLearningTime   = 1
        self.FlowLearningRate   = 100

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
        self.CSVfilename      = 'Results_qos_service.csv'
        self.ReportFilename   = 'Report_qos_service.pdf'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False
        self.DetailedFilename = 'Detailed_qos_service.csv'
        self.RSSIFilename = 'RSSI_qos_service.csv'

        #------------------- Flow Parameters ----------------
        """
        These parameters determine the type of data frames and flows to be 
        used in the test.
        Any of the defined flows can then be attached to a Mapping.
        A FlowConfigs is a dictionary of 'Flowname' : 
        {Key : Value pairs} . 
        Key : Value pairs can be
        'Type' : Packet or frame type. Valid values: 'UDP', 'TCP', 'IP', 'ICMP'
        'FrameSize' : frame size . Type <integer>
        'PhyRate' : rate. Type <integer>
        'RateMode' : 'pps'
        'IntendedRate' : Traffic rate. Type <integer>
        'NumFrames' : Max frames to be sent. Type <integer>
        """
        self.FlowConfigs = {
                            'Flow1': {'Type'         : 'VOIPG711', 
                                      'srcPort'      : 5003,
                                      'destPort'     : 5004,
                                      'PhyRate'      : 54, 
                                      'NumFrames'    : WE.MAXtxFrames,
                                      'UserPriority' : 7,
                                      'TosField'     : 0,
                                      },
                            'Flow2': {'Type'         : 'UDP', 
                                      'srcPort'      : 4000,
                                      'destPort'     : 4500,
                                      'FrameSize'    : 1500,
                                      'PhyRate'      : 54, 
                                      'RateMode'     : 'pps',
                                      'IntendedRate' : 100, 
                                      'NumFrames'    : WE.MAXtxFrames,
                                      'UserPriority' : 2,
                                      'flowType'     : 'BKFlow',
                                      'bidirection'  : False
                                      },
                            }

        self.minBKRate         = 4000
        self.maxBKRate         = 5000
        self.incrPPS           = 10
        self.numCallsPerAP     = 20
        self.RvalueF           = True 
        self.RvalueResolution  = 1
        self.Rvalue            = 78
        self.latencyValueF     = False
        self.latencyValue      = 0.5
        self.latencyResolution = 1
        self.pktLossValueF     = False
        self.pktLossValue      = 5.0
        self.pktLossResolution = 1
        self.jitterValueF      = False
        self.jitterValue       = 0.8
        self.jitterResolution  = 1
        self.binarySearchFlag  = False
        self.bgFrameSize = 0
        self.testParameters    = odict.OrderedDict()    #Used for filling the test parameter table in the report
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
        'Port'     : The port defined in the cardMap. 
        'Gateway'  : Gateway IP address for all the clients.
        'SubMask'  : Subnet mask for the IP addresses of the clients.
        'NumClients' : The number of wireless clients to be created in 
        this client group.
        'Security' : security profile name - This attaches a network 
        profile that gets configured for each of the clients. Not necessary
        if the client group is to be configured on a non-Wireless port.
        """
        self.ClientGroups = {
                            'Group1': {'Enable'     : True, 
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'    : '192.168.1.151', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.110',
                                       'SubMask'    : '255.255.255.0',
                                       'NumClients' : self.numCallsPerAP,
                                       'Security'   : 'Symbol',
                                       'QoSFlag'    : True, 
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable'
                                       },
                            'Group2': {'Enable'     : False,
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'    : '192.168.1.41', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.110',
                                       'SubMask'    : '255.255.255.0',
                                       'NumClients' : self.numCallsPerAP,
                                       'Security'   : 'Symbol',
                                       'QoSFlag'    : True,
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable' 
                                       },
                            'Group3': {'Enable'    : True, 
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'   : '192.168.1.201',
                                       'IPStep'    : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0', 
                                       'NumClients': self.numCallsPerAP,
                                       'VlanTag'   : 1,
                                       'QoSFlag'   : True,
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable' 
                                       },
                            'Group4': {'Enable'    : False,
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'   : '192.168.1.211',
                                       'IPStep'    : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0', 
                                       'NumClients': self.numCallsPerAP,
                                       'VlanTag'   : 1,
                                       'QoSFlag'   : True, 
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable'
                                       },
                            'Group5': {'Enable'     : True, 
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'    : '192.168.1.150', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.110',
                                       'SubMask'    : '255.255.255.0',
                                       'NumClients' : 1,
                                       'Security'   : 'Symbol',
                                       'QoSFlag'    : True, 
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable'
                                       },
                            'Group6': {'Enable'     : False,
                                       'StartMAC'   : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'    : '192.168.1.41', 
                                       'IPStep'     : '0.0.0.1',
                                       'Port'       : 'WT90_W1',
                                       'Gateway'    : '192.168.1.110',
                                       'SubMask'    : '255.255.255.0',
                                       'NumClients' : self.numCallsPerAP,
                                       'Security'   : 'Symbol',
                                       'QoSFlag'    : True,
                                       'VlanEnable': False, 
                                       'Dhcp'      : 'Disable'
                                       },
                            'Group7': {'Enable'    : True, 
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'   : '192.168.1.200',
                                       'IPStep'     : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0', 
                                       'NumClients': 1,
                                       'VlanTag'   : 1,
                                       'QoSFlag'   : True, 
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable'
                                       },
                            'Group8': {'Enable'    : False,
                                       'StartMAC'  : 'AUTO',
                                       'MACIncrMode': 'Decrement',
                                       'MACStep'    : 1,
                                       'StartIP'   : '192.168.1.210',
                                       'IPStep'     : '0.0.0.1',
                                       'Port'      : 'WT90_E1',
                                       'Gateway'   : '192.168.1.110',
                                       'SubMask'   : '255.255.255.0', 
                                       'NumClients': 1,
                                       'VlanTag'   : 1,
                                       'QoSFlag'    : True,
                                       'VlanEnable': False,
                                       'Dhcp'      : 'Disable'
                                       },
                            }

        """
        To setup clients for the test they will be placed into client groups. Each group is assigned to
        a logical port. Many different client groups can be defined and a port may have more than one group
        assigned to it. The client groups are divided between source(orginating traffic) and destination
        (receiving traffic). 
        Field Definitions:
          GroupName -  User defined name given to the client Group
          PortName -   Logical port name defined the CardMap.
          BSSID/SSID - The BSSID or SSID to which this client group will associate. BSSID will be in 
                       the form 00:11:22:33:44:55. SSID will be an ASCII text string. A BSSID of '00:00:00:00:00:00'
                       tells the system to pick the first on on the list
          MACaddress - The MAC address to use. Using the word 'DEFAULT' wiil cause a unique address to be
                       generated by the system. 
          IPaddress -  The Base IP address to use for this client group. Individual addresses for each client
                       in the group will be derived from the base IP address. An address of 0.0.0.0 implies that
                       DHCP will be used to obtain the client IP address. 
          SubNet    -  SubNet mask 
          Gateway -    Gateway address. 
          IncrTuple -  This is tuple of three values in the form (<count>, <MacIncrByte>, <IpIncrByte>). <count>
                       is the number of clients to create, <MacIncrByte> is the byte in the six byte MAC address
                       to increment (e.g. 00:00:00:00:10:02); Use the keyword 'DEFAULT' for automatic MAC incrementing.
                       <IpIncrByte> is the byte in the four byte IP address to increment (e.g. 0.0.0.1 will increment the
                       last byte by 1). 
                       NOTE: An empty tuple - () means that just one client is being defined. 
          Security -   Name of security policy to use for this client group. 'NONE' will cause open security. 
                       Security policies only apply to WiFi clients. 
          Options -    Reference to a client option list as defined above. 
        Field Format: a list of tuples
          ( <GroupName>, <PortName>, <BSSID/SSID>, <MACaddress>, <IPaddress>, <SubNet>, <Gateway>, ( <IncrTuple> ), Security, <options> ),
          ( <GroupName2>, <PortName2>, <BSSID/SSID>, <MACaddress2>, <IPaddress2>, <SubNet2>, <Gateway2>, ( <IncrTuple2> ), Security2, <options2> )
        """                
        self.SourceClients = [('ClientEth', 'WT90_E1', '00:00:00:00:00:00', 'DEFAULT', '192.168.1.2',  '255.255.0.0', '192.168.1.1', (), self.Security_None, {})]
        self.DestClients   = [('ClientUno', 'WT90_W1', '00:00:00:00:00:00', 'DEFAULT', '192.168.1.120', '255.255.0.0', '192.168.1.1', (), self.Security_None, self.ClientOptions )]       
                
        #---------------- Flow Mapping Parameters ----------------
        """
        The FlowMappings is a dictionary that defines the characteristics of
        each flow that will be generated. 
        Each of the flowmaps is defined as 
        'MapName': {Key : Value pairs}
        Key : Value pairs can be
        'SrcCG' : The source clientgroup name, Type - string
        'DstCG' : The destination clientgroup name, Type - string
        'FlowName': The name of the flow profile that will be generated
        This has to be pre-defined in the self.FlowConfigs section.
        """  
        self.FlowMappings = {
                            'Map1' : {'SrcCG'       : 'Group3',
                                      'DstCG'       : 'Group1',
                                      'FlowName'    : 'Flow1',
                                      },
                            'Map2' : {'SrcCG'       : 'Group4',
                                      'DstCG'       : 'Group2',
                                      'FlowName'    : 'Flow1',
                                      },
                            'Map3' : {'SrcCG'       : 'Group7',
                                      'DstCG'       : 'Group5',
                                      'FlowName'    : 'Flow2',
                                      },
                            'Map4' : {'SrcCG'       : 'Group6',
                                      'DstCG'       : 'Group8',
                                      'FlowName'    : 'Flow2',
                                      }
                            }
        
#------------------------ End of User Configuration --------------------------
        self.searchResolution  = 0.01
        self.voiceNumFrames = 0        
        self.finalGraphs = odict.OrderedDict()
        self.voiceUserPriority = None
        self.backgroundUserPriority = None        
    
    def getTestName(self):
        
        return 'qos_service'
    
    def createClientTuple(self, clientGroups):
        clientsPerCG = OrderedDict()
        groups = clientGroups.keys()
        groups.sort()
        for group in groups:
            groupProperties = clientGroups[group]
            if not self.isCGEnabled(groupProperties):
                continue
            clientData = ()
            clientData += (group,)
            if not 'Port' in groupProperties.keys():
                self.Print("Port not found in %s\n" % group, 'ERR')
                continue
            port = groupProperties['Port']
            clientData += (port,)
            securityData = {}
            
            if not 'Security' in groupProperties.keys():
                self.Print("Security not found in %s\n" % group, 'ERR')
                continue
            security = groupProperties['Security']
            if security not in self.NetworkList.keys():
                self.Print("%s not found in NetworkList\n" % security, 
                      'ERR')
                continue
            securityData = self.NetworkList[security]            
            
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes:
                if 'bssid' not in securityData.keys():
                    self.Print("bssid not found in %s\n" % securityData,
                          'ERR')
                    continue
                bssid = securityData['bssid']
            else:
                bssid = '00:00:00:00:00:00'
            clientData += (bssid,)
            if not 'StartMAC' in groupProperties.keys():
                self.Print("StartMAC not found in %s\n" % group, 'ERR')
                continue
            clientData += (groupProperties['StartMAC'],)
            if groupProperties['Dhcp'] == 'Enable':
                #Inform Waveengine.Createclients by giving IP:0.0.0.0 that client gets IP by Dhcp 
                clientData += ('0.0.0.0',)    
                clientData += ('',)           #subnet mask
                clientData += ('',)           #Gateway
            elif groupProperties['Dhcp'] == 'Disable':
                if not 'StartIP' in groupProperties.keys():
                    self.Print("StartIP not found in %s\n" % group, 'ERR')
                    continue
                clientData += (groupProperties['StartIP'],)
                if not 'SubMask' in groupProperties.keys():
                    self.Print("SubMask not found in %s\n" % group, 'ERR')
                    continue
                clientData += (groupProperties['SubMask'],)
                if not 'Gateway' in groupProperties.keys():
                    self.Print("Gateway not found in %s\n" % group, 'ERR')
                    continue
                clientData += (groupProperties['Gateway'],)
            incrTuple = ()
            if not 'NumClients' in groupProperties.keys():
                self.Print("NumClients not found in %s\n" % group, 'ERR')
                continue
            incrTuple += (groupProperties['NumClients'],)
            if groupProperties['StartMAC'] == 'DEFAULT':
                incrTuple += ('DEFAULT',)
            elif groupProperties['StartMAC'] == 'AUTO':
                incrTuple += ('AUTO',)
            else:
                if not 'MACIncrMode' in groupProperties.keys():
                    self.Print("MACIncrMode not found in %s\n" % group, 'ERR')
                    continue
                mode = groupProperties['MACIncrMode']
                if not 'MACStep' in groupProperties.keys():
                    self.Print("MACStep not found in %s\n" % group, 'ERR')
                    continue
                macIncrInt = int(groupProperties['MACStep'])
                if mode.upper() == 'INCREMENT':
                    macIncrMac = MACaddress().inc(macIncrInt)
                else:
                    macIncrMac = MACaddress().dec(macIncrInt)
                incrTuple += (macIncrMac.get(),)
            if not 'IPStep' in groupProperties.keys():
                self.Print("IPStep not found in %s\n" % group, 'ERR')
                continue
            incrTuple += (groupProperties['IPStep'],)
            clientData += (incrTuple,)
            security = self.Security_None
            #securityData should have been populated earlier if
            #security was configured and if it was a Wireless client
            if securityData != {}:
                if 'security' in securityData.keys():
                    security = securityData['security']
            clientData += (security,)
            clientOptions = OrderedDict()
            patt = re.compile(r'BK.+')
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes:
                wmeFlag = True #On by default
                
                if 'AssocProbe' in groupProperties.keys():
                    probeVal = str(groupProperties['AssocProbe'])
                    if probeVal == 'Broadcast':
                        clientOptions['ProbeBeforeAssoc'] = "bdcast"
                    elif probeVal == 'None':
                        clientOptions['ProbeBeforeAssoc'] = "off"
                    else:
                        clientOptions['ProbeBeforeAssoc'] = "unicast"                 
                
                if 'QoSFlag' in groupProperties.keys():
                    if (self.backgroundUserPriority == None and patt.match(group)) or \
                       (self.voiceUserPriority == None and not patt.match(group)):
                        wmeFlag = False
                    elif self.testParameters['Background Traffic Direction'] == 'Unidirectional' and \
                         patt.match(group):
                        # Handle special case here, where bk traffic is unidirectional (Eth->Wifi)
                        # and the bk WLAN QoS setting is enabled. In this case, we shouldn't be 
                        # setting WmeEnabled on.
                        for i in self.FlowMappings.keys():  
                            if self.FlowMappings[i]['SrcCG'] == group:
                                wmeFlag = True   
                                break 
                            wmeFlag = False
    
                if wmeFlag == True:
                    clientOptions['WmeEnabled'] = 'on'
                else:
                    clientOptions['WmeEnabled'] = 'off'
                
                if 'MgmtPhyRate' in groupProperties.keys():
                    clientOptions['PhyRate'] = groupProperties['MgmtPhyRate']
                
                if 'TxPower' in groupProperties.keys():
                    clientOptions['TxPower'] = groupProperties['TxPower']
                
                if 'CtsToSelf' in groupProperties.keys():
                    clientOptions['CtsToSelf'] = groupProperties['CtsToSelf']
                    
                gratArp = 'off'
                if 'GratuitousArp' in groupProperties.keys():
                    if groupProperties['GratuitousArp'] == 'True':
                        gratArp = 'on'
                clientOptions['GratuitousArp'] = gratArp
            if WE.GetCachePortInfo(port) == '8023':
                if 'VlanEnable' in groupProperties.keys():
                    if groupProperties['VlanEnable'] == 'True':
                        clientOptions['VlanTag'] = \
                        (groupProperties['VlanUserPriority'] & 0x7 )* 2**13 + \
                        (groupProperties['VlanCfi'] & 0x1 ) * 2**12 + \
                        (groupProperties['VlanId'] & 0xfff )
            # if bk traffic type is TCP, needs to add enableNetworkInterface to
            # the client options
            if self.backgroundType == 'TCP' and self.backgroundFrameRate > 0 and patt.match(group):
                clientOptions['enableNetworkInterface'] = True
            
            if groupProperties['Interface'] in WE.WiFiInterfaceTypes:
                interfaceOptions = self.clientgroupObjs[group].interfaceOptions
                clientOptions.update(interfaceOptions)   
             
            clientData += (clientOptions,)
            clientDataList = []
            clientDataList.append(clientData)
            clientsPerCG[group] = clientDataList
        return clientsPerCG
    
    def doPortScan(self, clientTuples):
        portsToScan = []
        for group in clientTuples.keys():
            tuples = clientTuples[group]
            for tupleData in tuples:
                portList = tupleData[1]
                if isinstance(portList, list):
                    for port in portList:
                        if port not in portsToScan:
                            portsToScan.append(port)
                elif isinstance(portList, str):
                    if portList not in portsToScan:
                        portsToScan.append(portList)
        for portName in portsToScan:
            if WE.GetCachePortInfo(portName) in WE.WiFiPortTypes:
                WE.VCLtest("port.scanBssid('%s')" % (portName))
                time.sleep(self.BSSIDscanTime)

    def VerifyBSSID_MAC(self, clients):
        # set random seed for psuedo-random MAC addresses that are repeatable.
        if not WE.GroupVerifyBSSID_MAC([clients], self.BSSIDscanTime):
            self.SavePCAPfile = True
            raise WE.RaiseException
        
    def delFlowOptions(self, flowOptions):
        #some of the config items are not used directly in client creation.
        #delete them.
        if 'flowType' in flowOptions.keys():
            del flowOptions['flowType']
        if 'TosField' in flowOptions.keys():
            del flowOptions['TosField']
        if 'Protocol' in flowOptions.keys():
            del flowOptions['Protocol']
        if 'UserPriority' in flowOptions.keys():
            del flowOptions['UserPriority']
        if 'bidirection' in flowOptions.keys():
            del flowOptions['bidirection']
        if 'TosVal' in flowOptions.keys():
            del flowOptions['TosVal']
        if 'dscpMode' in flowOptions.keys():
            del flowOptions['dscpMode']
        if "VOIP" in flowOptions['Type']: #srcPort, destPort options are not supported  
            del flowOptions['srcPort']    #for VoIP flows through VCL, so delete them,
            del flowOptions['destPort']   #this doesn't mean those ports can't be set, 
                                          #see 'Fix-VoipPorts' on how these ports are set
    def getFlowOptions(self, flowName, flowConfigs):
        if flowName not in flowConfigs.keys():
            self.Print("%s not found in FlowConfigs\n" % flowName, 'ERR')
            return -1
        flowDetails = flowConfigs[flowName]
        flowOptions = OrderedDict()
        flowOptions = flowDetails.copy()
        return flowOptions
       
    def configureFlows(self, clientGroups, mapsList, createdClients):
        def _generateFlowList(srcList, dstList, flowOptions, bgFlowF, 
                bidirection):
            generatedFlows = OrderedDict()
            srcCGFlows = []
            dstCGFlows = []
            srcIndx = 0
            srcLen = len(srcList)
            srcCGs = srcList.keys()
            dstCGs = dstList.keys()
            bidirectionF = True
            if bgFlowF == True:
                if bidirection == False:
                    bidirectionF = False
            for dst in dstCGs:
                #W.E seems to be deleting certain key/value pairs from
                #flowOptions. so creating a tmp dictionary to pass to W.E
                tmpFlowOptions = flowOptions.copy()
                dstFlow = dict([(dst, dstList[dst])])
                srcFlow = dict([(srcCGs[srcIndx], srcList[srcCGs[srcIndx]])])
                flow = WE.CreateFlows_Pairs(srcFlow, dstFlow, 
                        bidirectionF, tmpFlowOptions)
                for flowNames in flow.keys():
                    self.FlowList[flowNames] = flow[flowNames]
                    
                    if flow[flowNames][1] in srcCGs:
                        srcCGFlows.append(flowNames)
                    elif flow[flowNames][1] in dstCGs:
                        dstCGFlows.append(flowNames)
                generatedFlows.update(flow)
                srcIndx += 1
                if srcIndx == srcLen:
                    srcIndx = 0
            return generatedFlows, srcCGFlows, dstCGFlows
        
        totalFlows = OrderedDict()
        bgFlows    = OrderedDict()
        mapNames = mapsList.keys()
        for maps in mapNames:
            bgFlowF = False
            flowData = mapsList[maps]
            if 'SrcCG' not in flowData.keys():
                self.Print("SrcCG not found in %s\n" % maps, 'ERR')
                continue
            srcCG = flowData['SrcCG']
            if 'DstCG' not in flowData.keys():
                self.Print("DstCG not found in %s\n" % maps, 'ERR')
                continue
            dstCG = flowData['DstCG']
            if 'FlowName' not in flowData.keys():
                self.Print("Flow not found in %s\n" % maps, 'ERR')
                continue
            flowName = flowData['FlowName']
            flowOptions = self.getFlowOptions(flowName, self.FlowConfigs)
            if flowOptions == -1:
                self.Print("Bad flow configs for %s\n" % flowName, 'ERR')
                continue
            flowDetails = self.FlowConfigs[flowName]
            bidirection = True 
            if 'flowType' in flowDetails.keys():
                if flowDetails['flowType'] == 'BKFlow':
                    bgFlowF = True
            if 'bidirection' in flowDetails.keys():
                if flowDetails['bidirection'] == False:
                    bidirection = False
            if srcCG not in createdClients.keys():
                self.Print("%s not in createdClients' list\n" % srcCG, 'ERR')
                continue
            if dstCG not in createdClients.keys():
                self.Print("%s not in createdClients' list\n" % dstCG, 'ERR')
                continue
            srcList = createdClients[srcCG]
            dstList = createdClients[dstCG]
            srcLen = len(srcList)
            dstLen = len(dstList)
            if srcLen == 0 or dstLen == 0:
                self.Print("Not enough created Clients between %s and %s\n" %
                        (srcCG, dstCG))
                continue
            tmpFlowOptions = flowOptions.copy()
            voipPorts = {'SrcPort':flowOptions['srcPort'], 
                         'DestPort': flowOptions['destPort']}
            tosVal = flowOptions['TosVal']
            dscpMode = flowOptions['dscpMode']
            self.delFlowOptions(tmpFlowOptions)
            (generatedFlow, srcCGFlows, dstCGFlows) = _generateFlowList(
                    srcList, dstList, tmpFlowOptions, bgFlowF, bidirection)
            del tmpFlowOptions
            #FIXME: removed this line below when we have a fix in VCL for various header lengths
            WE.ModifyFlows(generatedFlow, {'Type': flowOptions['Type']})
            self.configureQoS(generatedFlow, srcCGFlows, srcCG, flowOptions)
            self.configureQoS(generatedFlow, dstCGFlows, dstCG, flowOptions)
            self.configureVoipPorts(srcCGFlows, dstCGFlows, voipPorts)
            self.configureToS(generatedFlow, dscpMode, tosVal)
            totalFlows.update(generatedFlow)
            if bgFlowF == True:
                bgFlows.update(generatedFlow)
        return (totalFlows, bgFlows)
    
    def configWLANPriority(self, flowName, priority, flowType='flow'):
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        WE.VCLtest("wlanQos.readFlow()")
        WE.VCLtest("wlanQos.setTgaPriority(%d)" % (priority))
        WE.VCLtest("wlanQos.setUserPriority(%d)" % (priority))
        WE.VCLtest("wlanQos.modifyFlow()")
        WE.VCLtest("%s.write('%s')" % (flowType, flowName))

    def configETHPriority(self, flowName, priority, flowType='flow'):
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        WE.VCLtest("enetQos.readFlow()")
        WE.VCLtest("enetQos.setPriorityTag('%s')" % ("on"))
        WE.VCLtest("enetQos.setTgaPriority(%d)" % (priority))
        WE.VCLtest("enetQos.setUserPriority(%d)" % (priority))
        WE.VCLtest("enetQos.modifyFlow()")
        WE.VCLtest("%s.write('%s')" % (flowType, flowName))

    def configureQoS(self, flows, CGFlows, CG, flowOptions):
        flowType = 'flow'
        if "TCP" in flowOptions['Type']:
            flowType = 'biflow'
        protocol = "Auto"
        if 'Protocol' in flowOptions.keys():
            protocol = flowOptions['Protocol']
        for flowName in CGFlows:
            WE.VCLtest("%s.read('%s')" % (flowType, flowName))
            WE.VCLtest("ipv4.readFlow()")
            if protocol != "Auto":
                WE.VCLtest("ipv4.setProtocol(%s)" % protocol)
            WE.VCLtest("ipv4.modifyFlow()")
            WE.VCLtest("%s.write('%s')" % (flowType, flowName))
        qosFlag = False
        if CG not in self.ClientGroups.keys():
            return
        CGDetails = self.ClientGroups[CG]
        if 'QoSFlag' not in CGDetails.keys():
            return
        qosFlag = CGDetails['QoSFlag']
        if qosFlag != True:
            return
        priority = None    #QoS is not enabled
        if 'UserPriority' in flowOptions.keys():
            priority = flowOptions['UserPriority']
        for flowName in CGFlows:
            if flowName not in flows.keys():
                continue
            flowDetails = flows[flowName]
            if len(flowDetails) <= 0:
                continue
            srcPort = flowDetails[0]
            if (WE.GetCachePortInfo(srcPort) in WE.WiFiPortTypes) and priority != None:
                self.configWLANPriority(flowName, priority, flowType)
            if WE.GetCachePortInfo(srcPort) == '8023' and \
            CGDetails['VlanEnable'] == 'True':
                self.configETHPriority(flowName, priority, flowType)
    
    def configureToS(self, flows, dscpMode, tosVal, flowType='flow'):
        if dscpMode == 'on':
            Field = 'Dscp'
        elif dscpMode == 'off':
            Field = "TosField"
        else:
            return
        for flowName in flows:
            WE.VCLtest("%s.read('%s')" % (flowType, flowName))
            WE.VCLtest("ipv4.readFlow()")   
            WE.VCLtest("ipv4.setDscpMode('%s')" % dscpMode)
            WE.VCLtest("ipv4.set%s(%d)" % (Field, tosVal))                  
            WE.VCLtest("ipv4.modifyFlow()") 
            WE.VCLtest("%s.write('%s')" % (flowType, flowName))
            
    def configureVoipPorts(self, srcCGFlows, dstCGFlows, voipPorts):
        setVoipPorts(srcCGFlows, dstCGFlows, voipPorts)

    def doArpExchanges(self, groupName, flowList):
        if len(flowList) > 0:
            if WE.ExchangeARP(flowList, groupName,
                    self.ARPRate, self.ARPRetries,
                    self.ARPTimeout) < 0.0:
                raise WE.RaiseException

    def initReport(self):
        self.MyReport = WaveReport(os.path.join(self.LoggingDirectory, self.ReportFilename))
        if self.MyReport.Story == None:
            return
        self.MyReport.Title("Service Assurance Report", self.DUTinfo)
         
    
    def modifyFlowRate(self, flowName, rate, flowType='flow'):
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        WE.VCLtest("%s.setIntendedRate(%d)" % (flowType, rate))
        # Calculate the number of frames to transmit
        # Assumption: we only have 1 unidirectional BK traffic flow
        numFrames = rate * self.TransmitTime
        WE.VCLtest("%s.setNumFrames(%d)" % (flowType, numFrames))
        WE.VCLtest("%s.write('%s')" % (flowType, flowName))

    def modifyVoiceFlowNumFrames(self):
        for flowName in self.voiceFlows.keys():
            WE.VCLtest("flow.read('%s')" % (flowName))
            WE.VCLtest("flow.setNumFrames(%d)" % (self.voiceNumFrames))
            WE.VCLtest("flow.write('%s')" % (flowName))  

    def changeBKRate(self, rate):
        flowType = 'flow'
        if self.backgroundType == 'TCP':
            flowType = 'biflow'
        flowNames = self.bgFlows.keys()
        rate = rate/float(len(flowNames))
        if rate < 1:
            rate = 1
        for flowName in self.bgFlows.keys():
            self.modifyFlowRate(flowName, rate, flowType)

    def averageStats(self, trialResults):
        latencySum = 0.0
        pktLossSum = 0.0
        jitterSum  = 0.0
        rvalueSum  = 0.0
        flowNames = trialResults.keys()
        numFlows = 0.0
        for flowName in flowNames:
            if flowName in self.bgFlows.keys():
                continue
            numFlows += 1
            latency = trialResults[flowName][0]
            if latency >= 0:
                latencySum += latency
            ploss = trialResults[flowName][1]
            if ploss >= 0:
                pktLossSum += ploss
            jitter = trialResults[flowName][2]
            if jitter >= 0:
                jitterSum  += jitter
            rvalue = trialResults[flowName][3]
            if rvalue >= 0:
                rvalueSum  += rvalue
        return (latencySum/float(numFlows), 
                pktLossSum/float(numFlows),
                jitterSum/float(numFlows),
                rvalueSum/float(numFlows))

    def bkStats(self, trialResults):
        latency = 0
        ploss = 0
        jitter = 0
        flowNames = trialResults.keys()
        for flowName in flowNames:
            if flowName in self.bgFlows.keys():  
                latency = trialResults[flowName][0]      
                ploss = trialResults[flowName][1]
                jitter = trialResults[flowName][2]
        return(latency, ploss, jitter)

    def measureLatencyRvalueJitter(self, flowName, portName, duration):
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        WE.VCLtest("flowStats.read('%s','%s')" % (portName, flowName))
        if flowStats.getRxFlowLatencyCountOverall() != 0:
            avgLatency = (WE.VCLtest('flowStats.getRxFlowSumLatencyOverall()')/
                          WE.VCLtest('flowStats.getRxFlowLatencyCountOverall()'))
            avgLatency = avgLatency / 1000000.0
        else:
            avgLatency = 0    

        if flowName not in self.bgFlows.keys():    #Do not caculate R-Value for background traffic
            rvalue =  flowStats.calcCumulativeRValue(flowName, duration, 0, 0)
            if rvalue < 0:
                rvalue = 0
        else:
            rvalue = -1017     #Indicating the traffic is non-VoIP. 
                                   
        jitter = WE.VCLtest('flowStats.getRxFlowSmoothedInterarrivalJitter()')
        jitter = jitter / 1000000.0
    
        return (avgLatency, rvalue, jitter)
            
    def collectStats(self, intendedRate, trialResults):
        totalBkTxRate = 0
        totalBkRxRate = 0
        totalVoTxRate = 0
        totaVoRxRate = 0
        for flowName in self.allFlows.keys():
            tmpDict = dict()
            tmpDict[flowName] = self.allFlows[flowName]
            (oload, oloadbps, frate, fratebps, ploss) = \
                    WE.MeasureFlow_OLOAD_FR_LossRate(tmpDict, 
                            self.TransmitTime)            
            if flowName in self.bgFlows.keys():
                totalBkTxRate += oload
                totalBkRxRate += frate
            else:
                totalVoTxRate += oload
                totaVoRxRate += frate
            (avgLatency, rvalue, jitter) = self.measureLatencyRvalueJitter(flowName, \
                                                    self.allFlows[flowName][2],self.TransmitTime)
            trialResults[flowName] = (avgLatency, ploss, jitter, rvalue)
            self.Print("Flow - %s : Latency - %0.1f, Pkt Loss - %0.1f, Jitter - %0.1f, " 
                    % (flowName, avgLatency, ploss, jitter))
            if rvalue != -1017:    
                self.Print("R Value - %0.1f\n" % (rvalue))
            else:
                self.Print("R Value - %s\n" % "N/A")
                rvalue = "N/A"
            WE.WriteDetailedLog(['FlowName', 'Latency', '% Pkt Loss', 
                    'Jitter', 'R Value'])
            WE.WriteDetailedLog([flowName, avgLatency, ploss, jitter,
                    rvalue])
        (latencyAvg, pktLossAvg, jitterAvg, rvalueAvg) = self.averageStats(
                trialResults)
        (latencyBk, pktLossBk, jitterBk) = self.bkStats(trialResults)
        #Get the Min, Max values- This is not efficient way of doing, have to change
        #the code to have one call rather than four calls. Opting this method for
        #the time being for on time production of results 
        (latencyMin, pktLossMin, jitterMin, rvalueMin) = (self.getMinVal(trialResults,0), \
                                                          self.getMinVal(trialResults,1), \
                                                          self.getMinVal(trialResults,2),\
                                                          self.getMinVal(trialResults,3))
        (latencyMax, pktLossMax, jitterMax, rvalueMax) = (self.getMaxVal(trialResults,0), \
                                                          self.getMaxVal(trialResults,1), \
                                                          self.getMaxVal(trialResults,2),\
                                                          self.getMaxVal(trialResults,3))
        finalStats = odict.OrderedDict()
        finalStats['flowRates'] = (intendedRate, totalBkTxRate, totalBkRxRate,totalVoTxRate, totaVoRxRate)
        finalStats['finalAvgResults'] = (latencyAvg, pktLossAvg, jitterAvg,
                rvalueAvg)
        finalStats['finalMinResults'] = (latencyMin, pktLossMin, jitterMin,
                rvalueMin)
        finalStats['finalMaxResults'] = (latencyMax, pktLossMax, jitterMax,
                rvalueMax)
        finalStats['finalBkResults'] = (latencyBk, pktLossBk, jitterBk)
        return finalStats
    
    def getMinVal(self, trialResults, valIndx):
        minValue = 1000000  #arbitrary Value
        for flowName in trialResults.keys():
            if flowName not in self.bgFlows.keys():
                value = trialResults[flowName][valIndx]
                if value >= 0 and value < minValue:
                    minValue = value
        if minValue == 1000000:
            return -1 #TODO - catch and process this return value
        return minValue

    def getMaxVal(self, trialResults, valIndx):
        maxValue = 0  #arbitrary Value
        for flowName in trialResults.keys():
            if flowName not in self.bgFlows.keys():
                value = trialResults[flowName][valIndx]
                if value >= 0 and value > maxValue:
                    maxValue = value
        return maxValue

    def getPercent(self, val, percent):
        return val * percent / 100.0

    def getRValueResult(self, trialResults):
        result = 0
        measuredRValue = self.getMinVal(trialResults, 3)
        if measuredRValue == -1:
            return -1
        Rdelta = self.getPercent(self.Rvalue, self.RvalueResolution)
        self.Print("measured Min R Value - %0.1f\n"% (measuredRValue))
        if measuredRValue >= self.Rvalue + Rdelta:
            result = 1
        elif measuredRValue < self.Rvalue - Rdelta:
            result = -1
        return result
    
    def getSingleResult(self, trialResults, indx, val, resolution):
        result = 0
        measuredVal = self.getMaxVal(trialResults, indx)
        delta = self.getPercent(val, resolution)
        if measuredVal > val + delta:
            result = -1
        if measuredVal <= val - delta:
            result = 1
        return result

    def getLinearSingleResult(self, trialResults, indx, val, resolution):
        result = 0
        measuredVal = self.getMaxVal(trialResults, indx)
        delta = self.getPercent(val, resolution)
        if measuredVal > val + delta:
            result = 1
        return result

    def getSecondaryMetricResult(self, trialResults):
        result = 0
        if self.latencyValueF == True:
            latencyResult = self.getSingleResult(trialResults, 0, 
                    self.latencyValue, self.latencyResolution)
        if self.pktLossValueF == True:
            pktLossResult = self.getSingleResult(trialResults, 1,
                    self.pktLossValue, self.pktLossResolution)
        if self.jitterValueF == True:
            jitterResult = self.getSingleResult(trialResults, 2,
                    self.jitterValue, self.jitterResolution)
        if self.latencyValueF and self.pktLossValueF and self.jitterValueF:
            result = min(latencyResult, pktLossResult, jitterResult)
        elif self.latencyValueF and self.pktLossValueF:
            result = min(latencyResult, pktLossResult)
        elif self.latencyValueF and self.jitterValueF:
            result = min(latencyResult, jitterResult)
        elif self.pktLossValueF and self.jitterValueF:
            result = min(pktLossResult, jitterResult)
        elif self.pktLossValueF:
            result = pktLossResult
        elif self.latencyValueF:
            result = latencyResult
        elif self.jitterValueF:
            result = jitterResult
        return result

    def checkStats(self, trialResults):
        if self.RvalueF == True:
            result = self.getRValueResult(trialResults)
        else:
            result = self.getSecondaryMetricResult(trialResults)
        return result

    def getLinearSecondaryMetricResult(self, trialResults):
        result = 0
        if self.latencyValueF == True:
            latencyResult = self.getLinearSingleResult(trialResults, 0, 
                    self.latencyValue, self.latencyResolution)
        if self.pktLossValueF == True:
            pktLossResult = self.getLinearSingleResult(trialResults, 1,
                    self.pktLossValue, self.pktLossResolution)
        if self.jitterValueF == True:
            jitterResult = self.getLinearSingleResult(trialResults, 2,
                    self.jitterValue, self.jitterResolution)
        if self.latencyValueF and self.pktLossValueF and self.jitterValueF:
            result = max(latencyResult, pktLossResult, jitterResult)
        elif self.latencyValueF and self.pktLossValueF:
            result = max(latencyResult, pktLossResult)
        elif self.latencyValueF and self.jitterValueF:
            result = max(latencyResult, jitterResult)
        elif self.pktLossValueF and self.jitterValueF:
            result = max(pktLossResult, jitterResult)
        elif self.pktLossValueF:
            result = pktLossResult
        elif self.latencyValueF:
            result = latencyResult
        elif self.jitterValueF:
            result = jitterResult
        return result
    
    def getLinearRValueResult(self, trialResults):
        result = 0
        measuredRValue = self.getMinVal(trialResults, 3)
        if measuredRValue == -1:
            return -1
        Rdelta = self.getPercent(self.Rvalue, self.RvalueResolution)
        self.Print("measured Min R Value - %0.1f\n" % (measuredRValue))
        if measuredRValue < self.Rvalue - Rdelta:
            result = 1
        return result

    def checkLinearStats(self, trialResults):
        if self.RvalueF == True:
            result = self.getLinearRValueResult(trialResults)
        else:
            result = self.getLinearSecondaryMetricResult(trialResults)
        return result
    
    def startTraffic(self):
        if len(self.bgFlows) > 0:
            self._startFlowGroup("bkGroup")

        if len(self.voiceFlows) > 0:
            self._startFlowGroup("voiceGroup")
            
    def stopTraffic(self):
        if len(self.bgFlows) > 0:
            WE.VCLtest("action.stopFlowGroup('%s')" % 
                    "bkGroup")
        if len(self.voiceFlows) > 0:
            WE.VCLtest("action.stopFlowGroup('%s')" % 
                    "voiceGroup")

    def reportStats(self):
        #FIX ME- Despite being one monolithic statement group, this method mixes the 
        #tasks of writing to the results into self.ResultsForCSVfile for the CSV file 
        #and populating self.MyReport for the pdf report. It's logical to
        #split those tasks, particularly now that we have an option to switch off pdf
        #report generation. Split reportStats() and  self.MyReport population
        self.MyReport.InsertHeader("Overview")
        self.MyReport.InsertParagraph("The test determines the maximum amount \
        of low priority traffic that the System Under Test (SUT) can sustain without \
        breaking the Service Level Agreement (SLA) for a specified number of VoIP calls. \
        The Service Level Agreement can be specified as a minimum \
        R-value or a combination of maximum Packet Loss, Latency and Jitter of the VoIP calls.")
        numTrials = self.testResults.keys()
        trialMinLatency = []
        trialAvgLatency = []
        trialMaxLatency = []
        trialMinPktloss   = []
        trialAvgPktloss   = []
        trialMaxPktloss   = []
        trialMinJitter  = []
        trialAvgJitter  = []
        trialMaxJitter  = []
        trialMinRValue  = []
        trialAvgRValue  = []
        trialMaxRValue  = []
        trialBkTxRate = []
        trialBkRxRate = []
        trialVoTxRate = []
        triaVoRxRate = []
        trialIntended= []
        trialBkLatency = []
        trialBkPktLoss = []
        trialBkJitter = []
        finalRxValues  = []
        finalIntendedRxTxvalues = [("Trial Num", "Intended Load", "Tx Offered Load", \
                                   "Rx Received Load")]
        for trialNum in numTrials:
            latencyMinList = []
            latencyAvgList = []
            latencyMaxList = []
            pktLossMinList = []
            pktLossAvgList = []
            pktLossMaxList = []
            jitterMinList  = []
            jitterAvgList  = []
            jitterMaxList  = []
            rValueMinList  = []
            rValueAvgList  = []
            rValueMaxList  = []
            bkTxRateList = []
            bkRxRateList = []
            voTxRateList = []
            voTxRateList = []
            intendedRateList = []
            latencyBkList = []
            pktLossBkList = []
            jitterBkList = []
            trialStats = self.testResults[trialNum]
            for trialStat in trialStats:
                flowRates = trialStat['flowRates']
                finalMinResults = trialStat['finalMinResults']
                finalAvgResults = trialStat['finalAvgResults']
                finalMaxResults = trialStat['finalMaxResults']
                finalBkResults = trialStat['finalBkResults']
                (intendedRate, bkTxRate, bkRxRate, voTxRate, voRxRate) = flowRates
                (latencyMin, pktLossMin, jitterMin, rvalueMin) = finalMinResults
                (latencyAvg, pktLossAvg, jitterAvg, rvalueAvg) = finalAvgResults
                (latencyMax, pktLossMax, jitterMax, rvalueMax) = finalMaxResults
                (latencyBk, pktLossBk, jitterBk) = finalBkResults
                latencyMinList.append(latencyMin)
                latencyAvgList.append(latencyAvg)
                latencyMaxList.append(latencyMax)
                pktLossMinList.append(pktLossMin)
                pktLossAvgList.append(pktLossAvg)
                pktLossMaxList.append(pktLossMax)
                jitterMinList.append(jitterMin)
                jitterAvgList.append(jitterAvg)
                jitterMaxList.append(jitterMax)
                rValueMinList.append(rvalueMin)
                rValueAvgList.append(rvalueAvg)
                rValueMaxList.append(rvalueMax)
                bkTxRateList.append(bkTxRate)
                bkRxRateList.append(bkRxRate)
                voTxRateList.append(voTxRate)
                voTxRateList.append(voRxRate)
                intendedRateList.append(intendedRate)
                latencyBkList.append(latencyBk)
                pktLossBkList.append(pktLossBk)
                jitterBkList.append(jitterBk)                
            finalRxValues.append(bkRxRate)
            finalIntendedRxTxvalues.append(((int(trialNum)+1), self.resultSummaryData[int(trialNum)][4], \
                                            self.resultSummaryData[int(trialNum)][2], \
                                            self.resultSummaryData[int(trialNum)][3]))
            trialMinLatency.append(latencyMinList)
            trialAvgLatency.append(latencyAvgList)
            trialMaxLatency.append(latencyMaxList)
            trialMinPktloss.append(pktLossMinList)
            trialAvgPktloss.append(pktLossAvgList)
            trialMaxPktloss.append(pktLossMaxList)
            trialMinJitter.append(jitterMinList)
            trialAvgJitter.append(jitterAvgList)
            trialMaxJitter.append(jitterMaxList)
            trialMinRValue.append(rValueMinList)
            trialAvgRValue.append(rValueAvgList)
            trialMaxRValue.append(rValueMaxList)
            trialBkTxRate.append(bkTxRateList)
            trialBkRxRate.append(bkRxRateList)
            trialVoTxRate.append(voTxRateList)
            triaVoRxRate.append(voTxRateList)
            trialIntended.append(intendedRateList)
            trialBkLatency.append(latencyBkList)
            trialBkPktLoss.append(pktLossBkList)
            trialBkJitter.append(jitterBkList)                        
		#Text strings
        testMethodology1 = "The test creates the specified client pairs for VoIP calls and one client pair for background (BK) traffic. Bidirectional VoIP flows are established between the clients on one port and the corresponding clients on another port. VoIP flows must meet the specified service level agreement (SLA). Background flows are created between the corresponding clients." 
        testMethodology2 = "The background traffic varies according to the specified search criteria until the maximum traffic load is identified that still permits the SUT to maintain the VoIP call SLA."
        testTopology = "The following diagram shows the test topology. Each box indicates the port identifiers and IP addresses for the test clients; for wireless clients the security mode and channel ID is also shown. The arrows show the direction of the traffic."

        self.MyReport.InsertHeader("Results Summary")
        if self.RvalueF == True:
            slaSpecified = "R-value:%0.1f" % self.Rvalue
        else:
            slaSpecified = "maximum latency:%0.1fms, packet loss:%0.1f%% and jitter:%0.1fms" \
            % (self.latencyValue, self.pktLossValue, self.jitterValue)
        
        #'adjustedTrailNum' Used for displaying in graph, we want the trial 
        #numbers to start from 1 rather than 0 used in indexing
        adjustedTrailNums = [str((int(val)+1)) for val in numTrials] 
        
        if len(numTrials) > 1:   
            trialList = []
            neverBrokeSLAStr = ""
            trialNeverPassedStr = ""
            bkTrafficRxList = []  
            printGraph = False
            numTrials = [int(val) for val in numTrials]          
            for num in numTrials:
                trialList.append(str(num+1))
                # neverBrokeSLA is a boolean that indicates whether or not the
                # test has broken the SLA
                # trialNeverPassed is a boolen that indicates if every trial in
                # the test broke the SLA 
                (neverBrokeSLA, trialNeverPassed, bkTrafficTx, bkTrafficRx, intendedRate) = self.resultSummaryData[num]
                if neverBrokeSLA == True:
                    neverBrokeSLAStr = neverBrokeSLAStr + str(num+1) + ", "
                if trialNeverPassed == True:
                    trialNeverPassedStr = trialNeverPassedStr + str(num+1) + ", "  
                    bkTrafficRx = 0    
                else:
                    printGraph = True        
                bkTrafficRxList.append(bkTrafficRx)   
            if printGraph == True:  
                self.MyReport.InsertParagraph("The following graph shows the maximum forwarding rate of the background traffic \
                    that can be supported by the SUT without breaking the specified SLA (%s) for each trial." % (slaSpecified)) 
                graph1 = Qlib.GenericGraph (adjustedTrailNums, "Trial Num", list((bkTrafficRxList,)) \
                        , "Background Traffic Rate(pps) - Rx", "Background Traffic Rate", ['Bar'])
                self.MyReport.InsertObject(graph1)
                self.finalGraphs["Background Traffic Rate"] = graph1
            if neverBrokeSLAStr != "":
                neverBrokeSLAStr = neverBrokeSLAStr[:-2]
                self.MyReport.InsertParagraph("Trial number %s: This is not necessarily the maximum forwarding rate of the background traffic as the"\
                    " test stopped because it reached the maximum offered load configured by the user." % neverBrokeSLAStr)                 
            if trialNeverPassedStr != "": 
                trialNeverPassedStr = trialNeverPassedStr[:-2]
                if self.binarySearchFlag == False:
                    self.MyReport.InsertParagraph("Trial number %s: The SLA specified by the user (%s) was broken with \
                        the minimum forwarding rate configured by the user. Try testing by reducing \
                        the minimum forwarding rate." % (trialNeverPassedStr, slaSpecified))  
                else:               
                    self.MyReport.InsertParagraph("Trial number %s: The test stopped because the search resolution was met. \
                        However, the test failed because it did not meet the SLA requirement (%s)." % (trialNeverPassedStr, slaSpecified))                                                                                                           
            if printGraph == True:
                self.MyReport.InsertParagraph("The following table shows the intended and offered background traffic load for each trial.") 
                self.MyReport.InsertDetailedTable(finalIntendedRxTxvalues, columns=[0.5*inch, 0.9*inch, 0.9*inch, 0.9*inch])
        else:    
            (neverBrokeSLA, trialNeverPassed, bkTrafficTx, bkTrafficRx, intendedRate) = self.resultSummaryData[0]  
            if trialNeverPassed == False:
                self.MyReport.InsertParagraph("The following graph shows the maximum forwarding rate of the background traffic that can be supported by the SUT at a given SLA (%s)" % (slaSpecified))                
                graph1 = Qlib.GenericGraph (adjustedTrailNums, "Trial Num", list(([bkTrafficRx],)) \
                        , "Background Traffic Rate(pps) - Rx", "Background Traffic Rate", ['Bar'])
                self.MyReport.InsertObject(graph1)
                self.finalGraphs["Background Traffic Rate"] = graph1
            else:
                if self.binarySearchFlag == False:
                    self.MyReport.InsertParagraph("The SLA specified by the user (%s) was broken with \
                        the minimum forwarding rate configured by the user. Try testing by reducing \
                        the minimum forwarding rate." % slaSpecified)  
                else:               
                    self.MyReport.InsertParagraph("The test stopped because the search resolution was met. \
                        However, the test failed because it did not meet the SLA requirement (%s)." % slaSpecified)                                                                                                                                              
            if neverBrokeSLA == True:
                self.MyReport.InsertParagraph("Note: This is not necessarily the maximum forwarding rate of the background traffic as the"\
                    " test stopped because it reached the maximum offered load configured by the user." )                        
            if trialNeverPassed == False:   
                self.MyReport.InsertParagraph("The following table shows the intended and offered background traffic load.") 
                self.MyReport.InsertDetailedTable(finalIntendedRxTxvalues, columns=[0.5*inch, 0.9*inch, 0.9*inch, 0.9*inch])

        self.MyReport.InsertHeader( "Methodology" )
        self.MyReport.InsertParagraph(testMethodology1)
        self.MyReport.InsertParagraph(testMethodology2)
        
        self.MyReport.InsertHeader( "Topology" )
        self.MyReport.InsertParagraph(testTopology)
        self.MyReport.InsertClientMap( self.SourceClients, self.DestClients, True, self.CardMap )
        
        self.MyReport.InsertPageBreak()
                
        if len(numTrials) > 1:
            self.MyReport.InsertParagraph("The following graphs show the measured R-value, latency, jitter, and packet loss for each trial.")
        else:
            self.MyReport.InsertParagraph("The following graphs show the measured R-value, latency, jitter, and packet loss per intended background rate.")
        numTrials = [int(val) for val in numTrials]
        CSVline = ()
        self.ResultsForCSVfile.append( CSVline )

        x_AxisLabel = "Background Traffic Intended Rate (fps) [Frame Size %s bytes]" % (self.bgFrameSize)
        # if trials > 1, draw bar charts instead of line charts
        if len(numTrials) > 1:
            trialList = []
            trialMinVal = []
            trialAvgVal = []
            trialMaxVal = []
            for num in numTrials:
                trialList.append(str(num+1))
            
            # Calculate min, avg & max R-Value
            for num in numTrials:
                trialMinVal.append(trialMinRValue[num][-1])
                trialAvgVal.append(trialAvgRValue[num][-1])
                trialMaxVal.append(trialMaxRValue[num][-1])
            graphRValue = Qlib.GenericGraph( 
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialMinVal,trialAvgVal,trialMaxVal)), # list of y values
                "R-Value",    # y label
                "Min, Avg & Max R-Value per Trial", # graphtitle
                ['Bar'], # graph type
                [["Min"],["Avg"],["Max"]] # list of legend name
            )    

            self.MyReport.InsertObject(graphRValue)
            self.finalGraphs['Min, Avg & Max R-Value per Trial'] =  graphRValue  

            # Calculate min, avg & max Latency
            trialMinVal = []
            trialAvgVal = []
            trialMaxVal = []            
            for num in numTrials:
                trialMinVal.append(trialMinLatency[num][-1])
                trialAvgVal.append(trialAvgLatency[num][-1])
                trialMaxVal.append(trialMaxLatency[num][-1])                  
            graphLatency = Qlib.GenericGraph( 
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialMinVal,trialAvgVal,trialMaxVal)), # list of y values
                "Latency (ms)", # y label
                "Min, Avg & Max Latency per Trial", # graphtitle
                ['Bar'], # graph type
                [["Min"],["Avg"],["Max"]] # list of legend name
            )         
            self.MyReport.InsertObject(graphLatency)
            self.finalGraphs['Min, Avg & Max Latency per Trial'] =  graphLatency         
            
            # Calculate min, avg & max Jitter
            trialMinVal = []
            trialAvgVal = []
            trialMaxVal = []            
            for num in numTrials:
                trialMinVal.append(trialMinJitter[num][-1])
                trialAvgVal.append(trialAvgJitter[num][-1])
                trialMaxVal.append(trialMaxJitter[num][-1])                  
            graphJitter = Qlib.GenericGraph( 
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialMinVal,trialAvgVal,trialMaxVal)), # list of y values
                "Jitter (ms)", # y label
                "Min, Avg & Max Jitter per Trial", # graphtitle
                ['Bar'], # graph type
                [["Min"],["Avg"],["Max"]] # list of legend name
            )         
            self.MyReport.InsertPageBreak()
            self.MyReport.InsertObject(graphJitter)
            self.finalGraphs['Min, Avg & Max Jitter per Trial'] =  graphJitter             

            # Calculate min, avg & max Pktloss
            trialMinVal = []
            trialAvgVal = []
            trialMaxVal = []            
            for num in numTrials:
                trialMinVal.append(trialMinPktloss[num][-1])
                trialAvgVal.append(trialAvgPktloss[num][-1])
                trialMaxVal.append(trialMaxPktloss[num][-1])                  
            graphPktloss = Qlib.GenericGraph( 
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialMinVal,trialAvgVal,trialMaxVal)), # list of y values
                "Packet Loss (%)", # y label
                "Min, Avg & Max Packet Loss per Trial", # graphtitle
                ['Bar'], # graph type
                [["Min"],["Avg"],["Max"]] # list of legend name
            )         
            self.MyReport.InsertObject(graphPktloss)
            self.finalGraphs['Min, Avg & Max Packet Loss per Trial'] =  graphPktloss 

            self.MyReport.InsertParagraph("The following graphs show the background Rx rate and the background latency for each trial.")

            # Calculate Bk rate
            trialFinalBkRate = []
            intendedLoads = []
            for trialNum in numTrials:              
                trialFinalBkRate.append(trialBkRxRate[trialNum][-1])   
            graphBKRate = Qlib.GenericGraph(
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialFinalBkRate,)), 
                "Background Rx Rate(pps)", 
                "Final Background Rx Rate per Trial",
                ['Bar']
            ) 
            self.MyReport.InsertObject(graphBKRate)
            self.finalGraphs["Final Background Rx Rate per Trial"] = graphBKRate

            # Calculate Bk Latency     
            trialBkLat = []            
            for num in numTrials:
                trialBkLat.append(trialBkLatency[num][-1])                                  
            graphBkLatency = Qlib.GenericGraph( 
                trialList,    # x values which is the trial numbers
                "Trials",     # x label
                list((trialBkLat,)), # list of y values
                "Latency (ms)", # y label
                "Background Latency per Trial", # graphtitle
                ['Bar'] # graph type
            )         
            self.MyReport.InsertObject(graphBkLatency)
            self.finalGraphs['Background Latency per Trial'] =  graphBkLatency

        else:
            trialNum = 0

            trialIntended[trialNum] = [str(val) for val in trialIntended[trialNum]]
			
			#Write Graphs for each trial
            graph2 = Qlib.GenericGraph(trialIntended[trialNum],x_AxisLabel,
                   [trialMinRValue[trialNum], trialAvgRValue[trialNum], \
                          trialMaxRValue[trialNum]], "R value", 
                    "Min, Avg & Max R-value per Intended Background Rate", ['Line'], [['Min'], ['Avg'],['Max']])
            self.MyReport.InsertObject(graph2)
            self.finalGraphs["Min, Avg & Max R-value per Intended BK Rate"] = graph2

            graph3 = Qlib.GenericGraph(trialIntended[trialNum], x_AxisLabel,
                    [trialMinLatency[trialNum], trialAvgLatency[trialNum], \
                          trialMaxLatency[trialNum]], "Latency (ms)",
                    "Min, Avg & Max Latency per Intended Background Rate", ['Line'], [['Min'], ['Avg'],['Max']])
            self.MyReport.InsertObject(graph3)
            self.finalGraphs["Min, Avg & Max Latency per Intended BK Rate"] = graph3

            graph4 = Qlib.GenericGraph(trialIntended[trialNum], x_AxisLabel,
                    [trialMinJitter[trialNum], trialAvgJitter[trialNum], \
                          trialMaxJitter[trialNum]], "Jitter (ms)", 
                    "Min, Avg & Max Jitter per Intended Background Rate", ['Line'], [['Min'], ['Avg'],['Max']])
            self.MyReport.InsertObject(graph4)
            self.finalGraphs["Min, Avg & Max Jitter per Intended BK Rate"] = graph4
            
            graph5 = Qlib.GenericGraph(trialIntended[trialNum], x_AxisLabel,
                    [trialMinPktloss[trialNum], trialAvgPktloss[trialNum], \
                          trialMaxPktloss[trialNum]], "Packet Loss %",
                    "Min, Avg & Max Packet Loss per Intended Background Rate", ['Line'], [['Min'], ['Avg'],['Max']])
            self.MyReport.InsertObject(graph5)
            self.finalGraphs["Avg Packet Loss per Intended BK Rate"] = graph5
            
            self.MyReport.InsertParagraph("The following graphs show the background Rx rate and the background latency per intended background rate.")
            
            graph6 = Qlib.GenericGraph(trialIntended[trialNum], x_AxisLabel,
                   	list((trialBkRxRate[trialNum],)), "Background Rx rate(pps)", 
                    "Background Rx Rate per Intended Background Rate", ['Bar']) 
            self.MyReport.InsertObject(graph6)
            self.finalGraphs["Background Rx Rate per Intended BK Rate"] = graph6

            graphBkLatency = Qlib.GenericGraph(trialIntended[trialNum], x_AxisLabel,
                       list((trialBkLatency[trialNum],)), "Latency (ms)", 
                    "Background latency per Intended Background Rate", ['Line']) 
            self.MyReport.InsertObject(graphBkLatency)
            self.finalGraphs["BK Latency per Intended BK Rate"] = graphBkLatency
                    
        for trialNum in numTrials:                
    		#Write data into Results_qos_service.csv
            CSVline = ('Trial - %d' % (int(trialNum)+1),)
            self.ResultsForCSVfile.append( CSVline )
            #Write the column headings
            if self.UserPassFailCriteria['user'] == "True":
                    CSVline = ('Background intended  Load:',
                       'Min R-Value', 'Avg R-Value', 'Max R-Value',
                       'Min Latency', 'Avg Latency', 'Max Latency',
                       'Min Jitter', 'Avg Jitter', 'Max Jitter',
                       'Min Pkt Loss', 'Avg Pkt Loss', 'Max Pkt Loss',
                       'Background Tx Rate', 'Background Rx Rate', 'Background Latency')
            else: 
                    CSVline = ('Background intended  Load:', 
                       'Min R-Value', 'Avg R-Value', 'Max R-Value',
                       'Min Latency', 'Avg Latency', 'Max Latency', 
                       'Min Jitter', 'Avg Jitter', 'Max Jitter',
                       'Min Pkt Loss', 'Avg Pkt Loss', 'Max Pkt Loss',
                       'Background Tx Rate', 'Background Rx Rate', 'Background Latency') 
            self.ResultsForCSVfile.append( CSVline )
            for i in range(0, len(trialIntended[trialNum])):
                CSVline = (trialIntended[trialNum][i],
                           trialMinRValue[trialNum][i],trialAvgRValue[trialNum][i],trialMaxRValue[trialNum][i],
                           trialMinLatency[trialNum][i],trialAvgLatency[trialNum][i],trialMaxLatency[trialNum][i],
                           trialMinJitter[trialNum][i],trialAvgJitter[trialNum][i],trialMaxJitter[trialNum][i],                                             
                           trialMinPktloss[trialNum][i],trialAvgPktloss[trialNum][i],trialMaxPktloss[trialNum][i],
                           trialBkTxRate[trialNum][i],trialBkRxRate[trialNum][i],trialBkLatency[trialNum][i]) 
                self.ResultsForCSVfile.append( CSVline )

        self._insertDetailedResultsTable(
                                         numTrials,
                                         trialIntended,
                                         trialBkRxRate,
                                         triaVoRxRate,
                                         trialMinRValue,
                                         trialMaxLatency,
                                         trialMaxPktloss,
                                         trialMaxJitter,
                                         trialBkLatency
                                         )
        if self.UserPassFailCriteria['user'] == "True":                                 
                self._insertSummaryResultsTable(finalIntendedRxTxvalues,numTrials,
                                         trialIntended,
                                         trialBkRxRate,
                                         triaVoRxRate,
                                         trialMinRValue,
                                         trialMaxLatency,
                                         trialMaxPktloss,
                                         trialMaxJitter,
                                         trialBkLatency
                                         )
  
        self.MyReport.InsertHeader("Configuration") 
        self.MyReport.InsertParagraph("The following table shows the parameters set for the test.")
        resSummary = [('Parameter', 'Value')]
        for key in self.testParameters.keys():
            resultTuple = (key, self.testParameters[key])
            resSummary.append(resultTuple)
        self.MyReport.InsertDetailedTable(resSummary, columns=[3.0*inch, 1.5*inch])
        
        self.insertAPinfoTable(self.RSSIFilename)
        
        self.MyReport.InsertHeader("Other Information") 
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        for item in self.OtherInfoData.items():
            OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        self.MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] )


    def _insertSummaryResultsTable(self,finalIntendedRxTxvalues, numTrials,
                                    trialIntended,
                                    trialBkRxRate,
                                    triaVoRxRate,
                                    trialMinRValue,
                                    trialMaxLatency,
                                    trialMaxPktloss,
                                    trialMaxJitter,
                                    trialBkLatency
):
         
        self.MyReport.InsertHeader("Summary Results")
        self.MyReport.InsertParagraph("The following table shows the Summary results for this test.")
        DetResTableEntries = [] 
        import operator
        for trialNum in numTrials:
            thisTrialTableEntries = []
            for i in range(0, len(trialIntended[trialNum])):
                    thisTrialTableEntries += (
                                           (
                                            (int(trialNum)+1),
                                            float(trialIntended[trialNum][i]),
                                            trialBkRxRate[trialNum][i],
                                            triaVoRxRate[trialNum][i],
                                            trialMinRValue[trialNum][i],
                                            trialMaxLatency[trialNum][i],
                                            trialMaxPktloss[trialNum][i],
                                            trialMaxJitter[trialNum][i],
                                            trialBkLatency[trialNum][i],
                                            ),
                                            )

            #Each trial entries are sorted by the intended load
            #i.e., item indexed 1 in list
            thisTrialTableEntries.sort(key = operator.itemgetter(1))

            DetResTableEntries += thisTrialTableEntries
            detResTable = [('Trial Num',
                        'Intended BK Load (pkts/sec)',
                        'BK Frame Rate (pkts/sec)',
                        'Voice Frame Rate (pkts\sec)',
                        'Min R-Value',
                        'Max Latency (msecs)',
                        'Max Pkt Loss (%)',
                        'Max Jitter (msecs)',
                        'BK Latency (msecs)')]
        detResTable += DetResTableEntries
        summary_tuple=[] 
        summary_tuple=[('Trial Num',
                        'Intended BK Load (pkts/sec)',
                        'BK Frame Rate (pkts/sec)',
                        'Voice Frame Rate (pkts\sec)',
                        'Min R-Value',
                        'Max Latency (msecs)',
                        'Max Pkt Loss (%)',
                        'Max Jitter (msecs)',
                        'BK Latency (msecs)')]

        for each_tup in detResTable:
               for each_tup_sum in finalIntendedRxTxvalues: 
                    if each_tup[2]== each_tup_sum[-1]:
                        summary_tuple=summary_tuple+[each_tup]         
        print "\nThe summary tuple is: \n%s\n" %summary_tuple
        for each_tup in summary_tuple[1:]:
             if float(each_tup[2])  >= float(self.UserPassFailCriteria["ref_min_bk_rate"]):
                       self.TestResult[each_tup[0]] = 'PASS'
                       WaveEngine.OutputstreamHDL("\nTrial-%s: The test has achieved the user specified Pass/Fail Criteria: User-%s, Achieved-%s\n" %(each_tup[0],self.UserPassFailCriteria['ref_min_bk_rate'],float(each_tup[2])),WaveEngine.MSG_SUCCESS)
             else:
                       self.TestResult[each_tup[0]] = 'FAIL'
                       WaveEngine.OutputstreamHDL("\nTrial-%s: The test has Failed to achieve the user specified Pass/Fail Criteria: User-%s, Achieved-%s\n" %(each_tup[0],self.UserPassFailCriteria['ref_min_bk_rate'],float(each_tup[2])),WaveEngine.MSG_WARNING)
        table_results=[]
        table_results=table_results+[summary_tuple[0]+('USC:BKR',)]
        for each in summary_tuple[1:]:
               table_results=table_results+[each+(self.TestResult[each[0]],)]
        self.ResultsforDb=self.ResultsforDb+table_results
        if self.Trials != len (table_results[1:]):
               Warning="""Note:: %s Iterations have achieved the same Background rate, hence a single trial has multiple entries""" %(len (table_results[1:])-self.Trials)
               self.MyReport.InsertParagraph(Warning)
        self.MyReport.InsertDetailedTable(table_results,
                                          columns = [
                                                     0.50*inch,
                                                     0.74*inch,
                                                     0.74*inch,
                                                     0.74*inch,
                                                     0.70*inch,
                                                     0.70*inch,
                                                     0.70*inch,
                                                     0.74*inch,
                                                     0.70*inch,
                                                     0.75*inch
                                                     ]
                                          )
        NoteText=""" Note: Abbreviations used: USC-User Specified Criteria,BKR-Background Rate """
        self.MyReport.InsertParagraph(NoteText)
        iteration_count=-1
        fail_count =0
        fail_perc  =0
        for each_tup in  table_results:
            iteration_count=iteration_count+1
            for each_value in each_tup:
                if each_value == 'FAIL':
                    fail_count=fail_count+1
                    #fail_perc=float(fail_count/iteration_count)* 100

        self.MyReport.InsertHeader( "User Specified P/F criteria" )
        ConfigParameters = [ ( 'Parameter', 'User specified Value', 'Overall Result' ),
                                         ( 'Acceptable BackGround Rate',"%s" %self.UserPassFailCriteria['ref_min_bk_rate'] ,
                              "Total:%s, PASS:%s and FAIL:%s"%(iteration_count,(iteration_count-fail_count),fail_count))]
        if fail_count > 0:
                       self.FinalResult =3
        self.MyReport.InsertParameterTable( ConfigParameters, columns = [ 1.75*inch, 1.25*inch, 1.75*inch ] ) # 4.75-inch total
      
  
    def _insertDetailedResultsTable(self,
                                    numTrials, 
                                    trialIntended,
                                    trialBkRxRate,
                                    triaVoRxRate,
                                    trialMinRValue,
                                    trialMaxLatency,
                                    trialMaxPktloss,
                                    trialMaxJitter,
                                    trialBkLatency
                                    ):
        """
        Write detailed results table
        """
        self.MyReport.InsertHeader("Detailed Results")
        self.MyReport.InsertParagraph("The following table shows the detailed results for this test.")
        DetResTableEntries = []

        import operator
        for trialNum in numTrials:
            thisTrialTableEntries = []
            for i in range(0, len(trialIntended[trialNum])):
                    thisTrialTableEntries += (
                                           (
                                            (int(trialNum)+1),
                                            float(trialIntended[trialNum][i]),
                                            trialBkRxRate[trialNum][i],
                                            triaVoRxRate[trialNum][i],
                                            trialMinRValue[trialNum][i],
                                            trialMaxLatency[trialNum][i],
                                            trialMaxPktloss[trialNum][i],
                                            trialMaxJitter[trialNum][i],
                                            trialBkLatency[trialNum][i],
                                            ),
                                            )
  
            #Each trial entries are sorted by the intended load 
            #i.e., item indexed 1 in list
            thisTrialTableEntries.sort(key = operator.itemgetter(1))
            
            DetResTableEntries += thisTrialTableEntries
            detResTable = [('Trial Num', 
                        'Intended BK Load (pkts/sec)', 
                        'BK Frame Rate (pkts/sec)', 
                        'Voice Frame Rate (pkts\sec)', 
                        'Min R-Value', 
                        'Max Latency (msecs)',
                        'Max Pkt Loss (%)', 
                        'Max Jitter (msecs)', 
                        'BK Latency (msecs)')]
        detResTable += DetResTableEntries
        self.MyReport.InsertDetailedTable(detResTable, 
                                          columns = [
                                                     0.50*inch,
                                                     0.74*inch,
                                                     0.74*inch,
                                                     0.74*inch,
                                                     0.70*inch,
                                                     0.70*inch,
                                                     0.70*inch,
                                                     0.74*inch,                                                                  
                                                     0.70*inch
                                                     ]
                                          )
         
    def doBinarySearch(self):
        searchLogic = WE.BinarySerach()
        searchLogic.minimum(self.minBKRate)
        searchLogic.maximum(self.maxBKRate)
        searchLogic.resolutionPercent(self.searchResolution)
        totalStats = []
        neverPassed = True
        intendedRate = self.minBKRate
        prevTestRate = 0
        while searchLogic.searching():
            trialResults = odict.OrderedDict()
            testRate = int(searchLogic.query())
            # check if prev iteration load is the same as current load
            if testRate == prevTestRate:
                break
            self.Print("Intended Background rate(pps) - %d\n" % (testRate))
            WE.WriteDetailedLog(['Intended Rate - %s' % testRate])
            self.modifyVoiceFlowNumFrames()
            self.changeBKRate(testRate)
            WE.ClearAllCounter(self.CardList)   
            self.startTraffic()
            currTime = 0.0
            #Print some stuff periodically so that GUI gets a chance 
            #to handle other events
            while currTime < self.TransmitTime:
                self.Print("\r Call Time - %0.1f" % (currTime))
                time.sleep(0.5)
                currTime += 0.5
            self.Print("\r")
            self.stopTraffic()
            finalStats = self.collectStats(testRate, trialResults)
            self.Print("Background traffic : Tx rate - %d, Rx rate - %d\n" % (
                      		  finalStats['flowRates'][1], finalStats['flowRates'][2]))
            result = self.checkStats(trialResults)
            trialResults.update(finalStats)
            totalStats.append(trialResults)            
            if result < 0:
                searchLogic.FAIL()
            else:
                intendedRate = testRate
                neverPassed = False
                bkTrafficTx = finalStats['flowRates'][1]                 
                bkTrafficRx = finalStats['flowRates'][2]        
                searchLogic.PASS()                
            # VPR 4318: If testRate < 2 fps then stop the iteration 
            if testRate < 2:
                break
            prevTestRate = testRate
        if testRate == self.maxBKRate and neverPassed == False:
            finalStats['neverBrokeSLA'] = True
        else:
            finalStats['neverBrokeSLA'] = False             
        if neverPassed == True:
            bkTrafficTx = finalStats['flowRates'][1]
            bkTrafficRx = finalStats['flowRates'][2] 

        finalStats['intendedRate'] = intendedRate                       
        finalStats['trialNeverPassed'] = neverPassed  
        finalStats['bkTrafficRx'] = bkTrafficRx
        finalStats['bkTrafficTx'] = bkTrafficTx        
        return (totalStats, finalStats)
    
    def doLinearSearch(self):
        currRate = self.minBKRate
        stopRate  = self.maxBKRate
        totalStats = []
        neverPassed = True
        intendedRate = self.minBKRate
        while currRate <= stopRate:
            trialResults = odict.OrderedDict()
            self.Print("Intended Background rate(pps) - %d\n"% (currRate))
            WE.WriteDetailedLog(['Intended Rate - %s' % currRate])
            self.modifyVoiceFlowNumFrames()
            self.changeBKRate(currRate)
            WE.ClearAllCounter(self.CardList)
            self.startTraffic()
            currTime = 0.0
            #Print some stuff periodically so that GUI gets a chance 
            #to handle other events
            while currTime < self.TransmitTime:
                self.Print("\r Call Time - %0.1f" % (currTime))
                time.sleep(0.5)
                currTime += 0.5
            self.Print("\r")
            self.stopTraffic()
            finalStats = self.collectStats(currRate, trialResults)
            self.Print("Background traffic : Tx rate - %d, Rx rate - %d\n" % (
                              finalStats['flowRates'][1], finalStats['flowRates'][2]))
            result = self.checkLinearStats(trialResults)
            trialResults.update(finalStats)
            totalStats.append(trialResults)
            if result == 1:               
                break
            else:
                neverPassed = False
                intendedRate = currRate
                currRate += self.incrPPS
                bkTrafficTx = finalStats['flowRates'][1]
                bkTrafficRx = finalStats['flowRates'][2]
        
        if currRate > self.minBKRate:         
            finalStats['neverBrokeSLA'] = True
        else:
            finalStats['neverBrokeSLA'] = False                         
        if neverPassed == True:
            bkTrafficTx = finalStats['flowRates'][1]            
            bkTrafficRx = finalStats['flowRates'][2] 
                       
        finalStats['intendedRate'] = intendedRate                         
        finalStats['trialNeverPassed'] = neverPassed  
        finalStats['bkTrafficTx'] = bkTrafficTx         
        finalStats['bkTrafficRx'] = bkTrafficRx                
        return (totalStats, finalStats)

    def startTest(self):
        self.testResults = odict.OrderedDict()
        self.resultSummaryData = []
        for i in range(self.Trials):
            # Print out the AP's BSSID, SSID, RSSI and other info to the CSV file
            WE.WriteAPinformation(self.clientList)
            self.Print("-------- Trial - %d --------\n" % (i+1))
            WE.WriteDetailedLog(['---- Trial - %d ----' % (i+1)])
            if self.binarySearchFlag == True:
                (totalStats, finalStats) = self.doBinarySearch()
            else:
                (totalStats, finalStats) = self.doLinearSearch()
            self.Print("Background Rx Rate = %d\n" % finalStats['flowRates'][2])
            self.testResults[str(i)] = totalStats[:]
            self.resultSummaryData.append([finalStats['neverBrokeSLA'], 
                                           finalStats['trialNeverPassed'], 
                                           finalStats['bkTrafficTx'],
                                           finalStats['bkTrafficRx'],
                                           finalStats['intendedRate']])       
            del totalStats
            time.sleep(self.SettleTime)
            WE.CheckEthLinkWifiClientState(self.CardList, self.clientList)
    
    def storeFlows(self, allFlows, bgFlows):
        self.bgFlows    = bgFlows.copy()
        self.allFlows   = allFlows.copy()
        self.voiceFlows = {}
        for flowName in allFlows.keys():
            if flowName not in bgFlows.keys():
               self.voiceFlows.update(dict([(flowName, allFlows[flowName])])) 

    def createFGroups(self):
        self._createFlowGroup(self.voiceFlows, "voiceGroup")
        self._createFlowGroup(self.bgFlows, "bkGroup")

    def doTestArpExchange(self):
        self.doArpExchanges("voiceGroup", self.voiceFlows)
        # only do ARPs if bk traffic type is not TCP        
        if self.backgroundType != 'TCP' and self.backgroundFrameRate > 0:         
            self.doArpExchanges("bkGroup", self.bgFlows)

    def run(self):
        try:
            self.ExitStatus = 0
            WE.setPortInfo({})
            WE.setPortBSSID2SSID({})
            WE.OpenLogging(Path=self.LoggingDirectory, Detailed=self.DetailedFilename)
            self.configurePorts()
            self.initailizeCSVfile()
            clientTuples = self.createClientTuple(self.ClientGroups)
            self.createClientsForTopology(clientTuples)
            #Related to VPR 4202. We want the MAC addresses to be distinct and also be set 
            #consistently. See the usage of the variable _ClientMACCounter in WaveEngine
            WE.SetClientMACCounter() 
            
            (createdClients, 
             self.clientList) = self.createClients(clientTuples)
             
            self.connectClients(self.clientList)
            WE.ClientLearning(self.clientList, self.ClientLearningTime, self.ClientLearningRate)
            (generatedFlows, bgFlows) = self.configureFlows(self.ClientGroups, self.FlowMappings, createdClients)
            self.storeFlows(generatedFlows, bgFlows)
            self._configureClientObjectsFlows(self.FlowList)
            self.setNATflag()
            self.createFGroups()
            if self.backgroundType == 'TCP':
                # do biflow.connect
                if WE.ConnectBiflow(bgFlows.keys()) < 0:
                    self.SavePCAPfile = True
                    raise WE.RaiseException
            self.doTestArpExchange()
            self.initReport()
            self.startTest()
            self.reportStats()
            if self.generatePdfReportF:
                self.printReport()    #This calls the printReport in QosCommon, don't get confused 
                                      #with 'PrintReport' (note the 'P' ) in BaseTest 
            self.SaveResults()
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
                for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                    msg += str(text)
                self.Print(str(msg), 'ERR')
            except Exception, e:
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1
        self.CloseShop()
        return self.ExitStatus
    #-- End def run() -- 

    def makeFlow(self, flowType, data, phyRate, prio, srcPort, dstPort, tosOptions,
                 bidirectionF = False):
        flowName = flowType + str(phyRate)
        flowDict = self.FlowOptions.copy() # VPR 2983  odict.OrderedDict()
        if flowType == 'voice':
            dataVoice = data['Voice']
            codec = dataVoice['Codec']
            trafficType = 'VOIPG711'
            if codec == 'G.711':
                trafficType = 'VOIPG711'
                FrameRate = 50
            elif codec == 'G.723':
                trafficType = 'VOIPG7231'
                FrameRate = 33
            elif codec == 'G.729':
                trafficType = 'VOIPG729A'
                FrameRate = 50
            flowDict['Type'] = trafficType
            flowDict['PhyRate'] = phyRate
            # VPR 4370: calculate the number of frames to transmit for each flow
            self.voiceNumFrames = int(FrameRate * self.TransmitTime)            
            flowDict['NumFrames'] = self.voiceNumFrames
        else:
            dataBG = data['Background']
            flowDict['Type'] = dataBG['Type']
            flowDict['FrameSize'] = dataBG['FrameSize']
            flowDict['PhyRate'] = phyRate
            flowDict['RateMode'] = 'pps'
            flowDict['NumFrames'] = WE.MAXtxFrames
            flowDict['IntendedRate'] = 100
            flowDict['flowType'] = 'BKFlow'
            flowDict['bidirection'] = bidirectionF
        if prio != None:    #When QoS Enabled
            flowDict['UserPriority'] = prio
        #The below two options for the Voice Flows must be deleted to avoid a warning message
        #that these options are not supported, we delete them in delflowOptions(), we 
        #delete 'TosVal', 'dscpMode' options too
        flowDict['srcPort'] = srcPort
        flowDict['destPort'] = dstPort
                    
        if tosOptions['TosDiffservDSCP'] != 'Default':
            flowDict['dscpMode'] = 'on'
            tosVal = tosOptions['TosDiffservDSCP']
        else:
            flowDict['dscpMode'] = 'off'
            tosVal = comupteToSByte(tosOptions)
        flowDict['TosVal'] = tosVal
        
        self.FlowConfigs[flowName] = flowDict
        return flowName
            
    def modifyMaps(self, tmpFlows, data, bgPrio, bgSrcP, bgDstP, vPrio, 
                   vSrcP, vDstP, bgDirection, bgToSoptions, voiceToSoptions):
        self.FlowMappings = odict.OrderedDict()
        self.FlowConfigs = odict.OrderedDict()
        phyRateFlowMap = odict.OrderedDict()
        phyRateFlowBGMap = odict.OrderedDict()
        for mapName in tmpFlows.keys():
            srcCG = tmpFlows[mapName]['SrcCG']
            dstCG = tmpFlows[mapName]['DstCG']
            flowType = tmpFlows[mapName]['flowType']
            if self.trafficDirection == "Wireless To Wireless":
                # take the smallest phyrate from src & dest
                phyRate = min(self.ClientGroups[srcCG]['PhyRate'],
                              self.ClientGroups[dstCG]['PhyRate'])
            else:
                if self.ClientGroups[srcCG]['Interface'] in WE.WiFiInterfaceTypes:
                    wlanCG = srcCG
                else:
                    wlanCG = dstCG
                phyRate = self.ClientGroups[wlanCG]['PhyRate']
            if flowType == 'voice':
                if str(phyRate) not in phyRateFlowMap.keys():
                    phyRateFlowMap[str(phyRate)] = self.makeFlow('voice', data,
                                                                 phyRate, vPrio,
                                                                 vSrcP, vDstP,
                                                                 voiceToSoptions
                                                                 )
                del tmpFlows[mapName]['flowType']
                tmpFlows[mapName]['FlowName'] = phyRateFlowMap[str(phyRate)]
            if flowType == 'background':
                if str(phyRate) not in phyRateFlowBGMap.keys():
                    bidirectionF = False
                    if bgDirection == 'Bidirectional':
                        bidirectionF = True
                    phyRateFlowBGMap[str(phyRate)] = self.makeFlow('bk', data,
                                                                   phyRate, bgPrio,
                                                                   bgSrcP, bgDstP,
                                                                   bgToSoptions,
                                                                   bidirectionF)
                del tmpFlows[mapName]['flowType']
                tmpFlows[mapName]['FlowName'] = phyRateFlowBGMap[str(phyRate)]
            self.FlowMappings[mapName] = tmpFlows[mapName]
        
    def getInfo( self ):
        """
        Returns blurb shown in the GUI describing the test.
        """
        msg = "The test determines the maximum amount " \
              "of low priority traffic that the System Under Test (SUT) can sustain without " \
              "breaking the Service Level Agreement (SLA) for a specified number of VoIP calls. " \
              "The Service Level Agreement can be specified as a minimum " \
              "R-value or a combination of maximum Packet Loss, Latency and Jitter of the VoIP calls." 
        
        return msg
     
    def getCharts( self ):
        """
        Returns dictionary of all chart objects supported by this test.
        """
        return self.finalGraphs
     
    def loadData( self,
                   waveChassisStore,
                   wavePortStore,
                   waveClientTableStore,
                   waveSecurityStore,
                   waveTestStore,
                   waveTestSpecificStore,
                   waveMappingStore,
                   waveBlogStore ):
        """
        Load dictionary data into test.
        Raise exception on error
        """
     
        # load data into base class
        BaseTest.loadData( self,
                           waveChassisStore,
                           wavePortStore,
                           waveClientTableStore,
                           waveSecurityStore,
                           waveTestStore,
                           waveTestSpecificStore,
                           waveMappingStore,
                           waveBlogStore )
       
        #These are the test specific parameters that get passed down from the 
        #GUI for the test execution
        data = waveTestSpecificStore[ 'qos_service' ]
          
        # voice options
        voiceData = data[ 'Voice' ]
        codecType    = str( voiceData[ 'Codec'     ] )
        self.testParameters["Voice Codec"] = codecType
        self.totalCalls = int( voiceData[ 'NumberOfCalls' ] )
        self.testParameters["Number of Calls/AP"] = str(self.totalCalls) + " call(s)"
        # voice advanced options
        #self.voiceUserPriority valid only when 'QosEnabled' is checked. Use the value 'True' when the
        #key is not present, might be useful in case the GUI code doesn't properly add this key 
        #into the dictionary when dealing with old configuration files which doesn't have this key
        self.voiceUserPriority = None
        if voiceData.get('QoSEnabled', 'True').lower() == 'true':    
            val = voiceData.get( 'UserPriority', "Default" )
            if str( val ).lower() == "default":
                self.voiceUserPriority = 7
            else:
                # non-default value
                self.voiceUserPriority = val
        val = voiceData.get( 'SrcPort', "Default" )
        if str( val ).lower() == "default":
            voiceSrcPort = 5004
        else:
            # non-default value
            voiceSrcPort = val
        val = voiceData.get( 'DestPort', "Default" )
        if str( val ).lower() == "default":
            voiceDestPort = 5003
        else:
            # non-default value
            voiceDestPort = val

        # voice ToS options
        voiceTosField           = voiceData.get( 'TosField', "Default" )
        # TosField could be 'Default' or a string from the Prec combo: Routine, Priority, etc...
        voiceTosLowDelay        = voiceData.get( 'TosLowDelay', False ) # just a boolean, True/False
        voiceTosHighThroughput  = voiceData.get( 'TosHighThroughput', False ) # just a boolean, True/False
        voiceTosHighReliability = voiceData.get( 'TosHighReliability', False ) # just a boolean, True/False
        voiceTosLowCost         = voiceData.get( 'TosLowCost', False ) # just a boolean, True/False
        voiceTosReserved        = voiceData.get( 'TosReserved', False ) # just a boolean, True/False
        voiceTosDiffservDSCP    = voiceData.get( 'TosDiffservDSCP', "Default" ) # string 'Default' or integer 0-63
        voiceToSoptions = {'TosField':voiceTosField,
                           'TosLowDelay':voiceTosLowDelay,
                           'TosHighThroughput':voiceTosHighThroughput,
                           'TosHighReliability':voiceTosHighReliability,
                           'TosLowCost':voiceTosLowCost,
                           'TosReserved':voiceTosReserved,
                           'TosDiffservDSCP':voiceTosDiffservDSCP
                           }

        # background traffic options
        bgData = data[ 'Background' ]
        trafficType      =   str( bgData[ 'Type'      ] )
        self.backgroundType = trafficType   
        self.backgroundFrameRate = int(bgData['FrameRate'])     
        self.testParameters["Background Traffic Type"] = trafficType
        self.bgFrameSize =   int( bgData[ 'FrameSize' ] )
        if bgData[ 'MinFrameRate' ] == "Default":
            minRateField = 10
        else:
            minRateField = int ( bgData[ 'MinFrameRate' ] )
        if bgData[ 'MaxFrameRate' ] == "Default":
            maxRateField = 7000
        else:
            maxRateField = int ( bgData[ 'MaxFrameRate' ] )

        if minRateField > maxRateField:      
             msg = "Minimum Frame Rate Serach Parameter is greater than Maximum"
             raise Exception, msg
         
        # get search parameters
        stepRateField = int( bgData.get( 'SearchStep', 10 ) )
        searchResField = float( str( bgData.get( 'SearchResolution', 0.1 ) ) )
        searchMode = str( bgData.get( 'SearchMode', "Linear" ) )
        self.testParameters["Traffic Rate Min-Max"] = "%s - %s" % (minRateField, maxRateField)
        # background traffic direction
        #   value can be one of: 'Unidirectional', or 'Bidirectional'
        trafficDirection = str( bgData.get( 'Direction', 'Unidirectional' ) )
        self.testParameters['Background Traffic Direction'] = trafficDirection  
        
        # background traffic advanced options
        #Background UserPriority valid only when 'QosEnabled' is checked. Use the value 'True' when the
        #key is not present, might be useful in case the GUI code doesn't properly add this key 
        #into the dictionary when dealing with old configuration files which doesn't have this key
        self.backgroundUserPriority = None
        if bgData.get('QoSEnabled', 'True').lower() == 'true':  
            val = bgData.get( 'UserPriority', "Default" )
            if str( val ).lower() == "default":
                self.backgroundUserPriority = 1
            elif 0 <= val <= 7:
                # non-default value
                self.backgroundUserPriority = val
        
        val = bgData.get( 'SrcPort', "Default" )
        if str( val ).lower() == "default":
            bgSrcPort = 0
        else:
            # non-default value
            bgSrcPort = val
        val = bgData.get( 'DestPort', "Default" )
        if str( val ).lower() == "default":
            bgDestPort = 0
        else:
            # non-default value
            bgDestPort = val

        # background ToS options
        bgTosField           = bgData.get( 'TosField', "Default" )
        # TosField could be 'Default' or a string from the Prec combo: Routine, Priority, etc...
        bgTosLowDelay        = bgData.get( 'TosLowDelay', False ) # just a boolean, True/False
        bgTosHighThroughput  = bgData.get( 'TosHighThroughput', False ) # just a boolean, True/False
        bgTosHighReliability = bgData.get( 'TosHighReliability', False ) # just a boolean, True/False
        bgTosLowCost         = bgData.get( 'TosLowCost', False ) # just a boolean, True/False
        bgTosReserved        = bgData.get( 'TosReserved', False ) # just a boolean, True/False
        bgTosDiffservDSCP    = bgData.get( 'TosDiffservDSCP', "Default" ) # string 'Default' or integer 0-63
        bgDirection          = bgData.get( 'Direction', "Unidirectional" )
        bgToSoptions = {'TosField':bgTosField,
                       'TosLowDelay':bgTosLowDelay,
                       'TosHighThroughput':bgTosHighThroughput,
                       'TosHighReliability':bgTosHighReliability,
                       'TosLowCost':bgTosLowCost,
                       'TosReserved':bgTosReserved,
                       'TosDiffservDSCP':bgTosDiffservDSCP
                        }
         #___________________________________TEL_________________________________________________
        #check for the db key in the waveTestStore['LogsAndResultsInfo'] dictionary if present assign the
        #the corresponding value to DbSupport. Similarly check for the key for pass/fail criteria pf and
        #update the self.UserPassFailCriteria['user'].If user is True then assign the other values for the
        #calculation purpose to judge the pass/fail of the result.

        if  waveTestStore['LogsAndResultsInfo'].has_key('db'):
            if  waveTestStore['LogsAndResultsInfo']['db'] == "True":
                self.DbSupport = waveTestStore['LogsAndResultsInfo']['db']
        if  waveTestStore['LogsAndResultsInfo'].has_key('pf'):
            if  waveTestStore['LogsAndResultsInfo']['pf'] == "True":
                self.UserPassFailCriteria['user'] = waveTestStore['LogsAndResultsInfo']['pf']
                if bgData.has_key('AcceptableBackgroundRate'):
                    if int(bgData['AcceptableBackgroundRate']) >=0:
                        self.UserPassFailCriteria['ref_min_bk_rate']= int(bgData['AcceptableBackgroundRate'])
                    else:
                        WaveEngine.OutputstreamHDL("\nThe value for the parameter AcceptableBackgroundRate  should be a positive number\n",WaveEngine.MSG_ERROR)
                        raise  WaveEngine.RaiseException
                else:
                    #WaveEngine.OutputstreamHDL("\nUser has not given the value for <AcceptableBackgroundRate> parameter, hence reverting to default value and proceeding further....\n",WaveEngine.MSG_WARNING)
                    self.UserPassFailCriteria['ref_min_bk_rate']=200
        #___________________________________TEL_________________________________________________
         
        # Auto Mapping options
        autoMap = data['AutoMap']
        self.trafficDirection = autoMap.get('trafficDirection', 'Ethernet To Wireless')
        self.splitTraffic = autoMap.get('splitTraffic', False)
        self.testParameters['Voice and Background Traffic Direction'] = self.trafficDirection 
 
        # Global Test Options
        self.testParameters['Trial Duration (secs)'] = self.TransmitTime
        self.testParameters['Settle Time (secs)'] = self.SettleTime 
        self.testParameters['Num of Trials'] = self.Trials 
        
        # SLA options
        slaData = data[ 'SLA' ]
        mode = slaData[ 'Mode' ]    # Mode = 'R-Value' or 'MaxLPJ'
        slaMinRValueField  = float( slaData[ 'MinRValue'  ] )
        slaMaxLatencyField = float( slaData[ 'MaxLatency' ] )
        slaMaxPktLossField = float( slaData[ 'MaxPktLoss' ] )
        slaMaxJitterField  = float( slaData[ 'MaxJitter'  ] )
        self.minBKRate         = minRateField
        self.maxBKRate         = maxRateField
        self.incrPPS           = stepRateField
        self.searchResolution  = searchResField
        self.RvalueF           = False
        self.latencyValueF     = False
        self.pktLossValueF     = False
        self.jitterValueF      = False
        if mode == 'R-Value':
            self.RvalueF       = True
            self.RvalueResolution  = 0
            self.Rvalue            = slaMinRValueField
            self.testParameters["SLA Target"] = 'Min R-Value'
            self.testParameters["Min R-Value"] = "(" + str(self.Rvalue) + ")"
        if mode == 'MaxLPJ':
            self.latencyValueF     = True
            self.latencyValue      = slaMaxLatencyField
            self.latencyResolution = 0
            self.pktLossValueF     = True 
            self.pktLossValue      = slaMaxPktLossField
            self.pktLossResolution = 0
            self.jitterValueF      = True
            self.jitterValue       = slaMaxJitterField
            self.jitterResolution  = 0
            self.testParameters["SLA Target"] = 'Max Latency PktLoss Jitter'
            self.testParameters["Max Latency"] = str(self.latencyValue) + "ms"
            self.testParameters["Max Pkt Loss"] = str(self.pktLossValue) + "%"
            self.testParameters["Max Jitter"] = str(self.jitterValue) + "ms"
        self.testParameters["Search Mode"] = searchMode
        if searchMode == "Binary":
            self.binarySearchFlag  = True
            self.testParameters["Search Resolution"] = str(self.searchResolution) + "%"
        else:
            self.binarySearchFlag  = False
            self.testParameters["Frame Rate Increment Step"] = str(self.incrPPS) + "fps"
        self.NetworkList = odict.OrderedDict()
        tmpClientGroups = self.configCGs(waveClientTableStore, 
                waveSecurityStore, waveTestSpecificStore)

        (tmpFlowMaps, self.ClientGroups) = self.configCGMaps(tmpClientGroups)
        if tmpFlowMaps == -1:
            return False
        self.modifyMaps(tmpFlowMaps, data, self.backgroundUserPriority, bgSrcPort, 
                        bgDestPort, self.voiceUserPriority, voiceSrcPort, voiceDestPort, 
                        bgDirection, bgToSoptions, voiceToSoptions) 

        # all good
        return True

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
