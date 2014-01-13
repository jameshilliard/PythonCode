import copy
import odict
import WaveEngine as WE
import random
import sched
import time
import CommonFunctions as CF

class RoamBenchCommon:
    """
    This class contains attributes common to roam benchmark based tests (for now they are
    'roaming benchmark' and 'voip roaming')
    """
    def getTestEthPortList(self):
        #Collect the card list on which Eth groups  exist
        #self.nonRoamGroups is now (release 2.4) Eth groups only, it was created when
        #the app design included wlan group which would be stationary (i.e., not roam)
        ethPorts = []
        for groupName in self.nonRoamGroups.keys():
            groupProperties = self.nonRoamGroups[groupName]
            #Why check if the value is 'True' (below), VPR 4541, when going through command line, 
            #the data structure passed contains Enable: 'True' but in gui its passed as expected
            #Enable: True
            if groupProperties['Enable'] in ['True', True]:    
                if groupProperties['Interface'] == '802.3 Ethernet':
                    portName = groupProperties['Port']
                    ethPorts.append(portName)            #Used for W.E.WaitforEthernetLink() below
        return ethPorts
    
    def roamGroups(self, waveClientTableStore):
        enabledWlanGroups  = self.wlanGroups(waveClientTableStore)
        roamGroups = []
        for groupName in enabledWlanGroups:
            if waveClientTableStore[groupName]['PortName'] == 'Roam':
                roamGroups.append(groupName)
        return roamGroups
    
    def getSecProfile(self, cgDetails, securityStore):
        cgName = cgDetails['Name']
        ssid = 'None'
        if 'Ssid' in cgDetails.keys():
            ssid = cgDetails['Ssid']
        bssid = 'None'
        if 'Bssid' in cgDetails.keys():
            bssid = cgDetails['Bssid']
        secName = cgName + 'security'
        self.NetworkList[secName] = {}
        secDetails = self.NetworkList[secName]
        secDetails['ssid'] = ssid
        secDetails['bssid'] = bssid
        security = self.Security_None
        if cgName in securityStore.keys():
            security = securityStore[cgName]
        secDetails['security'] = security    
        return secName  
    
    def configCGs(self, clientStore, securityStore):
        clientGroup = odict.OrderedDict()
        for name in clientStore.keys():
            groupDetails = clientStore[name]
            enableF = groupDetails['Enable']
            if (enableF != True) and (enableF != 'True'):
                continue
            name = groupDetails['Name']
            clientGroup[name] = odict.OrderedDict()
            clientGroupDetails = clientGroup[name]
            clientGroupDetails['Enable'] = enableF
            if groupDetails['MacAddressMode'] == 'Auto':
                clientGroupDetails['StartMAC'] = 'AUTO'
            elif groupDetails['MacAddressMode'] == 'Random':
                clientGroupDetails['StartMAC'] = 'DEFAULT'
            else:
                clientGroupDetails['StartMAC'] = groupDetails['MacAddress']
            clientGroupDetails['MACIncrMode'] = groupDetails['MacAddressMode']
            clientGroupDetails['MACStep'] = groupDetails['MacAddressIncr']
            clientGroupDetails['Dhcp'] = groupDetails['Dhcp']
            clientGroupDetails['StartIP'] = groupDetails['BaseIp']
            clientGroupDetails['IPStep'] = groupDetails['IncrIp']
            clientGroupDetails['Port'] = groupDetails['PortName']
            clientGroupDetails['Gateway'] = groupDetails['Gateway']
            clientGroupDetails['SubMask'] = groupDetails['SubnetMask']
            #For Roam benchmark, we want only one client for Eth groups, so hack 
            #The GUI (clients page) doesn't allow client num to be changed for Eth groups
            #all the groups coming to configCGs() are going to be only Eth groups,
            #still we have the check below
            if groupDetails['Interface'] == '802.3 Ethernet':
                clientGroupDetails['NumClients'] = 1

            #clientGroupDetails['NumClients'] = int( groupDetails['NumClients'] )
            clientGroupDetails['Security'] = self.getSecProfile(groupDetails, securityStore)
            if groupDetails['Interface'] in WE.WiFiInterfaceTypes:
                clientGroupDetails['AssocProbe'] = groupDetails['AssocProbe'] 
            else:
                clientGroupDetails ['VlanEnable'] = groupDetails['VlanEnable']
                clientGroupDetails ['VlanUserPriority'] = int(groupDetails['VlanUserPriority'])
                clientGroupDetails ['VlanCfi'] = bool(groupDetails['VlanCfi'])
                clientGroupDetails['VlanId'] = int(groupDetails['VlanId'])
            clientGroupDetails['MgmtPhyRate'] = groupDetails['MgmtPhyRate']
            clientGroupDetails['GratuitousArp'] = groupDetails['GratuitousArp']
            clientGroupDetails['Interface'] = groupDetails['Interface']
            clientGroupDetails['PhyRate'] = groupDetails['DataPhyRate']
        return clientGroup
    
    
    def createNonRoamClientTuple(self, clientGroups):
        clientsPerCG = odict.OrderedDict()
        groups = clientGroups.keys()
        groups.sort()
        for group in groups:
            groupProperties = clientGroups[group]
            if groupProperties['Enable'] != True and groupProperties['Enable'] != 'True':
                continue
            clientData = ()
            clientData += (group,)
            if not 'Port' in groupProperties.keys():
                self.Print("Port not found in %s\n" % group, 'ERR')
                continue
            port = groupProperties['Port']
            clientData += (port,)
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
            #For release 2.4 we allow only one Eth Client, per group, 
            #(Hack for that) We would ignore numClients, in case by any chance the GUI 
            #gives 'numClients' value other than 1
            """
            if not 'NumClients' in groupProperties.keys():
                self.Print("NumClients not found in %s\n" % group, 'ERR')
                continue
            """
            groupProperties['NumClients'] = 1
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
                    macIncrMac = CF.MACaddress().inc(macIncrInt)
                else:
                    macIncrMac = CF.MACaddress().dec(macIncrInt)
                incrTuple += (macIncrMac.get(),)
            if not 'IPStep' in groupProperties.keys():
                self.Print("IPStep not found in %s\n" % group, 'ERR')
                continue
            incrTuple += (groupProperties['IPStep'],)
            clientData += (incrTuple,)
            securityData = {}
            if not 'Security' in groupProperties.keys():
                    self.Print("Security not found in %s\n" % group, 'ERR')
                    continue
            securityProf = groupProperties['Security']
            if securityProf not in self.NetworkList.keys():
                    self.Print("%s not found in NetworkList\n" % security, 
                          'ERR')
                    continue
            securityData = self.NetworkList[securityProf]
            if securityData != {}:
                if 'security' in securityData.keys():
                    security = securityData['security']
            clientData += (security,)
            clientOptions = odict.OrderedDict()
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
                    if groupProperties['QoSFlag'] == False:
                        wmeFlag = False
                if wmeFlag == True:
                    clientOptions['WmeEnabled'] = 'on'
                if 'MgmtPhyRate' in groupProperties.keys():
                    clientOptions['PhyRate'] = groupProperties['MgmtPhyRate']
                
                if 'TxPower' in groupProperties.keys():
                    clientOptions['TxPower'] = groupProperties['TxPower']
                
                if 'CtsToSelf' in groupProperties.keys():
                    clientOptions['CtsToSelf'] = groupProperties['CtsToSelf'] 
                       
                if 'BOnlyMode' in groupProperties.keys():
                    clientOptions['BOnlyMode'] = groupProperties['BOnlyMode']
                    
                # Keep Alive Frames
                keepAlive = str(groupProperties.get('KeepAlive', False))
                if keepAlive == 'True':
                    clientOptions['ClientLearning'] = 'on'
                else:
                    clientOptions['ClientLearning'] = 'off'   
                clientOptions['LearningRate'] = \
                    int(groupProperties.get('KeepAliveRate', 10))  
                    
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
            clientData += (clientOptions,)
            clientDataList = []
            clientDataList.append(clientData)
            clientsPerCG[group] = clientDataList
        return clientsPerCG
    
    #Used to create the stationary clients
    def createNonRoamClients(self, clientTuples):
        createdClients, clientList = self.createClients(clientTuples)
        return (createdClients, clientList)

    #Used to connectNonRoam Clients
    def connectNonRoamClients(self, clientList):
        self.connectClients(clientList)

    def makeScheduler(self, eventlist, FuncRealTime, absTime):
        schedulerEventList = []
        schedulerFlowEventList = []
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
        for port in self.roamSourcePorts.values():
            if port not in listofports:
                listofports.append(port)
        listofports.sort()
        Ethportlist = []
        Wportlist = []
        for port in listofports:
            if WE.GetCachePortInfo(port) in WE.WiFiPortTypes:
                Wportlist.append(port)
            if WE.GetCachePortInfo(port) == '8023':
                Ethportlist.append(port)

        actualTestDuration = eventlist[len(eventlist) - 1].GetTime()
        stats_interval = 1
        start_time = int(0.0 + stats_interval + absTime + self.lastRunTime)
        end_time = int(actualTestDuration + absTime)
        
        #Run events one by one and sleep in between
        Scheduler = sched.scheduler(time.time, time.sleep)
        for i in range(start_time, end_time, stats_interval):
            Scheduler.enterabs(i, 100, FuncRealTime, (Ethportlist, Wportlist))
            
        for i in range(len(eventlist)):
            Scheduler.enterabs(eventlist[i].GetTime() + absTime, 1, eventlist[i].run, '') 

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
            
    def _getRoamData(self, waveTestSpecificStore, waveClientTableStore, wlanGroups):
        """
        We have options that are common across all the groups. But the test is 
        designed to allow each group to have its own different value for each of 
        these configs (test options). Here, we map test specific config to group 
        specific config 
        """
        commonRoamOptions = self._getCommonRoamOptions()
        rawTestSpecificData = waveTestSpecificStore[self.testKey]
        roaming_data = {}
        commonConfig = odict.OrderedDict()
    
        for option in commonRoamOptions:
            commonConfig[option] = rawTestSpecificData[option]
        for group in wlanGroups:
            roaming_data[group] = rawTestSpecificData[group]
            roaming_data[group].update(commonConfig)
        roaming_data["roamTraffic"] = rawTestSpecificData["roamTraffic"]
        roaming_data["roamRate"] = rawTestSpecificData["roamRate"]
    
        return roaming_data
    
    
    def _loadTestSpecificData(self, waveClientTableStore, waveTestSpecificStore,
                              waveSecurityStore, roaming_data, 
                              enabledGroups, wlanGroups, roamGroups):
        """
        if roaming_data.has_key("backgroundTraffic") and len(roaming_data["backgroundTraffic"][0]) > 0:
            self.stationaryFlowMappings = roaming_data["backgroundTraffic"][0]
        """
        if roaming_data.has_key("roamTraffic") and len(roaming_data["roamTraffic"])  > 0:
            self.roamFlowMappings = roaming_data["roamTraffic"]
            
        nonRoamGroups = [group for group in enabledGroups if group not in roamGroups]
        
        nonRoamClientTableStore = {}
        for group in nonRoamGroups:
            nonRoamClientTableStore[group] = waveClientTableStore[group]
        
        #For Stationary Client Groups and Eth groups
        self.nonRoamGroups = self.configCGs(nonRoamClientTableStore, waveSecurityStore)
        self.roamInterval = 1/waveTestSpecificStore[self.testKey]['roamRate']
    
        self.dummyClientGroupNumsDict, self.dummyRoamBenchDict = \
                                self._createDummyDictsForWaitTimes(waveClientTableStore, 
                                                                   waveTestSpecificStore,
                                                                   wlanGroups)
        
    def _createDummyDictsForWaitTimes(self, waveClientTableStore, waveTestSpecificStore,
                                      wlanGroups):
        """
        self.dummyRoamBenchDict, self.dummyClientGroupNumsDict are used 
        when calling computeWaitTimes(). Create them.
        """
        dummyClientGroupNumsDict = {}
        dummyRoamBenchDict = {}
        for group in wlanGroups:
            dummyClientGroupNumsDict[group] = int (waveClientTableStore[group]['NumClients'])
        dummyRoamBenchDict = copy.deepcopy(waveTestSpecificStore[self.testKey])
    
        return dummyClientGroupNumsDict, dummyRoamBenchDict
    
    def _getDwellList(self, clientVals):
        dwellList = []
        for port in clientVals['portNameList']:
            dwellList.append(self.roamInterval)
        return dwellList
    
    def _getClientDistr(self, clientDistOption):
        """
        The clients are always distributed across all the wlan ports
        """
        return True
    
    def _getTimeDistr(self, timeDistOption):
        """
        The clients are always time distributed evenly
        """
        return 'even'
    
    def _getTestType(self, repeatType):
        if repeatType == 1:
            testType = 'Duration'
        if repeatType == 2:
            testType = 'Repeat'
        
        return testType
