#
# QoSCommon is a class which has common functions used in the QoS scripts
# QoS capacity & service test extend QoSCommon

#Common imports used in the scripts
import WaveEngine as WE
import struct
import odict
from odict import *
from CommonFunctions import *

#################################### Constants #################################
#

class QosCommon:
################################ configCGs #####################################
# This is the QoS scripts common functions    
# Configures client group properties from waveClientTableStore
    def configCGs(self, clientStore, securityStore, testSpecificStore):
        clientGroup = odict.OrderedDict()
        if "qos_capacity" in  testSpecificStore.keys():
            testParams = testSpecificStore['qos_capacity']
        else:
            testParams = testSpecificStore['qos_service'] 
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
            clientGroupDetails['TrafficClass'] = groupDetails['TrafficClass']
            if "qos_capacity" in  testSpecificStore.keys():
                # for QoS capacity, the # of client is the max calls/AP
                clientGroupDetails['NumClients'] = testParams['Voice']['SearchMax']
            else:
                # for Qos service, the # of client is the # of calls/AP
                clientGroupDetails['NumClients'] = testParams['Voice']['NumberOfCalls']     
            if "qos_service" in  testSpecificStore.keys():
                clientGroupDetails['Security'] = self.getSecProfile(
                        groupDetails, securityStore)                           
            if groupDetails['Interface'] in WE.WiFiInterfaceTypes:
                clientGroupDetails['AssocProbe'] = groupDetails['AssocProbe'] 
                clientGroupDetails ['VlanEnable'] = False
                clientGroupDetails['TxPower'] = int(groupDetails.get('TxPower', "-6"))
                clientGroupDetails['CtsToSelf'] = groupDetails['CtsToSelf'] 
                # Keep Alive Frames
                keepAlive = str(groupDetails.get('KeepAlive', False))
                if keepAlive == 'True':
                    clientGroupDetails['ClientLearning'] = 'on'
                else:
                    clientGroupDetails['ClientLearning'] = 'off'   
                clientGroupDetails['LearningRate'] = \
                    int(groupDetails.get('KeepAliveRate', 10))                                                                                               
            else:
                clientGroupDetails ['VlanEnable'] = groupDetails['VlanEnable']
                clientGroupDetails ['VlanUserPriority'] = int(groupDetails['VlanUserPriority'])
                clientGroupDetails ['VlanCfi'] = True
                if str(groupDetails['VlanCfi']) == 'False':
                    clientGroupDetails ['VlanCfi'] = False
                clientGroupDetails['VlanId'] = int(groupDetails['VlanId'])
            clientGroupDetails['MgmtPhyRate'] = groupDetails['MgmtPhyRate']
            clientGroupDetails['QoSFlag'] = True #on by default
            clientGroupDetails['GratuitousArp'] = groupDetails['GratuitousArp']
            clientGroupDetails['Interface'] = groupDetails['Interface']
            clientGroupDetails['PhyRate'] = groupDetails['DataPhyRate']
            clientGroupDetails['phyInterface'] = groupDetails['phyInterface']
            clientGroupDetails['nPhySettings'] = groupDetails['nPhySettings']
            
            if "qos_capacity" in  testSpecificStore.keys():
                # QoS capacity specific options are below
                clientGroupDetails['MacAddressMode'] = groupDetails['MacAddressMode'] 
                clientGroupDetails['clientCount'] ='Variable'
                clientGroupDetails['MainFlow'] ='Flow1' 
                clientGroupDetails['ssid'] = groupDetails['Ssid']
                clientGroupDetails['bssid'] = groupDetails['Bssid']  
                clientGroupDetails['DataPhyRate'] = groupDetails['DataPhyRate']
                for secKeys in securityStore[name].keys():
                    clientGroupDetails[secKeys] = securityStore[name][secKeys]                 
                if groupDetails['Interface'] in WE.WiFiInterfaceTypes: 
                    clientGroupDetails['QosEnabled'] = "on"    
                else:
                    del clientGroupDetails['MgmtPhyRate']     
        return clientGroup    
    
    def isCGEnabled(self, cgProperties):
        retVal = False

        if 'Enable' in cgProperties.keys():
            if (cgProperties['Enable'] == True) or (cgProperties['Enable'] == 'True'):
                retVal = True
        return retVal   

    def setCardLists(self):
        cardList = []
        groups = self.ClientGroups.keys()
        groups.sort()
        for group in groups:
            groupProperties = self.ClientGroups[group]
            if self.isCGEnabled(groupProperties):
                if 'Port' in groupProperties.keys():
                    portName = groupProperties['Port']
                    if portName not in cardList:
                        cardList.append(portName)
        self.CardList = cardList                
############################### configCGMaps ###################################
# This is the QoS scripts common functions
# Configures the mapping for the client groups
    def configCGMaps(self, clientGroups):  
        voiceGroups = odict.OrderedDict()
        bkGroups = odict.OrderedDict()    
        voicePairs = []
        bkPairs = []
        i = 0
        CGKey = clientGroups.keys()
        CGKey.sort()
        
        voiceGroups[WE.WiFiInterface] = []
        voiceGroups['802.3 Ethernet'] = []
        bkGroups[WE.WiFiInterface] = []
        bkGroups['802.3 Ethernet'] = []
        # Separate clients into 'Voice' or 'Background' groups
        for grp in CGKey:                                                                        
            if clientGroups[grp]['TrafficClass'] == 'Voice': 
                if clientGroups[grp]['Interface'] in WE.WiFiInterfaceTypes:
                    voiceGroups[WE.WiFiInterface].append(grp)
                else:
                    voiceGroups['802.3 Ethernet'].append(grp)
            else: # clientGroups[grp]['TrafficClass'] == 'Background':
                if clientGroups[grp]['Interface'] in WE.WiFiInterfaceTypes:
                    bkGroups[WE.WiFiInterface].append(grp)  
                else:
                    bkGroups['802.3 Ethernet'].append(grp) 
                                      
        # Pair the clients based on self.trafficDirection (Ethernet to wireless, etc)
        if self.trafficDirection == 'Ethernet To Wireless':  
            for i in range(0, len(voiceGroups['802.3 Ethernet'])):
                voicePairs.append((voiceGroups['802.3 Ethernet'].pop(0), 
                                   voiceGroups[WE.WiFiInterface].pop(0)))
            for i in range(0, len(bkGroups['802.3 Ethernet'])):
                bkPairs.append((bkGroups['802.3 Ethernet'].pop(0), 
                                bkGroups[WE.WiFiInterface].pop(0)))
        elif self.trafficDirection == 'Wireless To Ethernet':  
            for i in range(0, len(voiceGroups[WE.WiFiInterface])):
                voicePairs.append((voiceGroups[WE.WiFiInterface].pop(0), 
                                   voiceGroups['802.3 Ethernet'].pop(0)))                   
            for i in range(0, len(bkGroups[WE.WiFiInterface])):
                bkPairs.append((bkGroups[WE.WiFiInterface].pop(0), 
                                bkGroups['802.3 Ethernet'].pop(0)))
        elif self.trafficDirection == 'Wireless To Wireless':  
            for i in range(0, len(voiceGroups[WE.WiFiInterface])/2):
                voicePairs.append((voiceGroups[WE.WiFiInterface].pop(0), 
                                   voiceGroups[WE.WiFiInterface].pop(0)))                           
            for i in range(0, len(bkGroups[WE.WiFiInterface])/2):
                bkPairs.append((bkGroups[WE.WiFiInterface].pop(0), 
                                bkGroups[WE.WiFiInterface].pop(0)))
        elif self.trafficDirection == 'Ethernet To Ethernet':  
            for i in range(0, len(voiceGroups['802.3 Ethernet'])/2):
                voicePairs.append((voiceGroups['802.3 Ethernet'].pop(0), 
                                   voiceGroups['802.3 Ethernet'].pop(0)))                                              
            for i in range(0, len(bkGroups['802.3 Ethernet'])/2):
                bkPairs.append((bkGroups['802.3 Ethernet'].pop(0), 
                                bkGroups['802.3 Ethernet'].pop(0)))
                        
        return self.createFlowMaps(voicePairs, bkPairs, clientGroups)

############################## createFlowMaps ##################################
# This is the QoS scripts common functions
# Creates the flow mapping based on the voice & background client pairs
    def createFlowMaps(self, voicePairs, bkPairs, clientGroups):
        flowMaps = odict.OrderedDict()
        self.ClientGroups = odict.OrderedDict()
        i = 1                 
        
        for voicePair in voicePairs:
            (voice1, voice2) = voicePair
            voiceDict1 = odict.OrderedDict()
            voiceDict1[voice1] = clientGroups[voice1]
            voiceDict2 = odict.OrderedDict()
            voiceDict2[voice2] = clientGroups[voice2]
            self.ClientGroups.update(voiceDict1)  
            self.ClientGroups.update(voiceDict2)                                  
            flowMaps['Map' + str(i)] = odict.OrderedDict()
            mapDetail = flowMaps['Map' + str(i)]
            mapDetail['SrcCG'] = voice1
            mapDetail['DstCG'] = voice2
            mapDetail['flowType'] = 'voice'
            i += 1             
        for bkPair in bkPairs:
            (bk1, bk2) = bkPair
            (bkGroup1, bkDict1, voiceDict1) = self.createBGCG(None, bk1, clientGroups)
            (bkGroup2, bkDict2, voiceDict2) = self.createBGCG(None, bk2, clientGroups)
            
            self.ClientGroups.update(bkDict1) 
            self.renameClientGroup(bk1, bkGroup1)
            
            self.ClientGroups.update(bkDict2)
            self.renameClientGroup(bk2, bkGroup2)    
                       
            flowMaps['Map' + str(i)] = odict.OrderedDict()
            mapDetail = flowMaps['Map' + str(i)]
            mapDetail['SrcCG'] = bkGroup1
            mapDetail['DstCG'] = bkGroup2
            mapDetail['flowType'] = 'background'
            i += 1  
        return (flowMaps, self.ClientGroups)  

################################ createBGCG ####################################
# This is the QoS scripts common functions
# Creates the background client groups
    def createBGCG(self, voiceGroupName, bkGroupName, clientGroups):
        if voiceGroupName != None:
            # if drop here, bk group inherits all the voice group properties
            voiceDict = clientGroups[voiceGroupName]    
            bgName = 'BK' + bkGroupName
            bgDict = voiceDict.copy()
            if voiceDict['MACIncrMode'] != 'Auto' and voiceDict['MACIncrMode'] != 'Random':
                macMode = voiceDict['MACIncrMode']
                startMac = voiceDict['StartMAC']
                macIncrInt = int(voiceDict['MACStep'])
                if macMode.upper() == 'INCREMENT':
                    macIncrMac = MACaddress().inc(macIncrInt)
                else:
                    macIncrMac = MACaddress().dec(macIncrInt)
                startMac   = MACaddress(startMac)
                startMac += MACaddress(macIncrMac.get())
                voiceDict['StartMAC'] = str(startMac)
            startIP = IPv4toInt(voiceDict['StartIP'])
            if startIP != 0:
                ipStep = IPv4toInt(voiceDict['IPStep'])
                voiceDict['StartIP'] = int2IPv4(startIP + ipStep)
            nameVoiceDict = odict.OrderedDict()
            nameVoiceDict[voiceGroupName] = voiceDict
            bgDict['NumClients'] = 1    #We have only one client in a bk traffic grp
            bgDict['clientCount'] = "Fixed"
            bgDict['MainFlow'] = 'Flow2'       
            nameBGDict = odict.OrderedDict()
            nameBGDict[bgName] = bgDict
            return (bgName, nameBGDict, nameVoiceDict)                 
        else:
            bgName = 'BK' + bkGroupName
            bgDict = clientGroups[bkGroupName]
            bgDict['NumClients'] = 1    #We have only one client in a bk traffic grp
            bgDict['clientCount'] = "Fixed"
            bgDict['MainFlow'] = 'Flow2'       
            nameBGDict = odict.OrderedDict()
            nameBGDict[bgName] = bgDict
            return (bgName, nameBGDict, None)            
            
######################### createClientsForTopology #############################
# This is the QoS scripts common functions    
# Creates the client topology for the topology map in the report
    def createClientsForTopology(self, clientTuples):
        #Create self.SourceClients, self.DestClients required for the Topology picture
        groupLen = len(clientTuples.keys())
        groupList = []
        #Create a list of clientgroup names in the order 'BKGroup1', 'Group1', 'BKGroup2', 'Group2'...
        for groupName in clientTuples.keys():
            #if self.ClientGroups[groupName]['TrafficClass'] == 'Background':
            groupList.append(groupName)
            """
            if "BK" in groupName:        #watch out, when the naming style of background groups changes
                groupList.append(groupName)
                if groupName.split('BK')[1] in clientTuples.keys():
                    groupList.append(groupName.split('BK')[1]
            """
        if  (groupLen% 2 != 0):
            msg = "The client groups are not properly created"
            raise Exception, msg
        else:
            i = 0
            for groupName in groupList:
                for flowGroupName in self.FlowMappings:
                    if self.FlowMappings[flowGroupName]['SrcCG'] == groupName:
                        self.SourceClients += clientTuples[groupName]
                        self.DestClients += clientTuples[self.FlowMappings[flowGroupName]['DstCG']]
                        break

############################### getSecProfile ##################################
# This is the QoS scripts common functions
# Gets the security options, this function is only used by QoS service
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

################################ printReport ###################################
# This is the QoS scripts common functions    
    def printReport(self):
        self.MyReport.Print() 

############################## numToDottedQuad #################################
# This is the QoS scripts common functions      
    def numToDottedQuad(self, n):
        """
        Convert long int to dotted quad string
        """
        return inet_ntoa(struct.pack('>L',n)) 


#Modules for setting ToS byte, WlanQoS, enetQoS
def comupteToSByte(tosOptions):
    _TosPrecBit = 5
    _TosFieldDelayBit = 4
    _TosFieldThroughputBit = 3
    _TosFieldReliabilityBit = 2
    _TosFieldMonetaryBit = 1
    _TosFieldReservedBit = 0
    
    tosPrec = tosOptions['TosField']
    if tosPrec == "Network Control":
        voiceTosField = 7
    elif tosPrec == "Internet Control":
        voiceTosField = 6
    elif tosPrec == "CRITIC/ECP":
        voiceTosField = 5
    elif tosPrec == "Flash Override":
        voiceTosField = 4
    elif tosPrec == "Flash":
        voiceTosField = 3
    elif tosPrec == "Immediate":
        voiceTosField = 2
    elif tosPrec == "Priority":
        voiceTosField = 1 
    else: # default to "Routine"
        voiceTosField = 0 
        
    voiceTosField <<= _TosPrecBit

    if tosOptions.get('TosReserved', False) == True:
        voiceTosField |= (1 << _TosFieldReservedBit) 
    if tosOptions.get('TosLowCost', False) == True:
        voiceTosField |= (1 << _TosFieldMonetaryBit) 
    if tosOptions.get('TosLowDelay', False) == True:
        voiceTosField |= (1 << _TosFieldDelayBit) 
    if tosOptions.get('TosHighReliability', False) == True:
        voiceTosField |= (1 << _TosFieldReliabilityBit) 
    if tosOptions.get('TosHighThroughput', False) == True:  
        voiceTosField |= (1 << _TosFieldThroughputBit)         

    return voiceTosField

def setToS(flows, tosOptions, Dscp, flowType = "flow"):

    setToSF = False
    if Dscp != None:
        Field = "Dscp"
        value = Dscp
        setToSF = True
        dscpMode = 'on'
    else:    
        tosByte = comupteToSByte(tosOptions)
        if tosByte != 0:
            Field = "TosField"
            value = tosByte
            setToSF = True
            dscpMode = 'off'
    for flowName in flows:
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        if setToSF:
            WE.VCLtest("ipv4.readFlow()")   
            WE.VCLtest("ipv4.setDscpMode('%s')" % dscpMode)
            WE.VCLtest("ipv4.set%s(%d)" % (Field, value))                  
            WE.VCLtest("ipv4.modifyFlow()") 

        WE.VCLtest("%s.write('%s')" % (flowType, flowName))

def setVoipPorts(srcCGFlows, DstCGFlows, voipPorts, flowType = "flow"):
    srcPort = int(voipPorts['SrcPort'])
    destPort = int(voipPorts['DestPort'])
    flows = srcCGFlows + DstCGFlows
    for flowName in flows:
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        WE.VCLtest("udp.readFlow()")
        if flowName in srcCGFlows:
            WE.VCLtest("udp.setSrcPort(%d)" % srcPort)
            WE.VCLtest("udp.setDestPort(%d)" % destPort) 
        elif flowName in DstCGFlows:   
            WE.VCLtest("udp.setSrcPort(%d)" % destPort)
            WE.VCLtest("udp.setDestPort(%d)" % srcPort) 
        WE.VCLtest("udp.modifyFlow()") 
        WE.VCLtest("%s.write('%s')" % (flowType, flowName))
        
def configureQoS(flows, QoSF = True, wlanPriority = None, 
                 VlanEnableF= False, ethPriority = None, 
                 flowType = "flow"):
    """
    
    configureQoS(flows, QoSF = True, wlanPriority = None, VlanEnableF= False, 
                ethPriority = None, flowType = "flow")
    Given a list of flows, configure the wlanQoS, ethQoS priority based on the flags
    QoSF, VlanEnableF respectively
    """
    if (ethPriority == None and wlanPriority == None)\
        or \
        (QoSF == False and VlanEnableF== False):
        return
    WlanPorts = []
    EthPorts = []
    for flowName in flows:
        flowDetails = flows[flowName]
        if len(flowDetails) <= 0:
            continue
        srcPort = flowDetails[0]
        walnPortF = False
        ethPortF = False
        if srcPort in WlanPorts:
            walnPortF = True
        elif srcPort in EthPorts:
            ethPortF = True
        else:
            if WE.GetCachePortInfo(srcPort) in WE.WiFiPortTypes:
                WlanPorts.append(srcPort)
                walnPortF = True
            elif WE.GetCachePortInfo(srcPort) == '8023':
                EthPorts.append(srcPort)
                ethPortF = True
        WE.VCLtest("%s.read('%s')" % (flowType, flowName))
        if QoSF == True and walnPortF:
            WE.VCLtest("wlanQos.readFlow()")    
            WE.VCLtest("wlanQos.setTgaPriority(%s)" % wlanPriority)
            WE.VCLtest("wlanQos.setUserPriority(%s)" % wlanPriority)
            WE.VCLtest("wlanQos.modifyFlow()")    
        elif VlanEnableF== True and ethPortF:
            WE.VCLtest("%s.read('%s')" % (flowType, flowName))
            WE.VCLtest("enetQos.readFlow()")    
            WE.VCLtest("enetQos.setPriorityTag('on')")
            WE.VCLtest("enetQos.setTgaPriority(%s)" % ethPriority)
            WE.VCLtest("enetQos.setUserPriority(%s)" % ethPriority)
            WE.VCLtest("enetQos.modifyFlow()")     
        WE.VCLtest("%s.write('%s')" % (flowType, flowName)) 
            
