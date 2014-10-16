#client_thput
#
# Objective: measure the forwarding rate and frame loss at different
#            loads and frames sizes
#
import sys, time, traceback
from basetest2 import *
import WaveEngine
from CommonFunctions import *
from optparse import OptionParser
from vcl import *

class Test( BaseTest2 ):
    def __init__(self):
        BaseTest2.__init__(self)
        ############# Hardware definition ####################
        """
        The CardMap defines the WaveBlade ports that will be available for the test.
        Field Definitions:                                                     
          PortName -    Name given to the specified WaveBlade port. This is a user defined name. 
          ChassisID -   The WT90/20 Chassis DNS name or IP address. Format: 'string' or '0.0.0.0'
          CardNumber -  The WaveBlade card number as given on the Chassis front panel.
          PortNumber -  The WaveBlade port number, should be equal to 0 for current cards. 
          Channel -     WiFi channel number to use on the port. 
          Autonegotiation - Ethernet Autonegotiation mode. Valid values: 'on', 'off', 'forced'.
          Speed -       Ethernet speed setting if not obtained by autonegotiation. Valid values: 10, 100, 1000
          Duplex -      Ethernet Duplex mode if not obtained by autonegotiation. Valid values: 'full', 'half'
        Field Format: dictionary
          For Wifi Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, <Channel> ),
          For Ethernet Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, <autoNegotiation>, <speed>, <duplex> ),
        """
        self.CardMap = { 'WT90_E1': ( 'wt-tga-xx-xx', 1, 0, 'on', 100, 'full' ),
                         'WT90_W1': ( 'wt-tga-xx-xx', 2, 0,  1 ),
                         'WT90_W2': ( 'wt-tga-xx-xx', 3, 0,  4 )
                       }
                            
        
        #self.SourceClients = [ ('ClientEth', 'WT90_E1', '00:00:00:00:00:00', 'DEFAULT', '192.168.50.10', '255.255.255.0', '192.168.50.1', (), Security_None, self.ClientOptions )]
        #self.DestClients   = [ ('ClientUno', 'WT90_W1', '00:00:00:00:00:00', 'DEFAULT', '192.168.50.20', '255.255.255.0', '192.168.50.1', (), Security_None, self.ClientOptions)]

        ################### First Level Test Parameters ##########################
        """
        The parameters in this group need to be set by the user to define the primary
        test configuration. 
        FrameSizeList - List of frame sizes to use in performing the test. This is the
                        primary parameter used in reporting results. Units: bytes 
        Trials -        The number of unique trials to attempt for each combination of the above parameters.
        TransmitTime -  This is the amount of time for a test iteration to execute. RFC2544 recommends a time from
                        30-240 seconds. Units: seconds.
        SettleTime -    Amount of time the test will wait for activity to settle or propagate through the SUT
                        before taking the measurements. RFC2544 recommends 2 seconds.  Units: seconds
        AgingTime -     The number of seconds the DUT/SUT needs to recover between each iteration.  Normally set to
                        zero unless the DUT/SUT resets during the iteration and needs some extra time to recover.
        """
        self.FrameSizeList  = [ 128, 256, 1024 ]
        self.Trials         =  1 
        self.TransmitTime   = 10.0
        self.SettleTime     =  2.0
        self.AgingTime      =  0.0
        
        ##################  Goal Seeking parameters  ##############################
        """
        The goal seeking parameters are used to define how the goal seeking algorithm will arrive at a solution.
        SearchMinimum -           The lower boundry for the goal seeking algorthim.  The algorthim will not search for
                                  values less than this.  Unit is in SUT's frames/second or percent if the last character is a '%'
        SearchMaximum -           The upper boundry for the goal seeking algorthim.  The algorthim will not search for
                                  values higher than this.  The binary search algorithm will use this as the inital value.
                                  If it passed, then the test is complete.  Otherwise the next value is half way between
                                  the SearchMinimum and SearchMaximum.  Unit is in SUT's frames/second or percent if
                                  the last character is a '%'
        SearchResolutionPercent - Determines how precise the search for the final result needs to be. For instance,
                                  a value of 0.1 means that the search will stop if the current result is within 0.1% 
                                  of the previous iteration result. 
        SearchAcceptLossPercent - Determines how much packet loss will be acceptable in seeking the throughput result. 
                                  Ordinarily, throughput is defined as the maximum forwarding rate with zero frame loss.
                                  However, since 802.11 is a lossy medium it may not be possible in some circumstances to
                                  achieve zero frame loss. This parameter can be used in those situations to allow the search
                                  process to obtain the throughput goal. 
        """
        self.SearchMinimum           = None
        self.SearchMaximum           = None
        self.SearchStart             = None
        self.SearchResolutionPercent = 0.1
        self.SearchAcceptLossPercent = 0.0

        ####################### Learning parameters ################################
        """
        These paramters are used to train the DUT/SUT about the clients and flows that are used during the test.   Loss is not
        an issue during learning, only during the actual measurement.
        
        ClientLearningTime - The number of seconds that a Client will flood a DNS request with its source IP address.  This is
                             used to teach the AP about the existance of a client if Security or DHCP is not suffiecient.
        ClientLearningRate - The rate of DNS request the client will learn with in units of frames per second.
        FlowLearningTime   - The number of seconds that the actual test flows will send out learning frames to populate the
                             DUT/SUT forwarding table.  The rate is at the configure test rate. 
        FlowLearningRate   - The rate of flow learning frames are transmitted in units of frames per second.  This should be set
                             lower than the actual offered loads.
        """
        self.ClientLearningTime = 0
        self.ClientLearningRate = 10
        self.FlowLearningTime   = 1
        self.FlowLearningRate   = 100

        ###################### Logging Parameters #################################
        """
        These parameters determine the how the output of the test is to be formed. 
        CSVfilename -       Name of the output file that will contain the primary test results. This file will be in CSV format.
                            This name can include a path as well. Otherwise the file will be placed at the location of the calling
                            program. 
        ReportFilename -    Name of the output file that will contain a formatted report with graphs, explainations, diagrams and
                            the CSV data.  This file is in PDF format. This name can include a path as well. Otherwise the file will
                            be placed at the location of the calling program.
        LoggingDirectory -  Location for putting the remaining test results files.
        SavePCAPfile -      Boolean True/False value. If True a PCAP file will be created containing the detailed frame data that
                            was captured on each WT-20/90 port. 
        DetailedFilename -  Name of the file for capturing the test details. This file will be put in the LoggingDirectory. 
        """
        self.CSVfilename      = 'Results_unicast_throughput.csv'
        self.ReportFilename   = 'Report_unicast_throughput.pdf'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False
        self.DetailedFilename = 'Detailed_unicast_throughput.csv'
        self.RSSIFilename    = 'RSSI_client_thput.csv'

        ####################### Timing parameters ################################
        """
        These parameters will effect the performance of the test. They should only be altered if a specific
        problem is occuring that keeps the test from executing with the DUT. 
        
        BSSIDscanTime -     Amount of time to allow for scanning during the BSSID discovery process. Units: seconds
        AssociateRate -     The rate at which the test will attempt to associate clients with the SUT. This includes the time
                            required to complete .1X authentications. 
                            Units: associations/second. Type: float
        AssociateRetries -  Number of attempts to retry the complete association process for each client in the test.
        AssociateTimeout -  Amount of time the test will wait for a client association to complete before considering iteration
                            a failed connection. Units: seconds; Type: float
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
        """
        self.BSSIDscanTime     =   1.5
        self.AssociateRate     =  10.0
        self.AssociateRetries  =   0
        self.AssociateTimeout  =   5.0
        self.ARPRate           =  10.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0
        self.UpdateInterval    =   0.5
        self.DisplayPrecision  =   3
        #self.testOptions['ContentionProbability']  =   0

        #################  Flow parameters  #################################
        """
        These parameters determine the type of data frames and flows to be used in the test. 
        
        FlowOptions - Dictionary of options used to configure data flows. 
        Field Definitions:
          Type - Packet or frame type. Valid values: 'UDP', 'TCP', 'IP', 'ICMP', 
        """
        self.FlowOptions    = {'Type': 'UDP', 'PhyRate': 54 }
        self.BiDirectional  = False

        ################## Report parameters #################################
        """
        These parameters are used in the PDF report generator to create a table
        with frame sizes and the binary search parameters (min value, max value,
        starting value)
        """
        self.reportMin = []
        self.reportMax = []
        self.reportStart = []
        self.reportResolution = []

########################## DO NOT MODIFY BELOW HERE ##########################
        # Include the version 
        self.version = '$Revision: 1.56 $' 
        self.date    = '$Date: 2007/06/25 23:58:21 $' 
        self.FlowMap        = WaveEngine.CreateFlows_Pairs
    
    def getTestName(self):
        
        return 'client_thput'
    
    def loadData( self, waveChassisStore, wavePortStore, waveClientTableStore,
           waveSecurityStore, waveTestStore, waveTestSpecificStore,
           waveMappingStore, waveBlogStore,wimixTrafficStore,wimixServerStore, clientAnalysisStore ):
        """
        Load dictionary data into test.
        Raise exception on error
        """
        self.wifiCards = []       
        self.ethCards = []  
         
        self.testParameters = odict.OrderedDict()           
        
        self.clientOptions ={}
        self.clientOptions['enableNetworkInterface'] = True
        #self.clientOptions['GratuitousArp'] = "on"
        self.finalGraphs = {}
        
        self.clientGroupTestMode = 0
        
        if 'Mode' in waveClientTableStore:
            self.clientGroupTestMode = int(waveClientTableStore['Mode'])
    	    del waveClientTableStore['Mode']
    	    
        self.waveChassisStore = waveChassisStore
        self.wavePortStore = wavePortStore
        self.waveClientTableStore = waveClientTableStore
        self.waveTestSpecificStore = waveTestSpecificStore
        self.waveBlogStore = waveBlogStore
        self.clientAnalysisStore = clientAnalysisStore
        
        waveMappingStore = [3, [self.waveClientTableStore.keys()[0], ], [self.waveClientTableStore.keys()[1],], 'One To One', 'unidirectional', {'Type' : "UDP", 'PhyRate' : 54.0, 'SourcePort' : 8000, 'DestinationPort' : 8000}, 'infrastructure']
        
        BaseTest2.loadData(self,
                           waveChassisStore, 
                           wavePortStore, 
                           waveClientTableStore, 
                           waveSecurityStore, 
                           waveTestStore, 
                           waveTestSpecificStore, 
                           waveMappingStore, 
                           waveBlogStore)
        
        
        #print "Info in the wimix test..."
        
        #print "\n\nWave Chassis Store"
        #print waveChassisStore
        #print "\n\nWave port Store"
        #print wavePortStore
        #print "\n\nWave Client Store"
        #print waveClientTableStore
        #print "\n\nWave Security Store"
        #print waveSecurityStore
        #print "\n\nWave test Store"
        #print waveTestStore
        #print "\n\nWave Test Specific Store"
        #print waveTestSpecificStore,
        #print "\n\nWave Traffic Store"
        #print wimixTrafficStore
        #print "\n\nWave Server Store"
        #print wimixServerStore
        #print "Blog Store"
        #print waveBlogStore
               
        self.blogPortList = []
        self.monitorPortList = []
        self.dynamicIntScheduleFlag = False
        self.CardMap = dict()
        self.clientList = {}
        self.waveAgentClientList = []
        self.ethClientList = []
        self.FlowList = {}
        self.clientPortDict = {}
        
        for chassis in waveChassisStore.keys():
            for cards in waveChassisStore[chassis].keys():
            	if 'BindStatus' not in waveChassisStore[chassis][cards]:
            	    for prts in waveChassisStore[chassis][cards]:            	    	
            	    	            	    	
                        if waveChassisStore[chassis][cards][prts]['BindStatus'] == "True":
                            if waveChassisStore[chassis][cards][prts]['PortType'] == "8023":
                                cardParamsList = []
                                cardParamsList.append(chassis)
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['CardID']))
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['PortID']))
                                cardParamsList.append(waveChassisStore[chassis][cards][prts]['Autonegotiation'])
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['EthernetSpeed']))
                                cardParamsList.append(waveChassisStore[chassis][cards][prts]['Duplex']) 
                                self.CardMap[waveChassisStore[chassis][cards][prts]['PortName']] = cardParamsList  
                                if waveChassisStore[chassis][cards][prts]['CardMode'] != "MONITOR":
                                    self.ethCards.append(waveChassisStore[chassis][cards][prts]['PortName'])   
                                else:
                                    self.monEthCards.append(waveChassisStore[chassis][cards][prts]['PortName'])                                                      
                            else:
                                cardParamsList = []
                                cardParamsList.append(chassis)
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['CardID']))
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['PortID']))
                                
                                if waveChassisStore[chassis][cards][prts]['Channel'] == "Unknown":
            	    		    WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (prts), WaveEngine.MSG_ERROR)
                                    raise WaveEngine.RaiseException
                                
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['Channel']))  
                                cardParamsList.append(int(waveChassisStore[chassis][cards][prts]['secChannel']))  
                                self.CardMap[waveChassisStore[chassis][cards][prts]['PortName']] = cardParamsList
                                
                                if waveChassisStore[chassis][cards][prts]['CardMode'] == "MONITOR":
                                    self.monWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                elif waveChassisStore[chassis][cards][prts]['CardMode'] == "IG":
                                    self.igWifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName']))   
                                else:
                                    self.wifiCards.append(str(waveChassisStore[chassis][cards][prts]['PortName'])) 
                                     
                                self.secondaryChannelDict[str(waveChassisStore[chassis][cards][prts]['PortName'])] = int(waveChassisStore[chassis][cards][prts]['secChannel'])
                else:
            	    if waveChassisStore[chassis][cards]['BindStatus'] == "True":            	    	
            	    	
                        if waveChassisStore[chassis][cards]['PortType'] == "8023":
                            cardParamsList = []
                            cardParamsList.append(chassis)
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['CardID']))
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['PortID']))
                            cardParamsList.append(waveChassisStore[chassis][cards]['Autonegotiation'])
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['EthernetSpeed']))
                            cardParamsList.append(waveChassisStore[chassis][cards]['Duplex']) 
                            self.CardMap[waveChassisStore[chassis][cards]['PortName']] = cardParamsList  
                            if waveChassisStore[chassis][cards]['CardMode'] != "MONITOR":
                                self.ethCards.append(waveChassisStore[chassis][cards]['PortName'])                     
                        else:
                            cardParamsList = []
                            cardParamsList.append(chassis)
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['CardID']))
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['PortID']))
                            
                            if waveChassisStore[chassis][cards]['Channel'] == "Unknown":
            	    	    	    WaveEngine.OutputstreamHDL("\nChannel for Port %s cannot be Unknown\n" % (cards), WaveEngine.MSG_ERROR)
                                    raise WaveEngine.RaiseException
                            
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['Channel']))  
                            cardParamsList.append(int(waveChassisStore[chassis][cards]['secChannel']))  
                            self.CardMap[waveChassisStore[chassis][cards]['PortName']] = cardParamsList
                            if waveChassisStore[chassis][cards]['CardMode'] != "MONITOR":
                                self.wifiCards.append(str(waveChassisStore[chassis][cards]['PortName'])) 
              
                   
        self.CardList = []
        
        for crd in self.CardMap.keys():
            if crd not in self.blogPortList:
                 self.CardList.append(crd)	
        
        self.serverList = wimixServerStore
        
        
        self.testType = "Client Throughput"        
            
        self.CSVfilename      = 'Results_' + self.testType + '.csv'
        self.CSVOTRfilename   = 'Results_' + self.testType + '_over_time.csv'
        self.ReportFilename   = 'Report_' + self.testType + '.pdf'
        self.DetailedFilename = 'Detailed_Results_' + self.testType + '.csv'
        self.ConsoleLogFileName = "Console_" + self.testType + "_script.html"
        self.TimeLogFileName = "Timelog_" + self.testType + "_script.txt"
        self.RSSILogFileName = "RSSI_" + self.testType + "_script.csv"
                	
                 
        self.clientGroups = {}
        for cltGrps in waveClientTableStore.keys():
            
            grpName = waveClientTableStore[cltGrps]['Name'] 
            self.clientGroups[grpName] = {}
            self.clientGroups[grpName]['enable'] = waveClientTableStore[cltGrps]['Enable']            
            self.clientGroups[grpName]['type'] = waveClientTableStore[cltGrps]['Interface']    
            self.clientGroups[grpName]['portName'] = waveClientTableStore[cltGrps]['PortName']            
            if waveClientTableStore[cltGrps]['Dhcp'] == "Enable":
                self.clientGroups[grpName]['ipMode'] = 0
            elif waveClientTableStore[cltGrps]['Dhcp'] == "Disable":  
            	self.clientGroups[grpName]['ipMode'] = 1
            self.clientGroups[grpName]['ipAddress'] = waveClientTableStore[cltGrps]['BaseIp'] 	
            self.clientGroups[grpName]['gateway'] = waveClientTableStore[cltGrps]['Gateway']  
            self.clientGroups[grpName]['subnetMask'] = waveClientTableStore[cltGrps]['SubnetMask']   
            self.clientGroups[grpName]['BehindNat'] = waveClientTableStore[cltGrps]['BehindNat']
            self.clientGroups[grpName]['NumClients'] = waveClientTableStore[cltGrps]['NumClients'] 
            
            if 'VlanEnable' in waveClientTableStore[cltGrps]:
            	self.clientGroups[grpName]['VlanEnable'] = waveClientTableStore[cltGrps]['VlanEnable']                
            else:
                self.clientGroups[grpName]['VlanEnable'] = False
                
            if 'VlanUserPriority' in waveClientTableStore[cltGrps]:
                self.clientGroups[grpName]['VlanUserPriority'] = int(waveClientTableStore[cltGrps]['VlanUserPriority'])
            else:
                self.clientGroups[grpName]['VlanUserPriority'] = 0
            
            if 'VlanId' in waveClientTableStore[cltGrps]:
                self.clientGroups[grpName]['VlanId'] = int(waveClientTableStore[cltGrps]['VlanId'])
            else:
                self.clientGroups[grpName]['VlanId'] = 0            
                                           
                      
            if waveClientTableStore[cltGrps]['MacAddressMode'] == "Auto":
                self.clientGroups[grpName]['macAddress'] = "AUTO"
            else:
                self.clientGroups[grpName]['macAddress'] = waveClientTableStore[cltGrps]['MacAddress']  	 
        
        self.PortOptions = {}        
        self.PortOptions['ContentionProbability'] = 0
        
         
        self.DUTinfo = {}
        self.labelSplit = "@|#^&"
        
        switchModelStrList = waveTestStore['DutInfo']['WLANSwitchModel'].split(self.labelSplit)
        if len(switchModelStrList) == 1:
            self.DUTinfo['WLAN Switch Model'] = switchModelStrList[0]
        else:
            self.DUTinfo[switchModelStrList[0]] = switchModelStrList[1]
        
        switchSwVerStrList = waveTestStore['DutInfo']['WLANSwitchSWVersion'].split(self.labelSplit)
        if len(switchSwVerStrList) == 1:
            self.DUTinfo['WLAN Switch Version'] = switchSwVerStrList[0]
        else:
            self.DUTinfo[switchSwVerStrList[0]] = switchSwVerStrList[1]
        
        apModelStrList = waveTestStore['DutInfo']['APModel'].split(self.labelSplit)
        if len(apModelStrList) == 1:
            self.DUTinfo['AP Model'] = apModelStrList[0]
        else:
            self.DUTinfo[apModelStrList[0]] = apModelStrList[1]    
        
        apVerStrList = waveTestStore['DutInfo']['APSWVersion'].split(self.labelSplit)
        if len(apVerStrList) == 1:
            self.DUTinfo['AP SW Version'] = apVerStrList[0]
        else:
            self.DUTinfo[apVerStrList[0]] = apVerStrList[1]           
        
        
        #Test results must be stored in the test specific results directory, the directory name is testName
        testName = waveTestSpecificStore.keys()[0]
        
        # set the logging directory
        self.LoggingDirectory = waveTestStore['LogsAndResultsInfo']['LogsDir']
        if waveTestStore['LogsAndResultsInfo'].get('TestNameDir', 'False') == "True":    #Using .get() for backward compatibility with existing wml files which won't have this key
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, self.testDir[testName])
        if waveTestStore['LogsAndResultsInfo']['TimeStampDir'] == "True":
            timeStr = time.strftime("%Y%m%d-%H%M%S", time.localtime(time.time()))
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, timeStr)

        # create the logging directory
        if self.LoggingDirectory != '':
            if not os.path.exists(self.LoggingDirectory):
                try:
                    # create new logging directory
                    os.makedirs(self.LoggingDirectory)
                    if not os.path.exists(self.LoggingDirectory):
                        raise Exception, "Directory was not created."
                except Exception, e:
                    # error creating logging directory
                    msg = "Unable to create logging directory %s.\n%s\n" % ( self.LoggingDirectory, str(e) )
                    raise Exception, msg
        
                        
        if waveTestStore['LogsAndResultsInfo'].get('GeneratePdfReport', 'True') == "True":
            self.generatePdfReportF = True
        else:
            self.generatePdfReportF = False
         
        try:
            if 'client_thput' not in waveTestSpecificStore.keys():
                self.Print("No Test config found\n", 'ERR')
                raise WaveEngine.RaiseException
        except WaveEngine.RaiseException:
            self.Print("WaveEngine terminating the run\n", 'ERR')
            self.CloseShop()
            return -1     	
        
        self._setSearchParams(waveTestSpecificStore, waveTestStore)
        self._setFrameSizeList(waveTestSpecificStore)
        self._loadTrafficMapping(waveMappingStore, waveClientTableStore)
        
        # all good
        return True
        
    def _setSearchParams(self, waveTestSpecificStore, waveTestStore):
        #These are the test specific parameters that get passed down from the 
        #GUI for the test execution 
        #self.SearchResolutionPercent = float(waveTestSpecificStore['client_thput']['SearchResolution'])
        if waveTestSpecificStore['client_thput']['MinSearchValue'] == "Default":
            self.SearchMinimum = None
        else:
            self.SearchMinimum = waveTestSpecificStore['client_thput']['MinSearchValue']
        if waveTestSpecificStore['client_thput']['MaxSearchValue'] == "Default":
            self.SearchMaximum = None
        else:
            self.SearchMaximum = waveTestSpecificStore['client_thput']['MaxSearchValue']
        if waveTestSpecificStore['client_thput']['StartValue'] == "Default":
            self.SearchStart = None
        else:
            self.SearchStart = waveTestSpecificStore['client_thput']['StartValue']
        if waveTestSpecificStore['client_thput']['SearchResolution'] == "Default":
            self.SearchResolutionPercent = None
        else:
            self.SearchResolutionPercent = waveTestSpecificStore['client_thput']['SearchResolution']           
                    
        self.SearchAcceptLossPercent = float(waveTestStore['TestParameters']['LossTolerance'])

    def _setFrameSizeList(self, waveTestSpecificStore):
        frameSizeList = waveTestSpecificStore['client_thput']['FrameSizeList']
        if (len(frameSizeList) != 0):
            self.FrameSizeList = []
            for eachFrameSize in frameSizeList:
                self.FrameSizeList.append(int(eachFrameSize))
    
    def PrintRealtimeStats(self, TXstate, Timeleft, ElapsedTime, PassedParameters):
        TotalTX = 0
        TotalRX = 0
        PktType = PassedParameters['Type'] 
        bpf = PassedParameters['BitsPerFrame']
        for Portname in PassedParameters['CardList']:
            WaveEngine.VCLtest("stats.read('%s')" % (Portname))
            if PktType == 'TCP':
                TotalTX += stats.txTcpFramesOkRate
                TotalRX += stats.rxTcpPacketsOkRate
            elif PktType == 'UDP':
                TotalTX += stats.txUdpFramesOkRate
                TotalRX += stats.rxUdpPacketsOkRate
            else:
                TotalTX += stats.txIpPacketsOkRate
                TotalRX += stats.rxIpPacketsOkRate
        OLOADtext = Float2EngNotation(bpf * TotalTX, self.DisplayPrecision)
        FRtext    = Float2EngNotation(bpf * TotalRX, self.DisplayPrecision)
        # Change pkt/sec to bps per VPR 3030
        WaveEngine.OutputstreamHDL("\r%s OLOAD=%sbps, FR=%sbps, (%2s %4.1f secs)" % 
                                   (PassedParameters['Title'], OLOADtext, FRtext,
                                    TXstate, ElapsedTime), WaveEngine.MSG_OK)
        return True

    def startTest(self, FuncRealTime):
        self.ResultsForCSVfile.append( ('Frame Size', 'Trial', 'Theoretical Throughput pkts/sec', 'Theoretical Throughput bits/sec', 'ILOAD pkts/sec', 'Throughput pkts/sec', 'Throughput bits/sec') )
        PassedParam = {'CardList': self.CardList, 'Type': self.FlowOptions['Type']}
        PassedParam['BitsPerFrame'] = 512
        #self._doFlowLearning(FuncRealTime, PassedParam)
        
        perFlowRateMediumCapCalc = self.getPerFlowRateAndMediumCapacityCalc() 
        
        numberOfAps = self._getNumAPs() 
        
        for eachSize in self.FrameSizeList:
            FrameSize = int(eachSize)
            
            (perFlowRate, flowMultiple, 
             mpduCount, TheoreticalMFR) = perFlowRateMediumCapCalc(FrameSize)
            #flowMultiple = TheoreticalMFR/perFlowRate
            
            if TheoreticalMFR == None:
                raise WaveEngine.TheoreticalMFRCalcException
            
            TheoreticalBPS = 8 * FrameSize * TheoreticalMFR
            
            _minimum, _minimumTheoritic = self._getMinValues(perFlowRate, 
                                                             TheoreticalMFR)
            _maximum, _maximumTheoritic = self._getMaxValues(perFlowRate, 
                                                            TheoreticalMFR)
            _start, _startTheoritic = self._getStartValues(perFlowRate, 
                                                           TheoreticalMFR)
            _resol, _resolTheoritic = self._getResolutionValues(perFlowRate, 
                                                                TheoreticalMFR)

            iload = _start
            newmax = _maximum
            newmin = _minimum
            resolution = _resol
            
            PassedParam['BitsPerFrame'] = 8 * FrameSize
            for TrialNumber in range(1, 1 + self.Trials):

                self._storeBoundaryMetricsForReport(_minimumTheoritic,
                                                 _maximumTheoritic,
                                                 _startTheoritic,
                                                 _resolTheoritic)

                (neverPassed, TputStats) = self._runTrial(FrameSize,
                                                 iload, flowMultiple,
                                                 mpduCount,
                                                 TheoreticalMFR, TheoreticalBPS,
                                                 FuncRealTime, PassedParam,
                                                 newmin, newmax, resolution,
                                                 numberOfAps)

                self._printThisTrialResults(FrameSize, TrialNumber, neverPassed, 
                                            TheoreticalMFR, TheoreticalBPS,
                                            TputStats)
                
                WaveEngine.CheckEthLinkWifiClientState(self.CardList, 
                                                       self.ListOfClients)

    def _getNumAPs(self):
        """
        When traffic is sent from ethernet group as in the cases of 
        (Eth-> wireless) or (Wireless-> Eth and bidirectional) the amount of 
        traffic sent by the eth groups = n * perFlowRate where 'n' is the
        number of AP interfaces i.e., number of APs.
        
        Here we assume every wifi port has one and only one AP. The parties using
        this method should know when this information should be used, e.g.,
        this is expected be of no use when traffic is wirelss to wireless.
        Based on these assumption, it should be safe to assume the number of 
        wifi ports to be equal to the number of APs
        """
        portList = []
        for groupName in self._allEnabledGroups():
            if self.clientgroupObjs[groupName].interface in WaveEngine.WiFiInterfaceTypes:
                portName = self.clientgroupObjs[groupName].portName
                if portName not in portList:
                    portList.append(portName)    
        
        return len(portList)
    
    def _getMinValues(self, perFlowRate, TheoreticalMFR):
        if self.SearchMinimum:
            if isnum(self.SearchMinimum):
                _minimum = float(self.SearchMinimum) / float(len(self.FlowList))
                _minimumTheoritic = _minimum
            else:
                if isnum(self.SearchMinimum[:-1]):
                    _minimum = (float(self.SearchMinimum[:-1]) / 100.0) * (perFlowRate)
                    _minimumTheoritic = (float(self.SearchMinimum[:-1]) / 100.0) * TheoreticalMFR
                else:
                    _minimum = 0.01 * (perFlowRate )
                    _minimumTheoritic = 0.01 * TheoreticalMFR
                    WaveEngine.OutputstreamHDL("Warning: Can not understand minimum rate of '%s', using default.\n" % (self.SearchMinimum), WaveEngine.MSG_WARNING)
        else:
            _minimum = 0.01 * (perFlowRate)
            _minimumTheoritic = 0.01 * TheoreticalMFR
        if _minimum == 0:    # min value can't be 0 fps
            _minimum = 1   
            _minimumTheoritic = TheoreticalMFR 
        
        return  _minimum, _minimumTheoritic
    
    def _getMaxValues(self, perFlowRate, TheoreticalMFR):
        if self.SearchMaximum:
            if isnum(self.SearchMaximum):
                _maximum = float(self.SearchMaximum) / float(len(self.FlowList))
                _maximumTheoritic = _maximum
            else:
                if isnum(self.SearchMaximum[:-1]):
                    _maximum = (float(self.SearchMaximum[:-1]) / 100.0) * (perFlowRate)
                    _maximumTheoritic = (float(self.SearchMaximum[:-1]) / 100.0) * TheoreticalMFR
                else:
                    _maximum = 1.50 * perFlowRate
                    _maximumTheoritic = 1.50 * TheoreticalMFR
                    WaveEngine.OutputstreamHDL("Warning: Can not understand maximum rate of '%s', using default.\n" % (self.SearchMaximum), WaveEngine.MSG_WARNING)
        else:
            # This is changed for VPR 2919 - The DUT was dying if offerered too much traffic
            _maximum =  1.50 * perFlowRate
            _maximumTheoritic = 1.50 * TheoreticalMFR
        
        return _maximum, _maximumTheoritic
    
    def _getStartValues(self, perFlowRate, TheoreticalMFR):
        if self.SearchStart:
            if isnum(self.SearchStart):
                _start = float(self.SearchStart) / len(self.FlowList)
                _startTheoritic = _start
            else:
                if isnum(self.SearchStart[:-1]):
                    _start = (float(self.SearchStart[:-1]) / 100.0) * (perFlowRate )
                    _startTheoritic =  (float(self.SearchStart[:-1]) / 100.0) * (TheoreticalMFR )
                else:
                    _start = 0.50 * (perFlowRate )
                    _startTheoritic = 0.50 * (TheoreticalMFR )
                    WaveEngine.OutputstreamHDL("Warning: Can not understand start value of '%s', using default.\n" % (self.SearchStart), WaveEngine.MSG_WARNING)
        else:                    
            _start = 0.50 *  perFlowRate  # default to 0.5 * Theoritical MFR
            _startTheoritic = 0.50 * TheoreticalMFR
        
        return _start, _startTheoritic
    
    def _getResolutionValues(self, perFlowRate, TheoreticalMFR):
        if self.SearchResolutionPercent:
            if isnum(self.SearchResolutionPercent):
                _resol = float(self.SearchResolutionPercent) / len(self.FlowList)
                _resolTheoritic = _resol
            else:
                if isnum(self.SearchResolutionPercent[:-1]):
                    _resol = (float(self.SearchResolutionPercent[:-1]) / 100.0)
                    if _resol <= 0.0:
                        _resol = 0.00001
                    if _resol > 1.0:
                        _resol = 1.0
                    _resolTheoritic = _resol * TheoreticalMFR
                    _resol = _resol * (perFlowRate)
                else:
                    _resol = 0.05 * (perFlowRate)
                    _resolTheoritic = 0.05 * TheoreticalMFR
                    WaveEngine.OutputstreamHDL("Warning: Can not understand search resolution value of '%s', using default.\n" % (self.SearchStart), WaveEngine.MSG_WARNING)
        else:                    
            _resol = 0.05 * (perFlowRate)    # default to 0.05 * Theoritical MFR                
            _resolTheoritic = 0.05 * TheoreticalMFR
        
        return _resol, _resolTheoritic
    
    def _storeBoundaryMetricsForReport(self,
                                    _minimumTheoritic,
                                    _maximumTheoritic,
                                    _startTheoritic,
                                    _resolTheoritic):
        self.reportMin.append(_minimumTheoritic)

        self.reportMax.append(_maximumTheoritic)

        self.reportStart.append(_startTheoritic)
        
        self.reportResolution.append(_resolTheoritic)
        
    def _runTrial(self,
                  FrameSize, iload, flowMultiple, mpduCount, 
                  TheoreticalMFR, TheoreticalBPS, 
                  FuncRealTime, PassedParam, 
                  newmin, newmax, resolution,
                  numberOfAps ):
        
        neverPassed = True
        delta = 0
        #Set dummy values for the cases when the loop below ends in the first
        #two cases of 'if'. 
        TputStats = {}
        
        while True:
            WaveEngine.WriteDetailedLog(['FrameSize', FrameSize, 
                                         'IntendedRate', iload* flowMultiple])
            
            aggregAppliedLoad = self._applyFlowRate({'PerFlowRate':iload}, 
                                                    FrameSize,
                                                    numMPDUperAMPDU = mpduCount)
            
            WaveEngine.ClearAllCounter(self.CardList)   
                         
            self.writeRSSIinfo()
            
            PassedParam['Title'] = "ILOAD=%sbps," % (Float2EngNotation(8 * FrameSize * aggregAppliedLoad, self.DisplayPrecision))
            
            WaveEngine.OutputstreamHDL("Frame: %d Attempting %.1f pkts/sec\n" % 
            (FrameSize, aggregAppliedLoad), WaveEngine.MSG_OK)
            
            retVal = self._transmitIteration(self.TransmitTime, self.SettleTime,
                                             self.UpdateInterval, "XmitGroup", 
                                             True, FuncRealTime, PassedParam)
            if retVal:
                self.TransmitTime = retVal
            
            FlowStatsDict = self._getOLOADandFR(FrameSize)
            #OLOAD         = FlowStatsDict['OLOAD']
            #OLOAD_bps     = FlowStatsDict['OLOAD bps']
            #FR            = FlowStatsDict['FR']
            #FR_bps        = FlowStatsDict['FR bps']
            #FrameLossRate = FlowStatsDict['FrameLossRate']

            if FlowStatsDict['OLOAD'] == 0:
                WaveEngine.OutputstreamHDL(
                " FAIL (nothing transmitted)\n" , WaveEngine.MSG_WARNING)                  
                delta = (iload - newmin) / 2
                #print "delta: ", delta                            
                if delta < resolution:
                    break
                newmax = iload                          
                iload = iload - delta
                
            elif FlowStatsDict['FrameLossRate'] > self.SearchAcceptLossPercent:
                if FlowStatsDict['FrameLossRate'] > 0.0001:
                    WaveEngine.OutputstreamHDL(" FAIL (loss of %s%%)\n" % 
                    (str(EngNotation2Int(Float2EngNotation(FlowStatsDict['FrameLossRate'], 2)))), WaveEngine.MSG_WARNING)
                else:
                    WaveEngine.OutputstreamHDL(" FAIL (loss less than 0.0001%%)\n", WaveEngine.MSG_WARNING)  
                delta = (iload - newmin) / 2
                #print "delta: ", delta                            
                if delta < resolution:
                    break
                newmax = iload
                iload = iload - delta   
                #print "newmax: ", newmax                    
                                      
            else:
                WaveEngine.OutputstreamHDL(" PASS: Achieved load of %.1f with %s%% loss (%s%% loss tolerance)\n" % 
                        (FlowStatsDict['OLOAD'], (str(EngNotation2Int(Float2EngNotation(FlowStatsDict['FrameLossRate'], 2)))), 
                                (str(EngNotation2Int(Float2EngNotation(self.SearchAcceptLossPercent, 2))))), 
                                WaveEngine.MSG_SUCCESS)
                TputStats = FlowStatsDict.copy()
                TputStats['ILOAD'] = aggregAppliedLoad
                neverPassed = False
                
                delta = (newmax - iload) /2
                #print "delta: ", delta
                if delta < resolution:
                    break
                newmin = iload                            
                iload = iload + delta
                #print "newmin: ", newmin
                
            #print "iload: ", iload 
            #print "resolution: ", resolution    

            # Certain DUT do not like the constant traffic
            if self.AgingTime > 0:
                WaveEngine.Sleep(self.AgingTime, 'DUT/SUT recovery time,')
        
        return (neverPassed, TputStats)

    def _getOLOADandFR(self, FrameSize):
        FlowStatsDict = {}
        # This is a hack since flows counter do not work with less than 64 byte frames
        if FrameSize < 64:
            (OLOAD, OLOAD_bps, FR, FR_bps, FrameLossRate) = \
            WaveEngine.MeasurePort_OLOAD_FR_LOSSRate(self.CardList, 
                                                     self.TransmitTime, 
                                                     self.FlowOptions['Type'],
                                                     FrameSize)
            FlowStatsDict['OLOAD']         = OLOAD
            FlowStatsDict['OLOAD bps']     = OLOAD_bps
            FlowStatsDict['FR']            = FR
            FlowStatsDict['FR bps']        = FR_bps
            FlowStatsDict['FrameLossRate'] = FrameLossRate
        else:
            FlowStatsDict = WaveEngine.MeasureFlow_Statistics(self.FlowList, 
                                                              self.TransmitTime,
                                                              FrameSize)
        return FlowStatsDict 
    
    def _printThisTrialResults(self, 
                                   FrameSize, TrialNumber, neverPassed, 
                                   TheoreticalMFR, TheoreticalBPS,
                                   TputStats):
                                   # MaxILOAD, Tput, TputBPS):
        # Print results for that frame size
        if neverPassed == True:
            self.ResultsForCSVfile.append( (FrameSize, TrialNumber , 
                                            int(TheoreticalMFR), 
                                            int(TheoreticalBPS), 
                                            0, 0, 0 ) )
            WaveEngine.OutputstreamHDL("Error: Framesize=%d failed every pass. No throughput measurement.\n" % 
                                      (int(FrameSize)), WaveEngine.MSG_ERROR)
        else:
            self.ResultsForCSVfile.append( (FrameSize, TrialNumber, 
                                            int(TheoreticalMFR), 
                                            int(TheoreticalBPS), 
                                            TputStats['ILOAD'], TputStats['OLOAD'], TputStats['OLOAD bps'] ) )
            WaveEngine.OutputstreamHDL("Completed: Throughput for %d byte packets is %.1f pkts/sec (or %s bits/sec)\n" % 
            (int(FrameSize), TputStats['OLOAD'], Float2EngNotation(TputStats['OLOAD bps'], self.DisplayPrecision)), WaveEngine.MSG_SUCCESS)
            if TputStats.has_key('Min Latency'):
                WaveEngine.OutputstreamHDL("           Latency: min = %sS max = %sS avg = %sS, Jitter = %sS\n" %
                  ( Float2EngNotation(TputStats['Min Latency'], self.DisplayPrecision),
                    Float2EngNotation(TputStats['Max Latency'], self.DisplayPrecision),
                    Float2EngNotation(TputStats['Avg Latency'], self.DisplayPrecision),
                    Float2EngNotation(TputStats['Avg Jitter'], self.DisplayPrecision)), WaveEngine.MSG_SUCCESS)

    def PrintReport(self):
        import os.path
        
        Results = self._getResults()

        # Text Strings

        MyReport = WaveReport(os.path.join(self.LoggingDirectory, 
                                           self.ReportFilename))
        if MyReport.Story == None:
            # Reportlab is not installed, no use creating a file
            return

        self._insertTitleAndOverview(MyReport)
    
        self._insertMeasuredThroughputGraph(MyReport, Results)
        
        self._insertTestConditions(MyReport)
        
        self._insertMethodology(MyReport)

        self._insertDetailedResults(MyReport, Results)

        self.insertAPinfoTable(RSSIfileName = self.RSSIFilename ,
                               reportObject = MyReport)

        self._insertOtherTestParamsInfo(MyReport)
        
        # generate output
        MyReport.Print()
    
    def _getResults(self):
        #Strip off the DUT info
        Results = []
        flag = False
        for line in self.ResultsForCSVfile:
            if flag:
                Results.append(line)
            if len(line) == 0:
                flag = True
        
        return Results
    
    def _insertTitleAndOverview(self, MyReport):
        OverviewText1 = """The throughput test measures a key performance metric: the maximum rate at which frames can be injected into the system under test (SUT) without exceeding a pre-set loss threshold. If the loss threshold is zero, this corresponds to the classical definition of throughput as per RFC 1242."""
        
        OverviewText2 = """Throughput is very important in assessing performance under higher-layer protocols such as TCP, where even small amounts of loss can significantly impact user applications."""

        MyReport.Title( "Unicast Throughput Report", self.DUTinfo, self.TestID )
        MyReport.InsertHeader( "Overview" )
        MyReport.InsertParagraph( OverviewText1 )
        MyReport.InsertParagraph( OverviewText2 )
        
    def _insertMeasuredThroughputGraph(self, MyReport, Results):
        TputText1 = """The following graph summarizes the measured throughput performance of the SUT at the specified frame sizes in bytes. Higher values indicate better overall performance."""
        
        TputText2 = """The theoretical throughput of the system, as limited by the physical media, is also indicated on the above graph. The SUT throughput should ideally be as close as possible to the indicated theoretical throughput values. NOTE: For 11n clients the theoretical maximum assumes the Best Effort AC, AIFSn of 2, and ECWMin of 4."""

        MyReport.InsertHeader( "Measured Throughput" )
        MyReport.InsertParagraph( TputText1 )
        if self._anyUserSpecifiedTheoreticals():
            userSpecifedRatesText = "<i>At least one of the Medium Capacity values shown is user specified</i>"
            MyReport.InsertParagraph( userSpecifedRatesText )
        MyReport.InsertObject( self.CreateThroughputGraph( Results,
                                                           GraphWidth = 5.5 * inch,
                                                           GraphHeight = 2.25 * inch ) )
        MyReport.InsertParagraph( TputText2 )
       
        #MyReport.InsertPageBreak()
        
    def _insertTestConditions(self, MyReport):
        MyReport.InsertHeader( "Test Conditions" )
        
        self._insertConfigParamsInfoTable(MyReport)
                
        self._insertTestTopology(MyReport)
         
        self._insertPortCountInfo(MyReport)        

        self._insertClientConfiguration(MyReport)
        
    def _insertConfigParamsInfoTable(self, MyReport):
        ConfigParameters = [ ( 'Parameter', 'Value', 'Description' ),
                             ( 'Frame Sizes', str( self.FrameSizeList ), "Frame sizes in bytes" ) ]
        MyReport.InsertParameterTable( ConfigParameters, columns = [ 1.25*inch, 3.0*inch, 1.75*inch ] ) # 6-inch total

        MyReport.InsertHeader("Test Configuration")

        _minText = "Lower limit of aggregate ILOAD offered to the SUT"
        
        isFps = False
        if self.SearchMinimum:
            if isnum(self.SearchMinimum):
                isFps = True
                _minimum = "%.0f fps" % (float(self.SearchMinimum))
            else:
                if isnum(self.SearchMinimum[:-1]):
                    _minimum = "%.1f%%" % (float(self.SearchMinimum[:-1]))
                else:
                    _minimum = "1%"
                _minText = "Lower limit of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput"
        else:
            _minimum = "1%"
            _minText = "Lower limit of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput"
            
        _maxText = "Upper limit of aggregate ILOAD offered to the SUT"
        if self.SearchMaximum:
            if isnum(self.SearchMaximum):
                _maximum = "%.0f fps" % (float(self.SearchMaximum))
            else:
                if isnum(self.SearchMaximum[:-1]):
                    _maximum = "%.1f%%" % ( float(self.SearchMaximum[:-1]) )
                else:
                    _maximum = "150%"
                _maxText = "Upper limit of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput"
        else:
            _maximum = "150%"
            _maxText = "Upper limit of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput"
                            
        _startText = "Initial value of aggregate ILOAD offered to the SUT"             
        if self.SearchStart:
            if isnum(self.SearchStart):
                _start = "%.0f fps" % (float(self.SearchStart))
            else:
                if isnum(self.SearchStart[:-1]):
                    _start = "%.1f%%" % (float(self.SearchStart[:-1]))
                else:
                    _start = "50%"
                _startText = "Initial value of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput" 
        else: 
            _start = "50%"  
            _startText = "Initial value of aggregate ILOAD offered to the SUT, in percent of theoretical maximum throughput" 
            
        _resolText = "Granularity of measured values"  
        if self.SearchResolutionPercent:
            if isnum(self.SearchResolutionPercent):
                _resol = "%.0f fps" % (float(self.SearchResolutionPercent))
            else:
                _resolText = "Granularity of measured values, in percent of theoretical maximum throughput"
                if isnum(self.SearchResolutionPercent[:-1]):
                    _resol = "%.1f%%" % (float(self.SearchResolutionPercent[:-1]))         
                else:
                    _resol = "5%"
        else:                    
            _resol = "5%"
            _resolText = "Granularity of measured values, in percent of theoretical maximum throughput"
            
        ConfigParamters = [ ( 'Parameter', 'Value', 'Description'),
                            ( 'Learning Time', "%d sec" % ( self.FlowLearningTime ), "Transmission time (seconds) for initial learning packets, to allow the SUT to set up forwarding tables" ),
                            ( 'Achieved Transmit Time', "%0.2f sec" % ( self.TransmitTime ), "Trial duration (seconds) - i.e., duration of test traffic" ),
                            ( 'Settle Time', "%d sec" % ( self.SettleTime ), "Idle time after test traffic transmission completes" ),
                            ( 'Aging Time', "%d sec" % ( self.AgingTime ), "Time allowed for the SUT to recover between iterations" ),
                            ( 'Number of Trials', "%d" % ( self.Trials ), "Number of times measurements are repeated for averaging" ),
                            ( 'Search Minimum', _minimum, _minText ),
                            ( 'Search Maximum', _maximum, _maxText ),
                            ( 'Starting Point', _start, _startText ),                            
                            ( 'Search Resolution', _resol, _resolText),
                            ( 'Acceptable Loss', "%s%%" % ( str( EngNotation2Int( Float2EngNotation( float( self.SearchAcceptLossPercent ), 2 ) ) ) ), "Frame loss threshold used when determining throughput" )
                            ]
        
        if self.testOptions['ContentionProbability'] > 0:
            ConfigParamters.append( ('Client Contention', 'ON', 'This enbles 2 or more clients to simultaneously attempt access to the media which results in CRC errored frames.'), )
        MyReport.InsertParameterTable(ConfigParamters, columns=[1.5*inch, 1.25*inch, 3.25*inch])
        if isFps == False: 
            MyReport.InsertHeader("Binary Search Options")
            MyReport.InsertParagraph("The maximum, minimum, starting point and search resolution of aggregate ILOAD values are calculated in percent of the theoretical maximum frame rate for the particular frame size. Please refer to the Test Configuration table for the percent values.")
            BinSearchParams = [('Frame Sizes', 'Search Max (fps)', 'Search Min (fps)', 'Start Point (fps)', 'Search Resolution (fps)')]
            for a,b,c,d,e in zip(self.FrameSizeList, self.reportMax, self.reportMin, self.reportStart, self.reportResolution):
                BinSearchParams.append((a,b,c,d,e))
            MyReport.InsertDetailedTable(BinSearchParams, columns=[1.2*inch, 1.2*inch, 1.2*inch, 1.2*inch, 1.2*inch]) 
            #MyReport.InsertPageBreak()

    def _insertTestTopology(self, MyReport):
        Topology = """The test topology is shown below. Traffic is transmitted in the direction of the arrows. The test client port identifiers and IP addresses are indicated in the boxes, together with the security mode and channel ID for WLAN clients."""
        MyReport.InsertHeader( "Test Topology" )
        MyReport.InsertParagraph( Topology )
        MyReport.InsertClientMap( self.SourceClients, self.DestClients, self.BiDirectional, self.CardMap )

    def _insertPortCountInfo(self, MyReport):
        # count ports used in client lists
        portlist = []
        for eachClient in self.SourceClients + self.DestClients:
            port = eachClient[ 1 ] # extract portname from client tuple
            if port not in portlist:
                portlist.append( port )
        numPorts = len( portlist )
        MyReport.InsertParagraph( "A total of %d ports were used in this test." % numPorts )
        #MyReport.InsertPageBreak()

    def _insertClientConfiguration(self, MyReport):
        # Add Client configuration table - THC
        MyReport.InsertHeader( "Client Configuration" )
        cgConfigParams = [ ( 'Client Group', 'PHY Type', 'PHY Rate (Mbps)', 'MCS', 'A-MPDU', 'Port' ) ]
        # Distill client group names from client lists
        clientGroupList = []
        allClientList = self.SourceClients + self.DestClients
        allClientList.sort()
        for eachClient in allClientList:
            clientGroupName = eachClient[ 0 ]
            if clientGroupName not in clientGroupList:
                clientGroupList.append( clientGroupName )

        for clientGroup in clientGroupList:
            propertiesForTTobject = self.clientgroupObjs[clientGroup].propertiesForTTobject

            groupPortName = propertiesForTTobject['portName']
            phyType = propertiesForTTobject['phyType']
            if phyType == 'Ethernet':
                mcsIndex = 'N/A'
                ampduEnabled = 'N/A'
                phyRate = propertiesForTTobject['linkSpeed']
            elif phyType == '11n':
                mcsIndex = propertiesForTTobject['dataMcsIndex'] 
                phyRate = WaveEngine.get11nPhyRate( int(mcsIndex), 
                                                    propertiesForTTobject['guardInterval'],
                                                    int(propertiesForTTobject['channelBandwidth']))    
                if propertiesForTTobject['EnableAMPDUaggregation'] == 'True':
                    ampduEnabled = 'On'
                else:
                    ampduEnabled = 'Off'
            else:
                mcsIndex = 'N/A'
                ampduEnabled = 'N/A'
                phyRate = str( propertiesForTTobject['dataPhyRate'] )

            # After gathering all the data, append the row to the table
            cgConfigParams.append( (clientGroup, phyType, phyRate, mcsIndex, ampduEnabled, groupPortName) )

        MyReport.InsertDetailedTable(cgConfigParams, columns=[ 1*inch, 
                                                               1*inch, 
                                                               1.25*inch, 
                                                               0.5*inch,
                                                               0.75*inch,
                                                               1.5*inch])
        

    def _insertMethodology(self, MyReport):
        Method1 = """The test is performed by associating test clients with the SUT ports, performing any desired learning transmissions, and then generating test traffic between the test clients. The test then calculates throughput according to the procedure specified in RFC 2544. Proprietary signatures and tags are inserted into the test traffic to ensure accurate measurement results."""
        
        Method2 = """A binary search algorithm is used to obtain the throughput, by finding the ILOAD resulting in the highest forwarding rate for which the packet loss ratio is less than the acceptable threshold. The Search Maximum and Search Minimum parameters may be used to constrain the search algorithm. The Starting Point is the starting value of the offered load and its value must be greater or equal to the Search Minimum and less than or equal to the Search Maximum. By default, the search algorithm will start at 50% of the theoretical throughput calculated for the test topology."""
        
        Method3 = """The test is repeated for each frame size, and also if the number of trials is greater than 1. The results are recorded separately for each combination of frame size and trial number, as well as being averaged into the graphs shown above."""

        MyReport.InsertHeader( "Methodology" )
        MyReport.InsertParagraph( Method1 )
        MyReport.InsertParagraph( Method2 )
        MyReport.InsertParagraph( Method3 )
        MyReport.InsertPageBreak()
    
    def _insertDetailedResults(self, MyReport, Results):
        MyReport.InsertHeader( "Detailed Results" )
        MyReport.InsertDetailedTable( Results, columns = [ 0.5*inch,
                                                           0.5*inch,
                                                           1.0*inch,
                                                           1.0*inch,
                                                           1.0*inch,
                                                           1.0*inch,
                                                           1.0*inch ] )
    
    def _insertOtherTestParamsInfo(self, MyReport):
        MyReport.InsertHeader( "Other Info" )
        OtherParameters = []
        OtherParameters.append( ( 'Results Directory',  str( self.LoggingDirectory ) )  )
        for item in self.OtherInfoData.items():
            OtherParameters.append( item )
        OtherParameters.append( ( 'WaveTest Version',   str( action.getVclVersionStr() ) ) )
        MyReport.InsertGenericTable( OtherParameters , columns = [ 1.5*inch, 4.5*inch ] )
    
    
    def connectWimixPorts(self, CardList, CardMap, portOptions): 
    	#self.isTestEnabled()   	            
        WaveEngine.ConnectPorts(CardList, CardMap, portOptions)
        WaveEngine.PortEnableFeature(CardList)  
    
    
    
    def createTestClients(self):               
    	for grpName in self.clientGroups:
    	    prt =  self.clientGroups[grpName]['portName']
    	    
            mac_addr = self.clientGroups[grpName]['macAddress']            
            ip_addr = self.clientGroups[grpName]['ipAddress']
                
    	    netmask = self.clientGroups[grpName]['subnetMask'] 
    	    gateway = self.clientGroups[grpName]['gateway']
                      
            clientOptions ={}
            if self.clientGroups[grpName]['type'] != "WaveAgent":            
                clientOptions['enableNetworkInterface'] = True
            
    	    clientData = [(grpName, prt, '00:00:00:00:00:00', mac_addr, ip_addr, netmask, gateway, (1, "AUTO", '0.0.0.1'), {'Method': 'NONE'}, clientOptions)]
            cl_dict = WaveEngine.CreateClients(clientData)
                        
            self.clientPortDict[grpName] = prt
            
            if self.clientGroups[grpName]['type'] != "WaveAgent":
                for kys in cl_dict.keys():
                    self.clientList[kys] = cl_dict[kys]                
                self.ethClientList.append(grpName)
            else:
                self.waveAgentClientList.append(grpName)
    
    def configureDataFlows(self):
        
        dir = "source"
        srcPort = 8000
        dstPort= 8000
        
        for ii in range(len(self.waveAgentClientList)):
            eClName = self.ethClientList[ii]
            wClName = self.waveAgentClientList[ii]
            
            if dir == "source":
                srcClient = wClName
                dstClient = eClName
            else:
                srcClient = eClName
                dstClient = wClName                
            
            FlowName = "F_%s-->%s" % (srcClient, dstClient)           
            WaveEngine.VCLtest("flow.create('%s')"       % (FlowName))
            WaveEngine.VCLtest("flow.setSrcClient('%s')"  % (srcClient))
            WaveEngine.VCLtest("flow.setDestClient('%s')" % (dstClient))
            WaveEngine.VCLtest("flow.setType('%s')" % ("UDP"))
            WaveEngine.VCLtest("flow.setIntendedRate(%f)" % 1000.0)
            WaveEngine.VCLtest("flow.setFrameSize(%d)" % 1518)
            WaveEngine.VCLtest("flow.setInsertSignature('on')")
            WaveEngine.VCLtest("flow.setNumFrames(%d)" % (4000000))  
            
            WaveEngine.VCLtest("udp.readFlow()")
            WaveEngine.VCLtest("udp.setSrcPort(%d)" % (srcPort) )
            WaveEngine.VCLtest("udp.setDestPort(%d)" % (dstPort) )
            WaveEngine.VCLtest("udp.modifyFlow()")        
            
            WaveEngine.VCLtest("flow.write('%s')"        % (FlowName))
            
            self.FlowList[FlowName] = ( self.clientPortDict[srcClient], srcClient, self.clientPortDict[dstClient], dstClient )
            
    def doArpExchange(self):  
    	return WaveEngine.ExchangeARP(self.FlowList, "arpFlows", self.ARPRate, self.ARPRetries, self.ARPTimeout)        
                    
    
    def run(self):
        # For debuging reports
        #self.LoggingDirectory = "/home/keith/Veriwave/WaveApps/Results/20060322-131618"
        #self.ReadResults()
        #self.PrintReport()
        #return
    
        #Configure the test which includes configure chassid,ports,create clients and create flows (Configure Stage)
        #Setup the clients which includes connect clients,ARP and DHCP
        WaveEngine.OpenLogging(Path=self.LoggingDirectory, Detailed=self.DetailedFilename)

        try:
            self.ExitStatus = 0
            #self.configurePorts()
            self.initailizeCSVfile()
            
            WaveEngine.OpenLogging(Path=self.LoggingDirectory, Timelog = self.TimeLogFileName, Console = self.ConsoleLogFileName, RSSI = self.RSSILogFileName, Detailed = self.DetailedFilename)   	         	
    	    chassisName = self.CardMap[self.CardMap.keys()[0]][0]
            
    	    WaveEngine.VCLtest("chassis.connect('%s')" % chassisName)
            
    	    WaveEngine.OutputstreamHDL("WaveEngine Version %s\n" % WaveEngine.full_version, WaveEngine.MSG_OK)
            WaveEngine.OutputstreamHDL("Framework Version %s\n" % WaveEngine.action.getVclVersionStr(), WaveEngine.MSG_OK)
            WaveEngine.OutputstreamHDL("Firmware Version %s\n\n\n" % chassis.version, WaveEngine.MSG_OK)
    	            
    	    WaveEngine.VCLtest("chassis.disconnect('%s')" % chassisName)
            
            self.connectWimixPorts(self.CardList, self.CardMap, self.PortOptions) 
    	    
            if WaveEngine.WaitforEthernetLink(self.CardList) == -1:
                raise WaveEngine.RaiseException
                        
            WaveEngine.ClearAllCounter(self.CardList)
            
            self.createTestClients()  
            
            self.ListOfClients = self.clientList
            self.TotalClients  = len(self.ListOfClients)
            self.AssociateRetries = 10            
            self.connectClients()
            
            self.configureDataFlows()            
            self.doArpExchange()           
            self._createFlowGroup(self.FlowList, "XmitGroup")
            
            #raise WaveEngine.RaiseException
            #return         
            
            
            
            self.startTest(self.RealtimeCallback)
            self.SaveResults()
            if self.generatePdfReportF:
                self.PrintReport()
            #Update the csv results, pdf charts (if opted by the user) in the GUI
            #'Results' page
            self.updateGUIresultsPage()    
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
            self.ExitStatus = 2
            self.SaveResults()
        except Exception, e:
            # some other error occured
            (exc_type, exc_value, exc_tb) = sys.exc_info()
            try:
                # print out nice traceback and error strings
                msg = "Fatal script error:\n"
                for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                    msg += str(text)
                WaveEngine.OutputstreamHDL(str(msg), WaveEngine.MSG_ERROR)
            except Exception, e:
                # just incase the exception handler blows up
                print "ERROR:\n%s\n%s\n" % (str(msg), str(e))
            self.ExitStatus = 1
        self.CloseShop()
        return self.ExitStatus
            
    def getInfo(self):
        """
        Returns blurb describing test for use in the GUI.
        """
        msg =  """The Throughput Benchmarking test identifies the maximum rate at which the system under test (SUT) can forward packets without loss. 

This test determines the throughput rate by using a binary search algorithm. The test starts by offering a predetermined starting load to the SUT. Packet loss is then measured. If packet loss is detected the offered load (OLOAD) is cut in half. If there is no packet loss the OLOAD is doubled. This process continues until the difference between OLOAD values is less than the search resolution setting. The process is repeated for each frame size specified in the test."""
        return msg

    def getCharts(self):
        """
        Returns dictionary of all chart objects supported by this test.
        """
        
        # strip off irrelevant headings
        results = []
        flag = False
        for line in self.ResultsForCSVfile:
            if flag:
                results.append(line)
            if len(line) == 0:
                flag = True
        # create charts
        charts = {}
        c = self.CreateThroughputGraph( results )
        t = c.title
        charts[ t ] = c
        
        return charts

################################### Flowables #################################
# These are unique objects that a placed in the Report.PDF file.
    def CreateThroughputGraph( self, Resultdata, GraphWidth = None, GraphHeight = None ):
        if not GraphWidth: GraphWidth  = 6.0 * inch
        if not GraphHeight: GraphHeight = 3.5 * inch

        #Extract the data from the CSV file
        _ExtractedData= {}
        for eachLine in Resultdata:
            if len(eachLine) != 7:
                continue
            (FrameSize, Trial, Theroy_FPS, Theroy_BPS, ILOAD_FPS, OLOAD_FPS, OLOAD_BPS) = eachLine
            if not isnum(FrameSize):
                continue
            if _ExtractedData.has_key(FrameSize):
                (m,n, TotalOLOAD_FPS, TotalOLOAD_BPS, Count) = _ExtractedData[FrameSize]
                _ExtractedData[FrameSize] = (Theroy_FPS, Theroy_BPS, TotalOLOAD_FPS + OLOAD_FPS, TotalOLOAD_BPS + OLOAD_BPS, Count + 1)
            else:
                 _ExtractedData[FrameSize] = (Theroy_FPS, Theroy_BPS, OLOAD_FPS, OLOAD_BPS, 1)
        FrameSizeList = _ExtractedData.keys()
        FrameSizeList.sort()
       
        graphTitle = "Throughput vs. Frame size"
       
        FrameSizeData = ()
        FrameSizeTheory = ()
        FrameSizeName = []
        for eachFrameSize in FrameSizeList:
            (Theroy_FPS, Theroy_BPS, TotalOLOAD_FPS, TotalOLOAD_BPS, Count) = _ExtractedData[eachFrameSize]
            OLOAD_Mbps  = TotalOLOAD_BPS  / (int(Count) * 1000000.0)
            Theroy_Mbps = Theroy_BPS / 1000000.0
            FrameSizeData   += (OLOAD_Mbps, )
            FrameSizeTheory += (Theroy_Mbps, )
            FrameSizeName.append(str(eachFrameSize))
        return self.ThroughputGraph(GraphWidth, GraphHeight, FrameSizeName, [FrameSizeTheory, ], [FrameSizeData, ], graphTitle)

    class ThroughputGraph(FlowableGraph):
        def __init__(self, width, height, names, line, bar, title):
            FlowableGraph.__init__(self, width, height)
            self.dataNames = names
            self.dataLine  = line
            self.dataBar   = bar
            self.offset    = (defaultPageSize[0] - 2 * inch - width) / 2.0
            self.title     = title

        def _rawDraw(self, x, y):
            from reportlab.lib import colors 
            from reportlab.graphics.shapes import Drawing, Line, String, STATE_DEFAULTS
            from reportlab.graphics.charts.linecharts import HorizontalLineChart, Label
            from reportlab.graphics.charts.barcharts  import VerticalBarChart
            from reportlab.graphics.widgets.markers import makeMarker
            self.originX = x
            self.originY = y
            self._setScale([self.dataLine, self.dataBar])
            (x1, y1, Width, Height) = self._getGraphRegion(x, y)

            #Build the graph
            self.drawing = Drawing(self.width, self.height)

            #Size of the Axis
            SizeXaxis = 14
            SizeYaxis = 0.0
            for n in range(int(self.valueMax / self.valueStep) + 1):
                eachValue = self.valueMin + n * self.valueStep
                SizeYaxis = max(SizeYaxis, self._stringWidth(str("%.1f Mbps" % eachValue), STATE_DEFAULTS['fontName'], STATE_DEFAULTS['fontSize']) )

            bc = VerticalBarChart()
            SizeYaxis += bc.valueAxis.tickLeft
            bc.y = y1 - y + SizeXaxis
            bc.height = Height - SizeXaxis - 20 # padding for legend
            self.graphCenterY = bc.y + bc.height/2
            if self.validData:
                # add valid data
                bc.x = x1 - x + SizeYaxis
                bc.width  = Width  - SizeYaxis
                bc.data = self.dataBar
                bc.categoryAxis.categoryNames = self.dataNames
                # axis values
                bc.valueAxis.valueMin  = self.valueMin
                bc.valueAxis.valueMax  = self.valueMax
                bc.valueAxis.valueStep = self.valueStep
                self.graphCenterX = bc.x + bc.width/2
                # add value labels above bars
                bc.barLabelFormat = "%.2f"
                bc.barLabels.dy = 0.08*inch
                bc.barLabels.fontSize = 6
            else:
                # no valid data
                SizeYaxis = 16
                bc.x = x1 - x + SizeYaxis
                bc.width  = Width  - SizeYaxis
                self.graphCenterX = bc.x + bc.width/2
                bc.data = [ (0, ), ]
                bc.categoryAxis.categoryNames = [ '' ]
                bc.valueAxis.valueMin  = 0
                bc.valueAxis.valueMax  = 1
                bc.valueAxis.valueStep = 1
                Nodata = Label()
                Nodata.fontSize = 12
                Nodata.angle = 0
                Nodata.boxAnchor = 'c'
                Nodata.dx = self.graphCenterX
                Nodata.dy = self.graphCenterY
                Nodata.setText("NO VALID DATA")
                self.drawing.add(Nodata)
                
            # chart formatting
            (R,G,B) = VeriwaveYellow
            bc.bars[0].fillColor   = colors.Color(R,G,B)
            bc.valueAxis.labelTextFormat = "%.1f Mbps"
            bc.categoryAxis.labels.boxAnchor = 'ne'
            bc.categoryAxis.labels.dx = 8
            bc.categoryAxis.labels.dy = -2
            bc.categoryAxis.labels.angle = 0
            # add chart
            self.drawing.add(bc)

            # Add Legend in upper right corner
            legendHeight  = 9 
            legendX = bc.x + 5
            legendY = bc.y + bc.height + 2 * legendHeight
            self.drawing.add(Line(legendX, legendY + 3 , legendX + 20, legendY + 3, strokeColor=bc.bars[0].fillColor, strokeWidth=3 ))
            self.drawing.add(String(legendX + 22, legendY, 'Measured', fontName='Helvetica', fontSize=8))
            legendY -= legendHeight

            # FIXME - Keith wants number on top of the bars
            self._drawLabels(self.title, "Frame Size", "")

            if self.validData and len(self.dataLine[0]) > 0:
                DashArray = [2,2]
                # add horizontal line if only one datapoint
                if len(self.dataLine[0]) == 1:
                    yPos = bc.height * (self.dataLine[0][0] - bc.valueAxis.valueMin) / (bc.valueAxis.valueMax - bc.valueAxis.valueMin)
                    self.drawing.add(Line(bc.x, bc.y + yPos, bc.x + bc.width, bc.y + yPos, strokeColor=colors.blue, strokeWidth=1, strokeDashArray = DashArray))
                # theoretical line
                lc = HorizontalLineChart()    
                lc.x = bc.x
                lc.y = bc.y
                lc.height = bc.height
                lc.width  = bc.width
                lc.valueAxis.valueMin  = self.valueMin
                lc.valueAxis.valueMax  = self.valueMax
                lc.valueAxis.valueStep = self.valueStep
                lc.valueAxis.visible   = False
                lc.data = self.dataLine
                # line format
                lc.lines[0].strokeColor = colors.blue
                lc.lines[0].strokeDashArray = DashArray
                lc.lines[0].symbol = makeMarker('FilledDiamond')
                lc.joinedLines = 1
                self.drawing.add(lc)
                    
                # legend
                self.drawing.add(Line(legendX, legendY + 3, legendX + 20 , legendY + 3, strokeColor=colors.blue, strokeWidth=1, strokeDashArray = DashArray))
                self.drawing.add(String(legendX + 22, legendY, 'Medium Capacity', fontName='Helvetica', fontSize=8))
                legendY -= legendHeight
            # all done
            

##################################### Main ###################################
if __name__=='__main__':
    # Commandline execution starts here
        
    # set up options parser.  -h or --help will print usage.
    usage = "usage: %prog [options] -f FILENAME"
    parser = OptionParser( usage )
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
        userTest.loadFile( options.filename )
        
    # override options if we need to
    if options.trials:
        userTest.setTrials( options.trials )
    if options.logs:
        userTest.SavePCAPfile = True
    # Run the test
    userTest.run()
    sys.exit(userTest.ExitStatus)
