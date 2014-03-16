# scaled_roaming.py
# Description:
# user configurable parameters are located in scaled_roaming_config.py

########################### DO NOT MODIFY BELOW HERE ###########################

import os, sys, time, traceback, sched
from basetest import *
from scaled_roaming_config import UserConfig
from BaseEventClass import getSecClass
import WaveEngine
from CommonFunctions import *
from optparse import OptionParser
from vcl import *

################################# Constants ####################################
ROAMING_RECORD_LENGTH = 29
RR_CLIENT_NAME, RR_ROAM_NUMBER, RR_SRC_BSSID, RR_TARGET_BSSID, \
RR_MC_CONNECTION_COMPLETE_TIME, RR_NETWORK_CONNECTED_FLAG, \
RR_RX_MC_DEAUTH_DISASSOC_TIME, RR_LAST_REASON_CODE, RR_TX_MC_START_TIME, \
RR_TGA_PROCESSING_TIME, RR_TSTAMP_PROBE_RSP, RR_TSTAMP_AUTH1_REQ, RR_TSTAMP_AUTH1_RSP, \
RR_TSTAMP_AUTH2_REQ, RR_TSTAMP_AUTH2_RSP, RR_TSTAMP_ASSOC_REQ, RR_TSTAMP_ASSOC_RSP, \
RR_LAST_STATUS_CODE, RR_TSTAMP_EAP_REQ_IDENTITY, RR_TSTAMP_EAP_RSP_IDENTITY, \
RR_TSTAMP_EAP_SUCCESS_OR_FAILURE, RR_TSTAMP_EAPOL_PAIRWISE_KEY, \
RR_TSTAMP_EAPOL_GROUP_KEY, RR_TSTAMP_DHCP_DISCOVER, \
RR_TSTAMP_DHCP_OFFER, RR_TSTAMP_DHCP_REQUEST, RR_TSTAMP_DHCP_ACK, RR_TSTAMP_NAT_REQ, \
RR_TSTAMP_NAT_RSP = range(ROAMING_RECORD_LENGTH)  

NUM_OF_ROAMS, NUM_OF_FAILED_ROAMS, NUM_OF_FAILED_ASSOC, \
NUM_OF_FAILED_NETWORK_CONN, TOTAL_ASSOC_TIME = range(5)   

RA_SSID, RA_BSSID_LIST, RA_NUM_OF_CLIENTS = range(3)    

CLIENTGRP_NAME, CLIENTGRP_PORTNAME, CLIENTGRP_BSSIDSSID, CLIENTGRP_MACADDR, \
CLIENTGRP_IPADDR, CLIENTGRP_SUBNET, CLIENTGRP_GATEWAY, CLIENTGRP_INCRTUPLE, \
CLIENTGRP_SECURITY_OPTIONS, CLIENTGRP_OPTIONS = range(10)

INCRTUPLE_NUM_OF_CLIENTS, INCRTUPLE_MAC_INCR_BYTE, INCRTUPLE_IP_INCR_BYTE = range(3)                                                        

FILE_HANDLER, INDEX_COUNT, LINES_COUNT = range(3)

SUCCESS_LIST, FAILED_LIST = range(2)

SECURITY_WEP_OPEN = 1
SECURITY_WEP_SHARED = 2
SECURITY_WPA_WPA2_PSK = 3
SECURITY_CCKM = 4
SECURITY_8021X = 5

DETAILED_RESULT_LENGTH = 38
DR_CLIENT_NAME, DR_ROAM_NUMBER, DR_ELAPSED_TIME, DR_MAC_ADDRESS, DR_SRC_BSSID, DR_TARGET_BSSID, \
DR_MC_CONNECTION_COMPLETE_TIME, DR_NETWORK_CONNECTED_FLAG, \
DR_RX_MC_DEAUTH_DISASSOC_TIME, DR_LAST_REASON_CODE, DR_TX_MC_START_TIME, \
DR_CLIENT_DELAY, DR_AP_ROAM_DELAY, DR_TSTAMP_PROBE_RSP, \
DR_AP_PROBE_RSP_DELAY, DR_TSTAMP_AUTH1_REQ, DR_TSTAMP_AUTH1_RSP, DR_AP_80211_AUTH_DELAY, \
DR_TSTAMP_AUTH2_REQ, DR_TSTAMP_AUTH2_RSP, DR_AP_WEP_AUTH_DELAY, DR_TSTAMP_ASSOC_REQ, \
DR_TSTAMP_ASSOC_RSP, DR_AP_ASSOC_DELAY, DR_TOTAL_ROAM_DELAY, DR_LAST_STATUS_CODE, \
DR_TSTAMP_EAP_REQ_IDENTITY, DR_TSTAMP_EAP_RSP_IDENTITY, DR_TSTAMP_EAP_SUCCESS_OR_FAILURE, \
DR_TSTAMP_EAPOL_PAIRWISE_KEY, DR_TSTAMP_EAPOL_GROUP_KEY, \
DR_AUTH_TIME, DR_TSTAMP_DHCP_DISCOVER, DR_TSTAMP_DHCP_OFFER, DR_TSTAMP_DHCP_REQUEST, \
DR_TSTAMP_DHCP_ACK, DR_TSTAMP_NAT_REQ, DR_TSTAMP_NAT_RSP = range(DETAILED_RESULT_LENGTH) 
   

class Test(BaseTest, UserConfig):
    def __init__(self):
        BaseTest.__init__(self)
        UserConfig.__init__(self)

        ####################### Learning parameters ############################
        """
        These parameters are used to train the DUT/SUT about the clients and flows that are used during the test. Loss is not
        an issue during learning, only during the actual measurement.
        
        ClientLearningTime - The number of seconds that a Client will flood a DNS request with its source IP address. This is
                             used to teach the AP about the existance of a client if Security or DHCP is not suffiecient.
        ClientLearningRate - The rate of DNS request the client will learn with in units of frames per second.
        FlowLearningTime   - The number of seconds that the actual test flows will send out learning frames to populate the
                             DUT/SUT forwarding table.  The rate is at teh configure test rate. 
        FlowLearningRate   - The rate of flow learning frames are transmitted in units of frames per second. This should be set
                             lower than the actual offered loads.
        """
        self.ClientLearningTime = 0
        self.ClientLearningRate = 10
        self.FlowLearningTime   = 2
        self.FlowLearningRate   = 100

        ########################  Flow parameters  #############################
        """
        These parameters determine the type of data frames and flows to be used in the test. 
        
        FlowOptions - Dictionary of options used to configure data flows. 
        Field Definitions:
          Type - Packet or frame type. Valid values: 'UDP', 'TCP', 'IP', 'ICMP', 
        """
        self.FlowOptions    = {'Type': 'UDP', 'PhyRate': 54}
        self.LocalPortNumber = 60
        self.DestPortNumber = 60
        self.BiDirectional  = False
        
        ###################### Logging Parameters ##############################
        """
        These parameters determine the how the output of the test is to be formed. 
        CSVfilename -       Name of the output file that will contain the primary test results. This file will be in CSV format.
                            This name can include a path as well. Otherwise the file will be placed at the location of the calling
                            program. 
        ReportFilename -    Name of the output file that will contain a formatted report with graphs, explainations, diagrams and
                            the CSV data.  This file is in PDF format. This name can include a path as well. Otherwise the file will
                            be placed at the location of the calling program.
        DetailedFileHandlerDict - a dictionary of: {'portName1': [fileHandler1, index_count1, lines_count1], } 
        DetailedFailedFileHandlerDict - a dictionary of: {'portName1': fileHandler1, index_count1, lines_count1], } 
        maxRoamingRecordsPerCsvFile - max roaming records per CSV file
        """
        self.CSVfilename          = 'Results_' + self.getTestName() + '.csv'
        self.ReportFilename       = 'Report_' + self.getTestName() + '.pdf'
        self.DetailedFileHandlerDict = odict.OrderedDict()
        self.DetailedFailedFileHandlerDict = odict.OrderedDict()
        self.RSSIFilename         = 'RSSI_' + self.getTestName() + '.csv'
        self.RoamingStatsCaptureLog = 'roamStatsCaptureLog.rsc' 
        self.maxRoamingRecordsPerCsvFile = 50000

        ####################### Timing parameters ##############################
        """
        These parameters will effect the performance of the test. They should only be altered if a specific
        problem is occuring that keeps the test from executing with the DUT. 
        
        ARPRate -           The rate at which the test will attempt issue ARP requests during the learning phase. 
                            Units: ARPs/second; Type: float
        ARPRetries -        Number of attempts to retry any give ARP request before considering the ARP a failure. 
        ARPTimeout -        Amount of time the test will wait for an ARP response before retrying or failing.
        UpdateInterval -    Interval at which the test will attempt to update test status back to the display console. 
                            Units: seconds
        DisplayPrecision -  Number of decimal places to use in reporting results.
        ClientContention -  Valid probability is between 0% and 100%.  The number should be interpreted as the "probability" 
                            of contention, and will be specified as the maximum probability of the [n-1,n] segment.
                            Example, specifying 50 means that the probability of generating a FCS error frame is between 40%
                            and 50%.  Only Values of 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, and 100 should be set.
        elapsedTime -       elapsed time
        """
        self.ARPRate           =  25.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0
        self.UpdateInterval    =  0.5
        self.DisplayPrecision  =   3
        self.testOptions['ContentionProbability'] = 0
        self.elapsedTime       = 0.0

        ##################### Internal data stuctures ##########################
        
        # self.roamingAreaDict format: {'portName1': ('ssid1', ('bssid1', 'bssid2',), numOfClients)}
        self.roamingAreaDict = odict.OrderedDict()
        # self.roamingAreaList format: ['portName1', 'portName2',]
        self.roamingAreaList = []
        # self.roamingCircuitList format: ['portName1->ssid1', 'portName2->ssid2',]
        self.roamingCircuitList = []
        # Detailed roaming result columns:
        self.detailedResultColumnsList = ['Client Name', 
                                          'Roam Number', 
                                          'Elapsed Time (sec)',
                                          'MAC Address',
                                          'srcBssid',
                                          'targetBssid',                                          
                                          'MC Connection Complete Time',
                                          'Network Connected (true=1/false=0)',
                                          'RxMcDeauthDisassocTime',
                                          'Last reason code',
                                          'TxMcStartTime',
                                          'Client Delay',
                                          'AP Roam Delay',
                                          'TstampProbeRsp',
                                          'AP Probe Response Delay',
                                          'TstampAuth1Req',
                                          'TstampAuth1Rsp',
                                          'AP 802.11 Auth Delay',
                                          'TstampAuth2Req',
                                          'TstampAuth2Rsp',
                                          'AP WEP Auth Delay',
                                          'TstampAssocReq',
                                          'TstampAssocRsp',
                                          'AP Association Delay',
                                          'Total Roam Delay',
                                          'Last status code',
                                          'TstampEapReqIdentity',
                                          'TstampEapRspIdentity',
                                          'TstampEapSuccessOrFailure',
                                          'TstampEapolPairwiseKey',
                                          'TstampEapolGroupKey',
                                          'Auth Time',
                                          'TstampDhcpDiscover',
                                          'TstampDhcpOffer',
                                          'TstampDhcpRequest',
                                          'TstampDhcpAck',
                                          'TstampNatReq',
                                          'TstampNatRsp'
                                          ] 

        # Overall summary columns:
        self.overallSummaryColumnsList = ['# of RA',
                                          '# of Clients',
                                          'Total # of Roams',
                                          '# of Failed Roams',
                                          'Average Association Time (ms)']
        # RA summary columns:
        self.raSummaryColumnsList = ['RA Id',
                                     '# of Clients',
                                     '# of BSSID',
                                     'Total # of Roams',
                                     '# of Failed Roams',
                                     '# of Failed Associations',
                                     '# of Failed Network Connections',
                                     'Average Association Time (ms)']
        # RA Summary dictionary
        self.raSummaryDict = odict.OrderedDict()
        self.PortOptions = {}
        self.clientPropertiesDict = odict.OrderedDict()
        self.roamNumberIndexDict = odict.OrderedDict()
        self.SavedData = UserConfig()
        self.scriptStartTime = 0.0
        self.roamStarted = False
        self.successFailedClientList = [[], []]
        
########################## DO NOT MODIFY BELOW HERE ############################

    def getTestName(self):
        return 'scaled_roaming'
    
    def loadData(self, 
                 waveChassisStore, 
                 wavePortStore, 
                 waveClientTableStore, 
                 waveSecurityStore, 
                 waveTestStore, 
                 waveTestSpecificStore, 
                 waveMappingStore, 
                 waveBlogStore):
        """
        Load dictionary data into test.
        Raise exception on error
        """
    
        # load data into base class
        BaseTest.loadData(self, 
                          waveChassisStore, 
                          wavePortStore, 
                          waveClientTableStore, 
                          waveSecurityStore, 
                          waveTestStore, 
                          waveTestSpecificStore, 
                          waveMappingStore, 
                          waveBlogStore)
        
        return True
    
    def __sanityCheck(self):
        # Check if client group names are all unique
        groupNameDict = {}
        for clientGroupList in self.SourceClients + self.DestClients:
            if groupNameDict.has_key(clientGroupList[CLIENTGRP_NAME]):
                WaveEngine.OutputstreamHDL("\nError: client group %s - client group name needs to be unique.\n" 
                                           %(clientGroupList[CLIENTGRP_NAME]), WaveEngine.MSG_ERROR)
                raise WaveEngine.RaiseException
            else:
                groupNameDict[clientGroupList[CLIENTGRP_NAME]] = ''
    
    def __scanForMultipleBssids(self):
        # self.roamingAreaDict format: 
        # {'portName1': ['ssid1', ['bssid1', 'bssid2',], numOfClients], }
        
        # check for wifi card type, only version 2 can support roamV2
        for portName in self.SrcCardList:
            modelName = WaveEngine.GetPortModelName(portName)
            if 'WBW1000' == modelName[0:7]:
                WaveEngine.OutputstreamHDL("\nPort %s doesn't support roam features - terminating test." 
                                           % (portName), WaveEngine.MSG_ERROR)
                raise WaveEngine.RaiseException                  
        
        # scan the port
        WaveEngine.OutputstreamHDL('Scanning Wifi ports for BSSIDs...\n', WaveEngine.MSG_OK)
        port2BssidDict = WaveEngine.GetBssidSsidDictionary(self.SrcCardList, self.BSSIDscanTime, self.maxBssidCount)
               
        if 0 == len(port2BssidDict):
            WaveEngine.OutputstreamHDL("\nNo BSSID found on scan - terminating test.", 
                       WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException            
        
        for index in range(0, len(self.SourceClients)):
            (clientGroupName, portName, ssid, macAddress, ipAddress, subnet, 
             gateway, incTuple, security, clientOptions) = self.SourceClients[index] 

            numOfClients = incTuple[INCRTUPLE_NUM_OF_CLIENTS]
            
            if portName not in self.roamingAreaDict:
                self.roamingAreaDict[portName] = [ssid, [], numOfClients]
            else:
                self.roamingAreaDict[portName][RA_NUM_OF_CLIENTS] += numOfClients
            if ssid != self.roamingAreaDict[portName][RA_SSID]:
                # invalid configuration
                WaveEngine.OutputstreamHDL("\nInvalid configuration: each Wifi port can only handle 1 Roaming Area, multiple SSIDs aren't allowed - terminating test.", 
                           WaveEngine.MSG_ERROR)
                raise WaveEngine.RaiseException
                
            bssidList = []
            for [_bssid, _ssid] in port2BssidDict[portName]:
                if ssid == _ssid:                    
                    bssidList.append(_bssid)
            self.roamingAreaDict[portName][RA_BSSID_LIST] = bssidList
                     
            if 1 >= len(bssidList):
                WaveEngine.OutputstreamHDL("\nInvalid configuration: one or less BSSID was found on the Roaming Area " + portName + " - terminating test.", 
                           WaveEngine.MSG_ERROR)
                raise WaveEngine.RaiseException   
            
            # Update the SSID field on self.SourceClient with the first BSSID on the list
            self.SourceClients[index] = (clientGroupName, portName, bssidList[0], macAddress, 
                                         ipAddress, subnet, gateway, incTuple, security, 
                                         clientOptions)
        
        # print out the roaming area information
        for portName in self.roamingAreaDict:
            WaveEngine.OutputstreamHDL("Port: %s - SSID: %s - BSSID list: %s\n" % 
                                       (portName, self.roamingAreaDict[portName][RA_SSID],
                                        self.roamingAreaDict[portName][RA_BSSID_LIST]), WaveEngine.MSG_OK)
                                     
    def __initializeCSVFile(self):
        import os.path
        self.ResultsForCSVfile = []
        
        self.ResultsForCSVfile.append(('WaveEngine Version', WaveEngine.full_version))
        self.ResultsForCSVfile.append(('Framework Version', WaveEngine.action.getVclVersionStr()))
        self.ResultsForCSVfile.append(('Firmware Version', WaveEngine.chassis.version))
        self.ResultsForCSVfile.append(('', ''))          
        self.ResultsForCSVfile.append(('TestID', str(self.TestID)))        
        for eachKey in self.DUTinfo.keys():
            self.ResultsForCSVfile.append((eachKey, self.DUTinfo[eachKey]))
        self.ResultsForCSVfile.append((),)
        
        FullPathFilename = os.path.join(self.LoggingDirectory, self.CSVfilename)
        # Test if we can write to the result CSV file
        try:
            _Fhdl = open(FullPathFilename, 'w')
            _Fhdl.close()
        except:
            WaveEngine.OutputstreamHDL("Error: CSV file %s is locked by another program.\n" % (FullPathFilename), WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException
        
        # Write to detailed log file(s)
        if 0 < len(self.DetailedFileHandlerDict) or 0 < len(self.DetailedFailedFileHandlerDict):
            for fileHandler in self.DetailedFileHandlerDict.values():
                for item in self.ResultsForCSVfile:
                    self.__writeDetailedLog(item, fileHandler[FILE_HANDLER])   
                self.__writeDetailedLog(self.detailedResultColumnsList, fileHandler[FILE_HANDLER])  
            for fileHandler in self.DetailedFailedFileHandlerDict.values():
                for item in self.ResultsForCSVfile:
                    self.__writeDetailedLog(item, fileHandler[FILE_HANDLER]) 
                self.__writeDetailedLog(self.detailedResultColumnsList, fileHandler[FILE_HANDLER])                           
        else:
            WaveEngine.OutputstreamHDL("Error: invalid detailed roaming result file specified", WaveEngine.MSG_ERROR) 
    
    def __writeDetailedLog(self, logList, fileHandler):
        first = True
        for currentObject in logList:
            if first:
                fileHandler.write("%s" % (currentObject))
                first = False
            else:
                fileHandler.write(", %s" % (currentObject))
        fileHandler.write("\n")
        fileHandler.flush()        
                                     
    def __createRoamingArea(self):
        import os.path
        self.roamingAreaList = WaveEngine.CreateRoamingArea(self.roamingAreaDict)
        # create a list of detailed CSV files for each RA
        for ra in self.roamingAreaList:
            self.roamNumberIndexDict[ra] = 0
            if True == self.SplitDetailedResultCsvFile:
                fileName = 'Detailed_' + self.getTestName() + "_" + ra + '_part1' + '.csv'
                failedName = 'Detailed_' + self.getTestName() + "_failed_roams_" + ra + '_part1' + '.csv' 
            else:
                fileName = 'Detailed_' + self.getTestName() + "_" + ra + '.csv' 
                failedName = 'Detailed_' + self.getTestName() + "_failed_roams_" + ra + '.csv'            
            try:
                self.DetailedFileHandlerDict[ra] = [open(os.path.join(self.LoggingDirectory, fileName), 'w'), 1, 0]
            except:
                WaveEngine.OutputstreamHDL("Error: Could not open %s for writing\n" % (fileName), WaveEngine.MSG_ERROR)   
            try:
                self.DetailedFailedFileHandlerDict[ra] = [open(os.path.join(self.LoggingDirectory, failedName), 'w'), 1, 0]   
            except:
                WaveEngine.OutputstreamHDL("Error: Could not open %s for writing\n" % (failedName), WaveEngine.MSG_ERROR)   
                          
    def __createRoamingCircuit(self):
        self.roamingCircuitList = WaveEngine.CreateRoamingCircuit(self.roamingAreaDict, self.DwellTime, self.PortsDwellTime)
    
    def __setClientRoamingOptions(self):
        from copy import deepcopy
        
        # add roaming options to client options
        for i in range(0, len(self.SourceClients)):
            (clientGroupName, portName, bssid, macAddress, ipAddress, subnet, 
             gateway, incTuple, security, clientOptions) = self.SourceClients[i]
            clientOptionsDict = deepcopy(clientOptions)
            clientOptionsDict['RoamingArea'] = portName
            clientOptionsDict['RoamingCircuit'] = portName + '->' + self.roamingAreaDict[portName][0]
            
            # set persistentReauth to off except when Network Auth method is EAP-FAST
            clientOptionsDict['PersistentReauth'] = 'off'
            if security.has_key('NetworkAuthMethod') and 'EAP/FAST' == security['NetworkAuthMethod']:
                clientOptionsDict['PersistentReauth'] = 'on'   
                
            # Check if learningRate is less than dwellTime  
            if clientOptionsDict.has_key('ClientLearning') and 'on' == clientOptionsDict['ClientLearning'] and \
              clientOptionsDict.has_key('LearningRate') and isnum(clientOptionsDict['LearningRate']):
                learningTime = 10.0 / float(clientOptionsDict['LearningRate'])  
                dwellTime = float(self.PortsDwellTime.get(portName, self.DwellTime))
                
                if learningTime > dwellTime:
                    WaveEngine.OutputstreamHDL("Warning: client group %s - learning time of %.1f sec is longer than dwell time of %.1f sec\n" % 
                                               (clientGroupName, learningTime, dwellTime), WaveEngine.MSG_WARNING)       
                
            self.SourceClients[i] = (clientGroupName, portName, bssid, macAddress, 
                                     ipAddress, subnet, gateway, incTuple, security, 
                                     clientOptionsDict)
    
    # TODO: Fix self.createClients() in basetest.py so it can easily be used 
    #       when running from scripts
    def __createClients(self):
        try:
            WaveEngine.OutputstreamHDL("\nCreating clients...\n", WaveEngine.MSG_OK)              
            self.ListofSrcClient = WaveEngine.CreateClients(self.SourceClients, LoginList=self.Logins)
            self.ListofDesClient = WaveEngine.CreateClients(self.DestClients, LoginList=self.Logins)
        except:
            WaveEngine.OutputstreamHDL("Failed to create the clients, terminating test.", WaveEngine.MSG_ERROR)
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            msg = "Script error:\n"
            for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                msg += str(text)
            WaveEngine.OutputstreamHDL(str(msg), WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException
        if len(self.ListofSrcClient) < len(self.SourceClients) or len(self.ListofDesClient) < len(self.DestClients):
            raise WaveEngine.RaiseException
        self.ListOfClients = {}
        self.ListOfClients.update(self.ListofSrcClient)
        self.ListOfClients.update(self.ListofDesClient)
        self.TotalClients  = len(self.ListOfClients)
        
        listOfClientProperties = []
        listOfClientProperties.append('MacAddress')
        self.clientPropertiesDict = WaveEngine.GetClientsProperties(self.ListofSrcClient, listOfClientProperties)
    
    def __updateClientsBssid(self):
        index = {}
        for portName in self.roamingAreaDict:
            index[portName] = 0
        
        if 0 < len(index):
            WaveEngine.OutputstreamHDL("\nUpdating clients BSSID...\n", WaveEngine.MSG_OK)  
            for client in self.ListofSrcClient:
                portName = self.ListofSrcClient[client][1]
                bssidList = self.roamingAreaDict[portName][RA_BSSID_LIST]
                bssid = bssidList[index[portName]]
                index[portName] = index[portName] + 1
                index[portName] = index[portName] % len(bssidList)
                WaveEngine.UpdateBssid(client, bssid)
                WaveEngine.UpdateClientDelays(client, 0)
    
    def __connectClients(self, clientList=()):
        if not clientList:
            clientList = self.getClientList()
            
        AssociateRate     = float(self.AssociateRate)
        AssociateRetries  = float(self.AssociateRetries)
        AssociateTimeout  = float(self.AssociateTimeout)
        TotalTimeout = ((len(clientList)/AssociateRate) + 
                        AssociateTimeout * (1 + AssociateRetries))
        ConnType = self.ConnectionType
        
        self.successFailedClientList = WaveEngine.AggregateConnectClients(
                                           clientList, AssociateRetries, AssociateTimeout, 
                                           noSummary=False, 
                                           ignoreClientAssocFailure=self.IgnoreClientAssocFailure, 
                                           ethIP='', localPort=-1, destPort=-1, 
                                           rate=AssociateRate, returnClientList=True) 
        
        if 0 != len(self.successFailedClientList[FAILED_LIST]):
            WaveEngine.OutputstreamHDL("Warning: %d client(s) failed to connect\n" %
                                       (len(self.successFailedClientList[FAILED_LIST])), WaveEngine.MSG_WARNING)
            if False == self.IgnoreClientAssocFailure:
                # save the roam stats before we quit the test
                WaveEngine.InitializeRoamingStatsCapture(self.RoamingStatsCaptureLog, self.roamingAreaList)
                WaveEngine.SaveRoamingStatsCapture()
                self.__collectRoamStats()
                self.SavePCAPfile = True
                self.Print("\nConnecting Clients Failed\n", 'ERR')
                raise WaveEngine.RaiseException
    
    def __initiateStunPackets(self):
        if self.stunRate > 0.0:
            successDict = odict.OrderedDict()
            successList = self.successFailedClientList[SUCCESS_LIST]
            
            for name in successList:
                if self.ListofSrcClient.has_key(name):
                    successDict[name] = self.ListofSrcClient[name]
            
            # Only initiate STUN packets for connected clients
            if 0 > WaveEngine.InitiateStunPackets(successDict, self.EthIP,
                                                  self.LocalPortNumber, self.DestPortNumber,
                                                  True, self.stunRate):
                self.SavePCAPfile = True
                self.Print("\nFailed to send STUN packets\n", 'ERR')
                raise WaveEngine.RaiseException            
    
    def __collectRoamStats(self, printStats=True):
        roamingRecordList = WaveEngine.GetRoamingRecord(self.RoamingStatsCaptureLog) 

        for recordList in roamingRecordList:
            clientName = recordList[RR_CLIENT_NAME]
            portName = self.ListofSrcClient[clientName][CLIENTGRP_PORTNAME]
            if True == self.SplitDetailedResultCsvFile:
                if self.maxRoamingRecordsPerCsvFile < self.DetailedFileHandlerDict[portName][LINES_COUNT]:
                    self.DetailedFileHandlerDict[portName][LINES_COUNT] = 0
                    self.DetailedFileHandlerDict[portName][INDEX_COUNT] += 1
                    fileName = 'Detailed_' + self.getTestName() + '_' + portName + \
                               '_part' + str(self.DetailedFileHandlerDict[portName][INDEX_COUNT]) + '.csv'
                    try:
                        self.DetailedFileHandlerDict[portName][FILE_HANDLER] = open(os.path.join(self.LoggingDirectory, fileName), 'w')
                        self.__writeDetailedLog(self.detailedResultColumnsList, self.DetailedFileHandlerDict[portName][FILE_HANDLER])              
                    except:
                        WaveEngine.OutputstreamHDL("Error: Could not open %s for writing\n" % (fileName), WaveEngine.MSG_ERROR)    
                if self.maxRoamingRecordsPerCsvFile < self.DetailedFailedFileHandlerDict[portName][LINES_COUNT]:
                    self.DetailedFailedFileHandlerDict[portName][LINES_COUNT] = 0
                    self.DetailedFailedFileHandlerDict[portName][INDEX_COUNT] += 1
                    failedName = 'Detailed' + self.getTestName() + "_failed_roams_" + portName + \
                                 '_part' + str(self.DetailedFailedFileHandlerDict[portName][INDEX_COUNT]) + '.csv'
                    try:
                        self.DetailedFailedFileHandlerDict[portName][FILE_HANDLER] = open(os.path.join(self.LoggingDirectory, failedName), 'w')
                        self.__writeDetailedLog(self.detailedResultColumnsList, self.DetailedFailedFileHandlerDict[portName][FILE_HANDLER])
                    except:
                        WaveEngine.OutputstreamHDL("Error: Could not open %s for writing\n" % (failedName), WaveEngine.MSG_ERROR)                                       
            fileHandler = self.DetailedFileHandlerDict[portName][FILE_HANDLER]
            failedHandler = self.DetailedFailedFileHandlerDict[portName][FILE_HANDLER]
            if 0 == self.__parseRoamingRecordList(recordList, fileHandler, failedHandler):
                self.DetailedFailedFileHandlerDict[portName][LINES_COUNT] += 1
            self.DetailedFileHandlerDict[portName][LINES_COUNT] += 1
                    
            mcConnectionCompleteTime = recordList[RR_MC_CONNECTION_COMPLETE_TIME]
            txMcStartTime = recordList[RR_TX_MC_START_TIME]
            tstampNatRsp = recordList[RR_TSTAMP_NAT_RSP]
      
            numOfRoams = 1
            numOfFailedRoams = 0
            if 0 == mcConnectionCompleteTime:
                numOfFailedRoams += 1
            numOfFailedAssoc = 0
            if 0 == txMcStartTime:
                numOfFailedAssoc += 1
            numOfFailedNetworkConn = 0
            if 0 == tstampNatRsp:
                numOfFailedNetworkConn += 1
            totalAssocTime = 0
            if 0 != mcConnectionCompleteTime:
                totalAssocTime = mcConnectionCompleteTime - txMcStartTime
                      
            if portName not in self.raSummaryDict:
                self.raSummaryDict[portName] = [numOfRoams, numOfFailedRoams,
                                                numOfFailedAssoc, numOfFailedNetworkConn,
                                                totalAssocTime]
            else:
                numOfRoams = self.raSummaryDict[portName][NUM_OF_ROAMS] + numOfRoams
                numOfFailedRoams = self.raSummaryDict[portName][NUM_OF_FAILED_ROAMS] + numOfFailedRoams
                numOfFailedAssoc = self.raSummaryDict[portName][NUM_OF_FAILED_ASSOC] + numOfFailedAssoc
                numOfFailedNetworkConn = self.raSummaryDict[portName][NUM_OF_FAILED_NETWORK_CONN] + numOfFailedNetworkConn
                totalAssocTime = self.raSummaryDict[portName][TOTAL_ASSOC_TIME] + totalAssocTime                 
                self.raSummaryDict[portName] = [numOfRoams, numOfFailedRoams,
                                                numOfFailedAssoc, numOfFailedNetworkConn,
                                                totalAssocTime]
        if True == printStats: 
            for portName in self.raSummaryDict:  
                WaveEngine.OutputstreamHDL("\nPort:%s - # of roams:%d - # of failed roams:%d - # of failed assoc:%d - # of failed network conn:%d" % 
                                           (portName, self.raSummaryDict[portName][NUM_OF_ROAMS], 
                                            self.raSummaryDict[portName][NUM_OF_FAILED_ROAMS], 
                                            self.raSummaryDict[portName][NUM_OF_FAILED_ASSOC], 
                                            self.raSummaryDict[portName][NUM_OF_FAILED_NETWORK_CONN]), 
                                            WaveEngine.MSG_OK)
    
    def __parseRoamingRecordList(self, record, fileHandler, failedHandler):
        list = [''] * DETAILED_RESULT_LENGTH
        
        """ 
DR_CLIENT_NAME, DR_ROAM_NUMBER, DR_MAC_ADDRESS, DR_SRC_BSSID, DR_TARGET_BSSID, 
DR_MC_CONNECTION_COMPLETE_TIME, DR_NETWORK_CONNECTED_FLAG, 
DR_RX_MC_DEAUTH_DISASSOC_TIME, DR_LAST_REASON_CODE, DR_TX_MC_START_TIME,                                 
DR_CLIENT_DELAY, DR_AP_ROAM_DELAY, DR_TSTAMP_PROBE_RSP, 
DR_AP_PROBE_RSP_DELAY, DR_TSTAMP_AUTH1_REQ, DR_TSTAMP_AUTH1_RSP, DR_AP_80211_AUTH_DELAY,
DR_TSTAMP_AUTH2_REQ, DR_TSTAMP_AUTH2_RSP, DR_AP_WEP_AUTH_DELAY, DR_TSTAMP_ASSOC_REQ, 
DR_TSTAMP_ASSOC_RSP, DR_AP_ASSOC_DELAY, DR_TOTAL_ROAM_DELAY, DR_TSTAMP_EAP_REQ_IDENTITY,
DR_TSTAMP_EAP_RSP_IDENTITY, DR_TSTAMP_EAP_SUCCESS_OR_FAILURE, 
DR_TSTAMP_EAPOL_PAIRWISE_KEY, DR_TSTAMP_EAPOL_GROUP_KEY, 
DR_AUTH_TIME, DR_TSTAMP_DHCP_DISCOVER, DR_TSTAMP_DHCP_OFFER, DR_TSTAMP_DHCP_REQUEST, 
DR_TSTAMP_DHCP_ACK, DR_TSTAMP_NAT_REQ, DR_TSTAMP_NAT_RSP = range(DETAILED_RESULT_LENGTH) 


RR_CLIENT_NAME, RR_ROAM_NUMBER, RR_SRC_BSSID, RR_TARGET_BSSID,
RR_MC_CONNECTION_COMPLETE_TIME, RR_NETWORK_CONNECTED_FLAG,
RR_RX_MC_DEAUTH_DISASSOC_TIME, RR_LAST_REASON_CODE, RR_TX_MC_START_TIME,                                 
RR_TGA_PROCESSING_TIME, RR_TSTAMP_PROBE_RSP, RR_TSTAMP_AUTH1_REQ, RR_TSTAMP_AUTH1_RSP,
RR_TSTAMP_AUTH2_REQ, RR_TSTAMP_AUTH2_RSP, RR_TSTAMP_ASSOC_REQ, RR_TSTAMP_ASSOC_RSP,
RR_TSTAMP_EAP_REQ_IDENTITY, RR_TSTAMP_EAP_RSP_IDENTITY, RR_TSTAMP_EAP_SUCCESS_OR_FAILURE, RR_TSTAMP_EAPOL_PAIRWISE_KEY,
RR_TSTAMP_EAPOL_GROUP_KEY, RR_TSTAMP_DHCP_DISCOVER,
RR_TSTAMP_DHCP_OFFER, RR_TSTAMP_DHCP_REQUEST, RR_TSTAMP_DHCP_ACK, RR_TSTAMP_NAT_REQ,
RR_TSTAMP_NAT_RSP = range(ROAMING_RECORD_LENGTH)  
        """           
        patt = re.compile(r'_[\d]+$')
        clientGroupName = patt.sub('', record[RR_CLIENT_NAME], 1)
        portName = ''
        securityType = 'NONE'
        for clientGroup in self.SourceClients:
            if clientGroupName == clientGroup[CLIENTGRP_NAME]:
                securityType = clientGroup[CLIENTGRP_SECURITY_OPTIONS]['Method']
                portName = clientGroup[CLIENTGRP_PORTNAME]
                break
        security = getSecClass(securityType)
        
        list[DR_CLIENT_NAME] = record[RR_CLIENT_NAME]
        list[DR_ROAM_NUMBER] = record[RR_ROAM_NUMBER]
        list[DR_MAC_ADDRESS] = self.clientPropertiesDict[record[RR_CLIENT_NAME]]['MacAddress']
        list[DR_SRC_BSSID] = record[RR_SRC_BSSID]
        if '00:00:00:00:00:00' == record[RR_SRC_BSSID]:
            self.roamNumberIndexDict[portName] += 1
            list[DR_ROAM_NUMBER] = 'NA'
            list[DR_SRC_BSSID] = 'NA'
        else:
            list[DR_ROAM_NUMBER] -= self.roamNumberIndexDict[portName]
        list[DR_TARGET_BSSID] = record[RR_TARGET_BSSID]        
        list[DR_MC_CONNECTION_COMPLETE_TIME] = record[RR_MC_CONNECTION_COMPLETE_TIME]
        list[DR_NETWORK_CONNECTED_FLAG] = record[RR_NETWORK_CONNECTED_FLAG]
        list[DR_RX_MC_DEAUTH_DISASSOC_TIME] = record[RR_RX_MC_DEAUTH_DISASSOC_TIME]
        list[DR_LAST_REASON_CODE] = record[RR_LAST_REASON_CODE]   
        list[DR_TX_MC_START_TIME] = record[RR_TX_MC_START_TIME]
        list[DR_CLIENT_DELAY] = record[RR_TGA_PROCESSING_TIME]
        list[DR_AP_ROAM_DELAY] = 'NA'
        list[DR_TSTAMP_PROBE_RSP] = record[RR_TSTAMP_PROBE_RSP]
        list[DR_AP_PROBE_RSP_DELAY] = record[RR_TSTAMP_PROBE_RSP] - record[RR_TX_MC_START_TIME]
        if 0 > list[DR_AP_PROBE_RSP_DELAY]:
            list[DR_AP_PROBE_RSP_DELAY] = 0
        list[DR_TSTAMP_AUTH1_REQ] = record[RR_TSTAMP_AUTH1_REQ]
        list[DR_TSTAMP_AUTH1_RSP] = record[RR_TSTAMP_AUTH1_RSP]
        list[DR_AP_80211_AUTH_DELAY] = record[RR_TSTAMP_AUTH1_RSP] - record[RR_TSTAMP_AUTH1_REQ]
        if 0 > list[DR_AP_80211_AUTH_DELAY]:
            list[DR_AP_80211_AUTH_DELAY] = 0
        list[DR_TSTAMP_AUTH2_REQ] = record[RR_TSTAMP_AUTH2_REQ]
        list[DR_TSTAMP_AUTH2_RSP] = record[RR_TSTAMP_AUTH2_RSP]  
        list[DR_AP_WEP_AUTH_DELAY] = 'NA'
        if security == SECURITY_WEP_SHARED:
            list[DR_AP_WEP_AUTH_DELAY] = record[RR_TSTAMP_AUTH2_RSP] - record[RR_TSTAMP_AUTH2_REQ]
            if 0 > list[DR_AP_WEP_AUTH_DELAY]:
                list[DR_AP_WEP_AUTH_DELAY] = 0
        list[DR_TSTAMP_ASSOC_REQ] = record[RR_TSTAMP_ASSOC_REQ]
        list[DR_TSTAMP_ASSOC_RSP] = record[RR_TSTAMP_ASSOC_RSP]
        list[DR_AP_ASSOC_DELAY] = record[DR_TSTAMP_ASSOC_RSP] - record[DR_TSTAMP_ASSOC_REQ]
        if 0 > list[DR_AP_ASSOC_DELAY]:
            list[DR_AP_ASSOC_DELAY] = 0    
        list[DR_TOTAL_ROAM_DELAY] = 'NA'  
        list[DR_LAST_STATUS_CODE] = record[RR_LAST_STATUS_CODE]
        list[DR_TSTAMP_EAP_REQ_IDENTITY] = record[RR_TSTAMP_EAP_REQ_IDENTITY]
        list[DR_TSTAMP_EAP_RSP_IDENTITY] = record[RR_TSTAMP_EAP_RSP_IDENTITY] 
        list[DR_TSTAMP_EAP_SUCCESS_OR_FAILURE] = record[RR_TSTAMP_EAP_SUCCESS_OR_FAILURE]       
        list[DR_TSTAMP_EAPOL_PAIRWISE_KEY] = record[RR_TSTAMP_EAPOL_PAIRWISE_KEY]        
        list[DR_TSTAMP_EAPOL_GROUP_KEY] = record[RR_TSTAMP_EAPOL_GROUP_KEY]               
        list[DR_AUTH_TIME] = 'NA'
        if security != SECURITY_WEP_OPEN and security != SECURITY_WEP_SHARED:
            list[DR_AUTH_TIME] = record[RR_MC_CONNECTION_COMPLETE_TIME] - record[RR_TSTAMP_ASSOC_RSP]
            if 0 > list[DR_AUTH_TIME]:
                list[DR_AUTH_TIME] = 0
        list[DR_TSTAMP_DHCP_DISCOVER] = record[RR_TSTAMP_DHCP_DISCOVER]
        list[DR_TSTAMP_DHCP_OFFER] = record[RR_TSTAMP_DHCP_OFFER]
        list[DR_TSTAMP_DHCP_REQUEST] = record[RR_TSTAMP_DHCP_REQUEST]
        list[DR_TSTAMP_DHCP_ACK] = record[RR_TSTAMP_DHCP_ACK]
        list[DR_TSTAMP_NAT_REQ] = record[RR_TSTAMP_NAT_REQ]
        list[DR_TSTAMP_NAT_RSP] = record[RR_TSTAMP_NAT_RSP]      
                    
        if 'NA' == list[DR_ROAM_NUMBER]:
            list[DR_ELAPSED_TIME] = 'NA'
        else:
            if 0.0 == self.elapsedTime: 
                self.elapsedTime = list[DR_TX_MC_START_TIME]
            elapsed = (list[DR_TX_MC_START_TIME] - self.elapsedTime) / 1000.0
            list[DR_ELAPSED_TIME] = "%.3f" % elapsed
                   
        self.__writeDetailedLog(list, fileHandler)
        if 0 == list[DR_MC_CONNECTION_COMPLETE_TIME]:
            # if got here, roam failed
            self.__writeDetailedLog(list, failedHandler)
            return 0 # return 0 for failed roam
        else:
            return 1 # return 1 for successful roam
                    
    def __createSummaryResultsFile(self):
        self.ResultsForCSVfile.append(('', ''))
        self.ResultsForCSVfile.append(self.overallSummaryColumnsList)
        
        numOfRAs = len(self.roamingAreaDict)
        numOfClients = len(self.ListofSrcClient)
        totalNumOfRoams = 0
        totalNumOfFailedRoams = 0
        averageAssociationTime = 0
        for raSummaryList in self.raSummaryDict.values():
            totalNumOfRoams += raSummaryList[NUM_OF_ROAMS]
            totalNumOfFailedRoams += raSummaryList[NUM_OF_FAILED_ROAMS]
            averageAssociationTime += raSummaryList[TOTAL_ASSOC_TIME]
        totalNumOfSuccessRoams = totalNumOfRoams - totalNumOfFailedRoams  
        if 0 != totalNumOfSuccessRoams:
            averageAssociationTime = averageAssociationTime / totalNumOfSuccessRoams
            
        roamNumberIndex = 0
        for number in self.roamNumberIndexDict.values():
            roamNumberIndex += number
        self.ResultsForCSVfile.append((numOfRAs, numOfClients, totalNumOfRoams-roamNumberIndex,
                                       totalNumOfFailedRoams, averageAssociationTime))
        
        self.ResultsForCSVfile.append(self.raSummaryColumnsList)
        for ra in self.roamingAreaDict:
            if ra in self.raSummaryDict:
                numOfClients = self.roamingAreaDict[ra][RA_NUM_OF_CLIENTS]
                numOfBssids = len(self.roamingAreaDict[ra][RA_BSSID_LIST])
                totalNumOfRoams = self.raSummaryDict[ra][NUM_OF_ROAMS]
                totalNumOfFailedRoams = self.raSummaryDict[ra][NUM_OF_FAILED_ROAMS]
                totalNumOfFailedAssoc = self.raSummaryDict[ra][NUM_OF_FAILED_ASSOC]
                totalNumOfFailedNetworkConn = self.raSummaryDict[ra][NUM_OF_FAILED_NETWORK_CONN]
                totalNumOfSuccessRoams = totalNumOfRoams - totalNumOfFailedRoams  
                averageAssociationTime = self.raSummaryDict[ra][TOTAL_ASSOC_TIME]
                if 0 != totalNumOfSuccessRoams:
                    averageAssociationTime = averageAssociationTime / totalNumOfSuccessRoams
                else:
                    averageAssociationTime = 0
                self.ResultsForCSVfile.append((ra, numOfClients, numOfBssids, totalNumOfRoams-self.roamNumberIndexDict[ra],
                                              totalNumOfFailedRoams, totalNumOfFailedAssoc,
                                              totalNumOfFailedNetworkConn, averageAssociationTime))          
        
    def __closeDetailedCsvFiles(self):
        for fileHandler in self.DetailedFileHandlerDict.values():
            fileHandler[FILE_HANDLER].close()   
        for fileHandler in self.DetailedFailedFileHandlerDict.values():
            fileHandler[FILE_HANDLER].close()                          
        
    def __scheduleNextEvent(self, scheduler, function, interval=1): 
        if self.stopTime > vclTime():
            #WaveEngine.OutputstreamHDL("TIME: %f - FUNCTION: %s\n" % (vclTime(), function), WaveEngine.MSG_OK) 
            function()
            if self.stopTime > interval + vclTime():
                scheduler.enter(interval, 1, self.__scheduleNextEvent, (scheduler, function, interval)) 
      
    def __printVclTime(self):
        WaveEngine.OutputstreamHDL("\nElapsed time: %.2fsec" % (vclTime()-self.scriptStartTime), WaveEngine.MSG_OK)
    
    def __saveFinalRoamStats(self):
        retry = 0
        while 0 >= WaveEngine.SaveRoamingStatsCapture() and 5 > retry:
            retry += 1
            time.sleep(1)
        self.__collectRoamStats(printStats=False)
        
    def __startTest(self, FuncRealTime):
        WaveEngine.ClearAllCounter(self.CardList)
        #self.writeRSSIinfo()

        WaveEngine.OutputstreamHDL("\n\nStart roaming...\n", WaveEngine.MSG_OK)            

        WaveEngine.InitializeRoamingStatsCapture(self.RoamingStatsCaptureLog, self.roamingAreaList)
        
        scheduler = sched.scheduler(vclTime, time.sleep)
        
        self.scriptStartTime = vclTime()
        
        scheduler.enter(0.01, 1, self.__scheduleNextEvent, (scheduler, self.__printVclTime))  
               
        for rc in self.roamingCircuitList:
            scheduler.enter(0, 1, WaveEngine.StartRoamingCircuit, (rc,))
            scheduler.enter(self.TestDuration, 1, WaveEngine.StopRoamingCircuit, (rc,))
            self.stopTime = vclTime() + self.TestDuration      
            #WaveEngine.OutputstreamHDL("STOP TIME: %f\n" % (self.stopTime), WaveEngine.MSG_OK)  

        if True == self.ParseRoamStatsInRealTime:      
            scheduler.enter(0, 1, self.__scheduleNextEvent, (scheduler, WaveEngine.SaveRoamingStatsCapture))          
            scheduler.enter(0, 1, self.__scheduleNextEvent, (scheduler, self.__collectRoamStats)) 
        else:
            # Save roam stats every 50 seconds until the end of transmit time
            scheduler.enter(0, 1, self.__scheduleNextEvent, (scheduler, WaveEngine.SaveRoamingStatsCapture, 50)) 
            scheduler.enter(0, 1, self.__scheduleNextEvent, (scheduler, self.__collectRoamStats, 50)) 
        scheduler.enter(self.TestDuration+4, 1, self.__saveFinalRoamStats, ())     
                  
        self.roamStarted = True
            
        scheduler.run()
        
        WaveEngine.OutputstreamHDL("\nStop roaming...\n", WaveEngine.MSG_OK)            
        
        WaveEngine.OutputstreamHDL("\nCreating summary result file...\n", WaveEngine.MSG_OK)
        # collect data for summary result file
        self.__createSummaryResultsFile()
        self.__closeDetailedCsvFiles()
        
        self.roamStarted = False    
           
    def PrintReport(self):
        pass
    
    def SaveSpecialResults(self):
        pass
    
    def run(self):
        if True == self.TimeStampDir:
            timeStr = time.strftime("%Y%m%d-%H%M%S", time.localtime(time.time()))
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, timeStr)
            
        WaveEngine.OpenLogging(Path=self.LoggingDirectory, RSSI=-1, Detailed=-1)
    
        try:
            self.ExitStatus = 0
            self.__sanityCheck()
            self.configurePorts()
            self.__scanForMultipleBssids()
            self.__createRoamingArea()
            self.__createRoamingCircuit()
            self.__initializeCSVFile()
            # TODO: fixed WaveEngine.VerifyBSSID_MAC()
            #self.VerifyBSSID_MAC()
            self.__setClientRoamingOptions()
            # TODO: use self.createClients() in basetest.py
            self.__createClients()
            self.__updateClientsBssid()
            self.__connectClients()
            self.__initiateStunPackets()  
            self.__startTest(self.RealtimeCallback)
            self.SaveResults()
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
            self.SaveResults()
            self.ExitStatus = 2
        except Exception, e:
            # some other error occured
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            try:
                # print out nice traceback and error strings
                msg = "Fatal script error:\n"
                for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                    msg += str(text)
                WaveEngine.OutputstreamHDL(str(msg), WaveEngine.MSG_ERROR)
                WaveEngine.OutputstreamHDL("\nPlease wait while trying to save roam stats\n", WaveEngine.MSG_WARNING)
                for rc in self.roamingCircuitList:
                    WaveEngine.StopRoamingCircuit(rc)
                if 0 < len(self.roamingCircuitList) and True == self.roamStarted:
                    time.sleep(2)
                    self.__saveFinalRoamStats()
            except Exception, e:
                # just incase the exception handler blows up
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1
            
        WaveEngine.DestroyAllClients()
        self.CloseShop()
        return self.ExitStatus
    
    def getInfo(self):
        """
        Returns blurb describing test for use in the GUI.
        """
        Method = """TODO"""
        
        return Method
    
    def getCharts(self):
        """
        Returns dictionary of all chart objects supported by this test.
        { 'Frame Loss [ILOAD=100]': <obj>,
          'Frame Loss [ILOAD=200]': <obj>,
          'Latency [framesize=100, ILOAD=100]': <obj>,
          <chart title>, <chart object> }
        """
        pass
    
    
##################################### Main #####################################
if __name__=='__main__':
    # Commandline execution starts here
    
    # set up options parser.  -h or --help will print usage. 
    usage = "usage: %prog [options] -f FILENAME"
    parser = OptionParser(usage)
    parser.add_option("-f", "--file", dest="filename", 
                    help="read configuration from FILE", metavar="FILE")
    parser.add_option("-q", "--quiet", 
                    action="store_true", dest="quietmode", default=False, 
                    help="don't print status messages to stdout")
    parser.add_option("-s", "--script", 
                    action="store_true", dest="scriptmode", default=False, 
                    help="don't run interactively")
    parser.add_option("-t", "--trials", 
                    action="store", type="int", dest="trials", default=0, 
                    help="override number of trials")
    parser.add_option("-l", "--savelogs", 
                    dest="logs", action="store_true", default=False, 
                    help="save hardware logs after test")
    (options, args) = parser.parse_args()
    # ...args is a list of extra arguments, like a wml config file.
    # options.scriptmode = True/False
    # options.quietmode = True/False
    # options.filename = string
    # options.logs = True/False

    # Create the test
    userTest = Test()
    WaveEngine.SetOutputStream(PrintToConsole)
    if options.filename != None:
        userTest.loadFile(options.filename)
        
    # override options if we need to
    if options.trials:
        userTest.setTrials(options.trials)
    if options.logs:
        userTest.SavePCAPfile = True
    # Run the test
    userTest.run()
    sys.exit(userTest.ExitStatus)

