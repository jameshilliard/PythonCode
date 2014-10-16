#
#
#
import sys, math, traceback
import WaveEngine
import WaveEngine as WE
import wmlParser 
import os 
import os.path
import time
import CommonFunctions as CF
from CommonFunctions import *
from PIL import Image
import odict
import time
import mediumCapacity


class ClientGroupNotEnabledError(Exception): pass

#The tests as of the writing don't run around the object paradigm of client group
#or client, the idea is to move to that end using the below object frame works
class ClientGroup(object):
    
    def __init__(self, 
                 groupClientStore, 
                 groupSecurityStore,
                 testTrafficType,
                 clientConnectMode):
        """
        ClientGroup should contain data of the client group, this object
        should not be the source for flow information and test configuration 
        information, flows are expected to be objects by themseleves, the test
        manager would attach a flow object to a client group object based on the
        test logic. 
        This means, once this structuring is done, the parameters 'testTrafficType' 
        and 'clientConnectMode' should go away from this initialised method. 
        """
        self.__clientGroupProperties = groupClientStore
        self.__securityConfig = groupSecurityStore
        self.__testTrafficType = testTrafficType
        self.__clientConnectMode = clientConnectMode
        
        
        self.enabled = self._isGroupEnabled()
        self.__name = self.__clientGroupProperties['Name']
        self.__portName = self.__clientGroupProperties['PortName']
        self.__bssid =  self.__clientGroupProperties['Bssid']
        
        self.__groupTuple = None
        self.__clients = {}
    def _isGroupEnabled(self):
        if self.__clientGroupProperties['Enable'] in [True, 'True']:
            return True
        else:
            return False

    def _getName(self):
        return self.__name
    def _setName(self, newName):
        self.__name = newName
    name = property(fget = _getName,
                    fset = _setName)
    
    def _portName(self):
        return self.__portName
    portName = property(fget = _portName)
    
    def _bssid(self):
        return self.__bssid 
    bssid = property(fget = _bssid)
    
    def _securityConfig(self):
        return self.__securityConfig
    securityConfig = property(fget = _securityConfig)
    
    def _numClients(self):
        return int(self.__clientGroupProperties['NumClients'])
    numClients = property(fget = _numClients)
    
    def _phyType(self):
        phyInterface = self.__clientGroupProperties['phyInterface']
        return self._getPhyType(phyInterface)
    phyType = property(fget = _phyType)
    
    def _groupTuple(self):
        
        
        """
        For all the client groups, compute a tuple which is expected by 
        WaveEngine.CreateClients(). 
        Return a dict of all groups tuples 
        """
        
        if not self.__groupTuple:
            
            if self.enabled:
                
                groupName   = self.__name
    
                portName = self.__clientGroupProperties['PortName']
                
                bssid = self._getBSSID()
                
                baseMAC = self._getBaseMAC( )
                
                (ipAddress, 
                 subnetmask, 
                 gateway) = self._getIPsubnetmaskGateway()
                
                incrTuple = self._getIncrTuple()
        
                securityOptions = self._getSecOptions()
        
                clientOptions = self._getClientOptions()
        
                self.__groupTuple = (groupName, portName, bssid, baseMAC, 
                                     ipAddress, subnetmask, gateway, 
                                     incrTuple, securityOptions, clientOptions)
        
            else:
                raise ClientGroupNotEnabledError

        return self.__groupTuple
                
    groupTuple = property(fget = _groupTuple)    
    
    
    def _getBSSID(self):
        # need to convert 'None' to '00:00:00:00:00:00' for ethernet clients.
        if self.__clientGroupProperties['Interface'] == '802.3 Ethernet':
            bssid = '00:00:00:00:00:00'
        else:
            bssid = self.__clientGroupProperties['Bssid']
    
        return bssid
    
    def _getBaseMAC(self):
        # translate mac address mode
        macAddrMode = str(self.__clientGroupProperties['MacAddressMode'] ).upper()
        if macAddrMode == 'AUTO':
            # automatic mode -- assign MAC by cc:ss:pp:ip:ip:ip
            baseMAC = 'AUTO'
        elif macAddrMode in [ 'DEFAULT', 'RANDOM' ]:
            # default mode -- assign MAC by the IETF draft rr:pp:pp:rr:rr:rr
            # also known as random mode
            baseMAC = 'DEFAULT'
        else:
            # provided mac
            baseMAC = str(self.__clientGroupProperties['MacAddress'])
        
        return baseMAC
    
    def _getIPsubnetmaskGateway(self):
        useDhcp = str( self.__clientGroupProperties['Dhcp'] )
        if ( useDhcp in [ 'Enable', 'True' ] ):
            ipAddress =  str( "0.0.0.0" )
        else:
            ipAddress = str(self.__clientGroupProperties['BaseIp'])
        subnetmask = self.__clientGroupProperties['SubnetMask']
        gateway = self.__clientGroupProperties['Gateway']
    
        return (ipAddress, subnetmask, gateway)
    
    def _getIncrTuple(self):
        """
        Return (numClients, macIncr, IPincr)
        """
        numClients = int(self.__clientGroupProperties['NumClients'])
    
        #This is the MAC addr increment/decrement
        macIncr = str(self.__clientGroupProperties['MacAddressIncr'])
        macAddrMode = str(self.__clientGroupProperties['MacAddressMode'] ).upper()
        if macIncr.upper() == 'DEFAULT':
            # store AUTO or DEFAULT from base MAC
            if macAddrMode in ['DEFAULT', 'RANDOM']:
                macAddrMode = 'DEFAULT'
            if macAddrMode in [ 'DEFAULT', 'AUTO' ]:
                macIncr = macAddrMode
        else:
            macIncrInt = int(macIncr)
            if macAddrMode == 'INCREMENT':
                macIncrMac = MACaddress().inc(macIncrInt)
            else:
                macIncrMac = MACaddress().dec(macIncrInt)
            macIncr = macIncrMac.get()
        
        #This is the client IP increment field
        IPincr = self.__clientGroupProperties['IncrIp']
    
        incrTuple = (numClients, macIncr, IPincr)
        
        return incrTuple
    
    def _getSecOptions(self):
        """
        
        """
        return self.__securityConfig
    
    def _getClientOptions(self):
        
        clientOptionsDict = odict.OrderedDict()
        # if flow type is TCP, we need to add 'enableNetworkInterface' to client options
        # note that this only works for tests which use Import_ClientLists()
        # to populate the client options
        if self.__testTrafficType == 'TCP':
            clientOptionsDict['enableNetworkInterface'] = True
    
        #We don't have to set the PhyRate in case of an Ethernet Card as that shall
        #be set on a per port basis
        if self.__clientGroupProperties['Interface'] != WE.EthInterface:
            
            interfaceOptions = self._getInterfaceOptions()
            clientOptionsDict.update(interfaceOptions)
            
            if self.__clientGroupProperties['GratuitousArp'] == 'True':
                clientOptionsDict['GratuitousArp'] = 'on'
            else:
                clientOptionsDict['GratuitousArp'] = 'off'
            if str( self.__clientGroupProperties.get( 'ProactiveKeyCaching', 
                                                     'False' ) ) == 'True':
                clientOptionsDict['ProactiveKeyCaching'] = 'on'
            else:
                clientOptionsDict['ProactiveKeyCaching'] = 'off'
            probeVal = str( self.__clientGroupProperties.get( 'AssocProbe', 
                                                             'unicast' ) )
            if probeVal == 'Broadcast':
                clientOptionsDict['ProbeBeforeAssoc'] = 'bdcast'
            elif probeVal == 'None':
                clientOptionsDict['ProbeBeforeAssoc'] = 'off'
            else:
                clientOptionsDict['ProbeBeforeAssoc'] = 'unicast'
                
            clientOptionsDict['TxPower'] = int(self.__clientGroupProperties.get('TxPower', '-6'))
            # Keep Alive Frames
            keepAlive = str(self.__clientGroupProperties.get('KeepAlive', False))
            if keepAlive == 'True':
                clientOptionsDict['ClientLearning'] = 'on'
            else:
                clientOptionsDict['ClientLearning'] = 'off'   
            clientOptionsDict['LearningRate'] = \
                int(self.__clientGroupProperties.get('KeepAliveRate', 10))
            # Ad Hoc mode option
            clientOptionsDict['ConnectMode'] = self.__clientConnectMode                         
            #clientOptionsDict['TxPower'] = int(waveClientTableStore[]['TxPower'])            
            # Check if 802.11e QoS Access Category is enabled
            #if waveClientTableStore[]['Wlan80211eQoSEnable'] == "True":
            #    clientOptionsDict['WmeEnabled'] = "on"            
            
            clientOptionsDict['CtsToSelf'] = \
                self.__clientGroupProperties.get('CtsToSelf','off')
            
        # Ethernet-only options, such as VLAN
        else:
            if str( self.__clientGroupProperties.get( 'VlanEnable', 
                                                     'False' ) ) == 'True':
                vlanTag = self._getVLANtag()
                clientOptionsDict[ 'VlanTag' ] = vlanTag
        
        return clientOptionsDict

    def _getInterfaceOptions(self):
        "802.11b", "802.11ag", "802.11n"
        interfaceOptions = odict.OrderedDict()

        phyInterface = self.__clientGroupProperties['phyInterface']
        interfaceOptions['PhyType'] = self._getPhyType(phyInterface)
        
        if phyInterface in ['802.11b', '802.11ag']:
            interfaceOptions['PhyRate'] = float(self.__clientGroupProperties['MgmtPhyRate'])
        elif phyInterface == '802.11n':
            nPhySettings = self.__clientGroupProperties['nPhySettings']
            interfaceOptions['PlcpConfiguration'] =  nPhySettings['PlcpConfiguration'] 
            interfaceOptions['ChannelBandwidth'] = nPhySettings['ChannelBandwidth']
            interfaceOptions['ChannelModel'] =  nPhySettings['ChannelModel']
            interfaceOptions['DataMcsIndex'] = nPhySettings['DataMcsIndex']
            interfaceOptions['GuardInterval'] = nPhySettings['GuardInterval']
            if nPhySettings.get('EnableAMPDUaggregation', 'False') == 'True':
                interfaceOptions['WmeEnabled'] = 'on'
                interfaceOptions['AggregationEnabled'] = 'on'
            else:
                interfaceOptions['AggregationEnabled'] = 'off'
                
        return interfaceOptions    
    
    interfaceOptions = property(fget = _getInterfaceOptions) 
    
    def _getPhyType(self, phyInterface):
        phyTypeMap = {'802.11b': '11b',
                      '802.11ag': '11ag',
                      '802.11n': '11n'
                      }
        return phyTypeMap[phyInterface]
        
    def _getVLANtag(self):
        # VLAN enabled, parse VLAN values
        userPriority = int( self.__clientGroupProperties.get( 'VlanUserPriority', 0 ) )
        if str( self.__clientGroupProperties.get( 'VlanCfi', "False" ) ) == "True":
            cfiBit = 1
        else:
            cfiBit = 0
        vlanId = int( self.__clientGroupProperties.get( 'VlanId', 0 ) )
        # assemble parts into the VCAL VLAN Tag
        # [ 3:UserPriority ][ 1:CFI ][ 12:VlanId ] => 16bit value
        vlanTag = ( userPriority & 0x7 ) * 2**13 + ( cfiBit & 0x1 ) * 2**12 + ( vlanId & 0xfff )
        # msg = "%s: assembled VLAN tag = %d ( user = %d, cfi = %d, id = %d )" % ( clientGroup, vlanTag, userPriority, cfiBit, vlanId )
        # OutputstreamHDL( msg, MSG_WARNING )
            
        return vlanTag
    
    def _interface(self):
        return self.__clientGroupProperties['Interface']

    interface = property(fget = _interface)
    
    def _dataPhyRate(self):
        return float(self.__clientGroupProperties['DataPhyRate'])
    
    dataPhyRate = property(fget = _dataPhyRate)
    
    def _nPhySettings(self):
        return self.__clientGroupProperties['nPhySettings']
    nPhySettings = property(fget = _nPhySettings)
    
    def Wlan80211eQoSEnabled(self):
        if self.__clientGroupProperties['Wlan80211eQoSEnable'] == 'True':
            return True
        else:
            return False
        
    def _Wlan80211eQoSAC(self):
        return self.__clientGroupProperties['Wlan80211eQoSAC']
    
    Wlan80211eQoSAC = property(fget = _Wlan80211eQoSAC)
    

    """
    def __init__(self, 
                 name, 
                 portName, 
                 bssid, 
                 baseMAC, 
                 baseIP,
                 subnetmask, 
                 gateway, 
                 incrTuple, 
                 securityConfig, 
                 clientgroupOptions,
                 mpduAggregation
                 ):
        self.name = name
        self.portName = portName
        self.bssid = bssid
        #self.ssid = ssid
        self.baseMAC = baseMAC
        self.baseIP = baseIP
        self.subnetmask = subnetmask
        self.gateway = gateway
        self.incrTuple = incrTuple
        self.securityConfig = securityConfig
        self.clientgroupOptions = clientgroupOptions
        self.mpduAggregation = mpduAggregation
        self.clients = {}
        #self.clientNames = []

       
    def getName(self):
        return self.name
    
    def getPortName(self):
        return self.portName
    
    def getBssid(self):
        return self.bssid
    
    def getBaseMAC(self):
        return self.baseMAC
    
    def getBaseIP(self):
        return self.baseIP
    
    def getSubnetmask(self):
        return self.subnetmask
    
    def getGateway(self):
        return self.gateway
    
    def getIncrTuple(self):
        return self.incrTuple
    
    def getSecurityConfig(self):
        return self.securityConfig
    
    def getClientgroupOptions(self):
        return self.clientgroupOptions
        
    def getInterfaceType(self):
        phyType = self.clientgroupOptions.get('PhyType', '')
        if phyType not in ['11b', '11ag', '11n']:
            interfaceType = '8023'
        else:
            interfaceType = phyType
        
        return interfaceType
        
    def getClientNames(self):
        return self.clients.keys()
    
    def getNumClients(self):
        return len(self.clients)
    
    def setSecurityConfig(self, securityOptions):
        self.securityOptions = securityOptions
    
    def modifySecurityOptions(self, options):
        pass
    
    def setClientgroupOptions(self, clientgroupOptions):
        self.clientgroupOptions = clientgroupOptions
    
    def modifyClientOptions(self, options):
        pass
    """
    
    def isBehindNAT(self):
        if self.__clientGroupProperties.get('BehindNAT', 'False') == 'True':
            return True
        else:
            return False
        
    def isMPDUaggregationON(self):
        if (self.interface in WE.WiFiInterfaceTypes 
            and 
            self.__clientGroupProperties['phyInterface'] == '802.11n'):
            
            nPhySettings = self.__clientGroupProperties['nPhySettings']
            
            if nPhySettings.get('EnableAMPDUaggregation', 'False') == 'True':
               return True
        
        return False

    def isTheClientMember(self, clientName):
        return clientName in self.__clients
    
    def getOriginatingFlowList(self):
        originatingFlows = []
        for clientName in self.__clients:
            clientFlows = self.__clients[clientName].getOriginatingFlows()
            originatingFlows += clientFlows.keys()
        return originatingFlows
    
    def addClients(self, createdClients):
        self._addClients(createdClients)
                
    def _getClients(self):
        return self.__clients
    
    def _setClients(self, createdClients):
        #Erase any existing clients, as that's intuitive for an '=' operation
        self.__clients = {}
        self._addClients(createdClients)

    clients = property(fget = _getClients,
                       fset = _setClients)
    
    def _getClientTupleInfo(self):
        """
        """
        clientTupleInfo = odict.OrderedDict()
        for clientName in self.__clients:
            clientObj = self.__clients[clientName]
            clientTupleInfo[clientName] = (clientObj.connectionState, 
                                           clientObj.portList, 
                                           clientObj.basicType)
        return clientTupleInfo
    clientTupleInfo = property(fget = _getClientTupleInfo)
    
    def _addClients(self, createdClients):
        for clientName in createdClients:
            (connectionState, portList, basicType) = createdClients[clientName]
            self.__clients[clientName] = Client(self.__name, 
                                                   clientName,
                                                   portList, 
                                                   basicType, 
                                                   connectionState
                                                   )
    def _propertiesForTTobject(self):
        """
        """
        properties = {}

        # Add in the port info so we can include this in the report client group configuration table
        properties['portName'] = self.__portName

        if self.interface in WE.WiFiInterfaceTypes:
            phyInterface = self.__clientGroupProperties['phyInterface']
            #tt object knows interfaces as '11b', '11ag' and '11n'
            if phyInterface == '802.11ag':
                phyType = '11ag'
            elif phyInterface == '802.11b':
                phyType = '11b'
            elif phyInterface == '802.11n':
                phyType = '11n'
            
            properties['phyType'] = phyType
            
            if phyType in ['11b', '11ag']:
                properties['dataPhyRate'] =  self.__clientGroupProperties['DataPhyRate']
                
            elif phyType == '11n':
                nPhySettings = self.__clientGroupProperties['nPhySettings']
                dataMcsIndex = nPhySettings['DataMcsIndex']
                channelBandwidth = nPhySettings['ChannelBandwidth']
                guardInterval = nPhySettings['GuardInterval']
                plcpConfiguration = nPhySettings['PlcpConfiguration']
                EnableAMPDUaggregation = nPhySettings.get('EnableAMPDUaggregation', 
                                                          'False')
                
                properties['dataMcsIndex'] = dataMcsIndex
                properties['channelBandwidth'] = channelBandwidth
                properties['guardInterval'] = guardInterval
                properties['plcpConfiguration'] = plcpConfiguration
                properties['EnableAMPDUaggregation'] = EnableAMPDUaggregation
            else:
                #Error message
                pass
            
            return properties
                
        elif self.interface in WE.EthInterface:
            properties['phyType'] = 'Ethernet'
            
            WE.VCLtest("port.read('%s')"%self.__portName)
            duplex = WE.VCLtest("port.getDuplex()")
            linkSpeed = WE.VCLtest("port.getSpeed()")

            properties['linkSpeed'] = linkSpeed
            properties['duplex'] = duplex
        
        return properties
    
    propertiesForTTobject = property(fget = _propertiesForTTobject)
    
class Client(object):
    def __init__(self, 
                 groupName, 
                 name, 
                 portList,
                 basicType, 
                 connectionState):
        self.groupName = groupName
        self.name = name
        self.portList = portList
        self.basicType = basicType
        self.connectionState = connectionState
        """
        self.ip = ''
        self.mac = ''
        self.smask = ''
        self.gateway = '' 
        self.ssid = ''
        self.interfaceInfo = interfaceInfo
        """
        self.originatingFlows = {}
        self.destinatingFlows = {}

    def getOriginatingFlows(self):
        return self.originatingFlows
    
    def getDestinatingFlows(self):
        return self.destinatingFlows

    def addOriginatingFlow(self, flowName, peerName, peerPort):
        self.originatingFlows[flowName] = {'peerName':peerName,
                                          'peerPort':peerPort 
                                          }

    def addDestinatingFlow(self, flowName, peerName, peerPort):
        self.destinatingFlows[flowName] = {'peerName':peerName,
                                          'peerPort':peerPort 
                                          }

class FlowGroupObj(object):
    def __init__(self, flowList, flowGroupName):
        self.__name = flowGroupName
        self.__flowList = flowList
        #self.__flowNames is used to store those flows which have only name 
        #information (no info on src, dest etc), see .doc for addFlowName() below
        self.__flowNames = []
        
    def isReadyToStart(self):
        allFlowNames = self.__flowNames + self.__flowList.keys()
        
        for flowName in allFlowNames:
            transmitState = self._getTransmitState(flowName)
            if transmitState in ['on', 'ON']:
                return False
        return True
    
    def _getTransmitState(self, flowName):
        #FlowList doesn't contain information on whether it's a flow or a 
        #biflow, for now, using try..except. FlowList should contain the 
        #flow type information, Ideally flow should be an object which is 
        #an attribute of mc.
        try:
            WaveEngine.VCLtest("biflow.read('%s')"%flowName, 
                               negativesAreOK = True)
            transmitState = WaveEngine.VCLtest("biflow.get('TransmitState')", 
                                                negativesAreOK = True)
        except:
            WaveEngine.VCLtest("flow.read('%s')"%flowName, 
                               negativesAreOK = True)
            transmitState = WaveEngine.VCLtest("flow.getTransmitState()", 
                                                negativesAreOK = True)
        return transmitState
    
    def addFlowName(self, flowName):
        """
        This method is used to add a flow whose only information available is 
        its name. Going with this method for quick fix for VPR 6091. QoS Capacity
        adds flow to flow groups, but at that point of code, we only have flow
        name available, no other info (of course, can get that info,
        this is a quick fix)
        Get rid of this method, which requires refactoring especially of QoS Capacity
        test
        """
        self.__flowNames.append(flowName)
        
class BaseTest(object):
    def __init__(self):
        self.clientgroupObjs = {}
        self.ListofSrcClient = odict.OrderedDict()
        self.ListofDesClient = odict.OrderedDict()
        self.ListOfClients = odict.OrderedDict()
        self.clientGroupObjInfo = {}
        self.flowGroupObjs = {}
        self.CardList = []
        self.SrcCardList = []
        self.DesCardList = []
        self.ResultsForCSVfile = []
        self.RealtimeCallback = self.PrintRealtimeStats
        #_______________dataExport__________________        
        self.DbSupport = False
        self.Version_list_db =[]
        self.attribute_final_list_db  = {} 
        self.ResultsforDb =[]
        self.start_time=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))
        #_______________dataExport__________________

        ########################## Paramters redefined by the calling class ##########################

        #                 Name      Chassis   Cd Pt  Chan
        self.CardMap = { 'Name': ('Chassis', 0, 0, 6) }
        # Description of Client setups
        # Option name MUST match VCL's set/get names exactly
        self.ClientOptions = {}
        self.PortOptions   = {}
        self.testOptions = {}
        # Security Options
        # A Dictionary of passed paramters. Below is a sample of a few different Security options:
        Security_None = {'Method': 'NONE'}
        Security_WEP  = {'Method': 'WEP-OPEN-128', 'KeyId'   : 0, 'NetworkKey': '00:00:00:00:00:00' }
        Security_WPA2 = {'Method': 'WPA2-EAP-TLS', 'Identity': 'anonymous', 'Password' : 'whatever'}
        # A BSSID/SSID of all zeros tells WaveEngine to use the first BSSID is finds on the port
        # A MAC address of 'DEFAULT' lets WaveEngine set them to IETF draft draft-ietf-bmwg-hash-stuffing-04
        # A IP address of '0.0.0.0' tells WaveEngine that the client is DHCP
        #                       Name          Port       BSSID/SSID    MAC        IP               Subnet           Gateway      Count Security Options
        self.SourceClients = [ ('Eth', 'Port1', '00:00:00:00:00:00', 'DEFAULT', '192.168.50.10', '255.255.255.0', '192.168.50.1', (), Security_None, self.ClientOptions)]
        self.DestClients   = [ ('Wifi', 'Port2', '00:00:00:00:00:00', 'DEFAULT', '192.168.50.11', '255.255.255.0', '192.168.50.1', (), Security_None, self.ClientOptions)]

        # Test Paramters
        self.FrameSizeList  = [ 100 ]
        self.ILOADlist      = [ 100, 500 ]
        self.Trials         =  1  

        # Time units in seconds
        self.TransmitTime   =  30
        self.SettleTime     =   2
        self.AgingTime      =   5
        self.IntendedTransmitTime = 30
        
        #Passed strings describing the DUT/SUT
        self.DUTinfo = {'WLAN Switch Model'      : "WLANSwitchModel", 
                        'WLAN Switch SW version' : "1", 
                        'AP Model'               : "APModel", 
                        'AP SW version'          : "1.01"}

        # Test ID
        self.TestID = "" # test ID string, useful for automation

        # Set Flow parameter
        # Valid names for FlowMap are CreateFlows_Pairs, CreateFlows_Many2One, CreateFlows_PartialMesh, CreateFlows_FullMesh
        self.FlowMap        = WaveEngine.CreateFlows_Pairs
        # Option name MUST match VCL's set/get names exactly
        self.FlowOptions    = {'Type': 'IP', 'PhyRate': 54 }
        self.BiDirectional  = False
        self.biFlow = False
        self.connectMode = 'infrastructure'
        # dict that stores the flow rate for each wifi group
        self.flowPhyRates = {}
        # dict that stores the WLAN 802.11e QoS Access Category for each wifi group
        self.flowWlan80211eQoSAC = {}
        self.FlowList = {}
        self.ArpList = {}
        self.trafficParams = {}
        
        self.testDir = {'unicast_latency': 'Latency', 
                        'unicast_max_client_capacity':'MaximumClientCapacity', 
                        'unicast_max_forwarding_rate':'MaximumForwardingRate', 
                        'unicast_packet_loss':'PacketLoss', 
                        'unicast_unidirectional_throughput':'Throughput', 
                        'rate_vs_range':'RateVsRange', 
                        'tcp_goodput':'TcpGoodput', 
                        'roaming_delay':'RoamingDelay', 
                        'roaming_benchmark':'RoamingBenchmark',
                        'voip_roam_quality': 'RoamingServiceQuality',
                        'Call Capacity':'CallCapacity',
                        'qos_capacity':'ServiceCapacity',
                        'qos_service':'ServiceAssurance' ,
                        'aaa_auth_rate': 'AaaAuthRate',
                        'frame_generator':'FrameGenerator',
                        'mesh_throughput_per_hop': 'MeshThroughputPerHop',
                        'mesh_throughput_aggregate': 'MeshThroughputAggregate',
                        'mesh_latency_per_hop': 'MeshLatencyPerHop',
                        'mesh_latency_aggregate': 'MeshLatencyAggregate',
                        'mesh_max_forwarding_rate_per_hop': 'MeshMaxFwdRatePerHop',
                        }
        ####################### Learning parameters ################################
        """
        These paramters are used to train the DUT/SUT about the clients and flows that are used during the test.   Loss is not
        an issue during learning, only during the actual measurement.
        
        ClientLearningTime - The number of seconds that a Client will flood a DNS request with its source IP address.  This is
                             used to teach the AP about the existance of a client if Security or DHCP is not suffiecient.
        ClientLearningRate - The rate of DNS request the client will learn with in units of frames per second.
        FlowLearningTime   - The number of seconds that the actual test flows will send out learning frames to populate the
                             DUT/SUT forwarding table.  The rate is at teh configure test rate. 
        FlowLearningRate   - The rate of flow learning frames are transmitted in units of frames per second.  This should be set
                             lower than the actual offered loads.
        """
        self.ClientLearningTime = 2
        self.ClientLearningRate = 10
        self.FlowLearningTime   = 2
        self.FlowLearningRate   = 100

        #Set Logging Paramters
        self.CSVfilename      = 'Results.csv'
        self.ReportFilename   = 'Report.pdf'
        self.LoggingDirectory = "logs"
        self.SavePCAPfile     = False
        self.GeneratePCAPlog  = False
        self.PCAPFilename     = None
        self.DetailedFilename = ''
        self.ConsoleFilename  = ''
        self.RSSIFilename     = None
        self.TimelogFilename  = ''
        
        # Search paramters
        self.SearchResolutionPercent = 0.1
        self.SearchAcceptLossPercent = 0.0

        # Max Forwading Rate specific search Paramters
        self.SearchInitailSlice      = 5
        self.SearchIterations        = 10 
        self.SearchHighListLength    = 3

       ####################### Timing parameters ################################
        """
        These parameters will effect the performance of the test. They should only be altered if a specific
        problem is occuring that keeps the test from executing with the DUT. 
        
        BSSIDscanTime -     Amount of time to allow for scanning during the BSSID discovery process. Units: seconds
        ConnectionType -    The connection process type, which can be 'Aggregate' or 'Variable'
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
        ContentionProbability -  Valid probability is between 0% and 100%.  The number should be interpreted as the "probability" 
                            of contention, and will be specified as the maximum probability of the [n-1,n] segment.
                            Example, specifying 50 means that the probability of generating a FCS error frame is between 40%
                            and 50%.  Only Values of 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, and 100 should be set.
        """
        self.BSSIDscanTime     =   1.5
        self.ConnectionType    = 'Aggregate'
        self.AssociateRate     =  25.0
        self.AssociateRetries  =   0
        self.AssociateTimeout  =   5.0
        self.ARPRate           =  25.0
        self.ARPRetries        =   3
        self.ARPTimeout        =  10.0
        self.UpdateInterval    =  0.5
        self.DisplayPrecision  =   3
        self.testOptions['ContentionProbability'] = 0
        ports = []
        self.PortOptions['ContentionProbability'] = {}
        for clientTuple in self.SourceClients + self.DestClients:
            port = clientTuple[1]
            ports.append(port)
        for port in ports:
            self.PortOptions['ContentionProbability'][port] = self.testOptions['ContentionProbability']
        
        #Options for training flows between Iterations
        self.ReEducationTime        = 0
        self.ReEducationFlowOptions = {'Type': 'ICMP', 'FrameSize': 128}
        self.ReEducationalGroupName = 'EducationcalGroup'
        self.ReEducationFlowList    = {}       

        #Return status when Program exits
        self.ExitStatus = 0

        # If RandomSeed is an int or long, hash(RandomSeed) is used instead to start the random number generator
        self.RandomSeed = None
        
        # Ordered dictionary to populate the 'Other Info' table in the PDF reports.
        # Used for WaveApps version number.
        self.OtherInfoData = odict.OrderedDict()

        # A dictionary of real time data
        self.RealtimeData = {}

        # A list of measured RSSI values measured between iterations
        self.RSSItable = []
        
        # A dict of 'group name' : (port name, BSSID) 
        self.grpBssidDict = {}
        
        #These ports are used for capture Only
        self.MonitorPortList = []

        # Login information for clients.
        # None = no per-client login, use per-group 'Identity' and 'Password'
        # List of tuples in the form: [ ( 'user', 'pw' ), ... ] used across client groups.
        # Dictionary of the form: { 'groupname': [ (u,p), (u,p), ... ] }
        self.Logins = None

        # This list is used to check if the current test is in the Mesh Test Suite
        # Blog Mode only applies to Mesh Test Suite for now
        self.meshTestList = ['mesh_latency_per_hop', 'mesh_latency_aggregate', 
                             'mesh_throughput_per_hop', 'mesh_throughput_aggregate', 
                             'mesh_max_forwarding_rate_per_hop']
        self.InterferenceRate = [('Port Name', 'Frame Size Band', 'Lowest Frame Size (Bytes)', 
                                  'Highest Frame Size (Bytes)', 'Frame Strike Rate (%)'), ]

    def Print(self, msg, itype = 'OK'):
        if itype == 'ERR':
            msgtype = WaveEngine.MSG_ERROR
        elif itype == 'WARN':
            msgtype = WaveEngine.MSG_WARNING
        elif itype == 'OK':
            msgtype = WaveEngine.MSG_OK
        elif itype == 'SUCC':
            msgtype = WaveEngine.MSG_SUCCESS
        elif itype == 'DBG':
            msgtype = WaveEngine.MSG_DEBUG
        else:
            msgtype = WaveEngine.MSG_OK
        WaveEngine.OutputstreamHDL(msg, msgtype)

    def PrintRealtimeStats(self, TXstate, Timeleft, ElapsedTime, PassedParameters):
        """
        Default realtime stats function.  Should be reimplemented in subclasses.
        """
        msg = "Stats:  TXstate = %s  Timeleft = %s  ElapsedTime = %s \n" % \
                      (TXstate, Timeleft, ElapsedTime)
        WaveEngine.OutputstreamHDL(msg, WaveEngine.MSG_DEBUG)
        return True
        
    def setTrials(self, num):
        self.Trials = num

    def setCallback(self, func):
        """
        Use given function reference as the callback for messages.
        """
        WaveEngine.SetOutputStream(func)
        
    def setRealtimeCallback(self, func):
        """
        Use given function reference as the callback for realtime stats.
        Function must take TXstate, Timeleft, ElapsedTime, and PassedParameters as arguments.
        Function will return True, or False to abort the test.
        """
        self.RealtimeCallback = func
        
    def getInfo(self):
        """
        Returns information about the specific test.
        """
        raise NotImplemented

    def getClassFromTest(self):
        """
        Parses test class object and categorizes into license key categories.
        Returns testClass -- benchmark, qos, etc...
        """
        testClass = None
        fileName = str( sys.modules[ self.__module__ ].__file__ )
        baseName, extName = os.path.splitext( os.path.basename( fileName ) )
        testName = str( baseName ) # Example: 'unicast_latency'
        global testname 
        testname=testName
        classes = {'benchmark': ['unicast_latency',
                                 'unicast_call_capacity',
                                 'unicast_client_capacity',
                                 'unicast_max_client_capacity',
                                 'unicast_max_forwarding_rate',
                                 'unicast_packet_loss',
                                 'unicast_unidirectional_throughput',],
                   'roaming':   ['roaming_delay', 'roaming_benchmark', 'scaled_roaming',],
                   'qos':       ['qos_capacity',
                                 'qos_service',
                                 'voip_roam_quality',
                                 ],
                   'rvr':       ['rate_vs_range',],
                   'tcp':       ['tcp_goodput',],
                   'security':  ['frame_generator'],
                   'AAA':       ['aaa_auth_rate'],
                   'mesh':      ['mesh_throughput_per_hop',
                                 'mesh_throughput_aggregate',
                                 'mesh_latency_per_hop',
                                 'mesh_latency_aggregate',                                   
                                 'mesh_max_forwarding_rate_per_hop',],                    
                  }
        for key in classes:
            if testName in classes[ key ]:
                testClass = key
        return testClass

    def isTestEnabled(self):
        """
        Returns True if license key allows test to be run.
        Returns False if license key does not allow test to run.
        Uses 'getClass' method to find test class.
        Uses 'vwRoot/waveapps.vw' to store license key.
        """
        testClass = self.getClassFromTest()
        #print "testClass =", testClass

        # app root location
        appRoot = os.path.dirname(os.path.abspath(sys.argv[0]))
        try:
            vwRoot = os.environ['VERIWAVE_HOME']
        except:
            vwRoot = appRoot

        import vcl
        vcl.session.appRoot = vwRoot
        rc = vcl.session.checkTest(testClass)
        if rc != 0:
            raise WaveEngine.RaiseKeyException

        return True

    def getCharts(self):
        """
        Returns test-specific chart objects in a dictionary.
        Must be re-implemented in sub-class.
        """
        return {}

    ##################################### Import_ClientDescription #####################################
    # (BaseName, Port, BSSID, Base_MAC,  Base_IP, Subnet, Gateway, (Count=1, Incr_MAC='0:0:0:0:0:0', Incr_IP='0.0.0.0'), Security, Options)
    def Import_ClientLists(self, waveMappingStore):

        # Build Src and Des Lists
        UsedProfiles = [] 
        SrcClient   = []    
        DesClient   = []
        
        if len(waveMappingStore) > 2:
                    
            ClientProfile = self._getClientGroupsTuples()
        
            for ClientName in waveMappingStore[1]:
                SrcClient.append(ClientProfile[ClientName])
                if ClientName not in UsedProfiles:
                    UsedProfiles.append(ClientName)
            for ClientName in waveMappingStore[2]:
                DesClient.append(ClientProfile[ClientName])
                if ClientName not in UsedProfiles:
                    UsedProfiles.append(ClientName)
            ClientList  = []
            for ClientName in UsedProfiles:
                ClientList.append(ClientProfile[ClientName]) 
        return SrcClient, DesClient

    def _getClientGroupsTuples(self):
        clientgroupTuples = {}
        for groupName in self._enabledGroups:
            clientgroupTuples[groupName] = self.clientgroupObjs[groupName].groupTuple
            
        return clientgroupTuples
    
    def renameClientGroup(self, name, newName):
        self.clientgroupObjs[newName] = self.clientgroupObjs[name]
        self.clientgroupObjs[newName].name = newName
        
        #Handle the side effects
        #Swap to new name
        if name in self._enabledGroups:
            ind = self._enabledGroups.index(name)
            self._enabledGroups[ind] = newName
            
        del self.clientgroupObjs[name]
    
    def _allEnabledGroups(self):
        """
        In some tests (e.g., QoS capacity, assurance) self.clientgroupObjs 
        might be altered after load data, in such cases, getting latest list
        of groups enabled might be required, thus re-running 
        self._allEnabledGroups() to get the latest group names.
        Minimizing the call to this method by using self._enabledGroups, which 
        gets updated in the latest call to this method.
        """
        self._enabledGroups = [groupName for groupName in self.clientgroupObjs 
                                if self.clientgroupObjs[groupName].enabled]
        return self._enabledGroups
        
                        
    def _clientLearning(self, clientDict, clientLearnTime, clientLearnRate):
        """
        Set the learning flow rate to the groups data phy rate and run flows.
        It is assumed that this method is called by a test to run learning flows
        for all the mobile clients, thus we ignore clientList (until we see
        the need to consider it).
        
        """
        for groupName in self._enabledGroups:
            groupDataPhyRate = self.clientgroupObjs[groupName].dataPhyRate
            clientTupleInfo = self.clientgroupObjs[groupName].clientTupleInfo
            WE.ClientLearning(clientTupleInfo, clientLearnTime, clientLearnRate,
                              flowPhyRate = groupDataPhyRate)    
         
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
        Simply loads the given storage dictionaries into the test class.
        Raises exceptions on error.
        """
        self.loadingpassfaildata(waveChassisStore, 
                 wavePortStore, 
                 waveClientTableStore, 
                 waveSecurityStore, 
                 waveTestStore, 
                 waveTestSpecificStore, 
                 waveMappingStore, 
                 waveBlogStore)
        testName = waveTestSpecificStore.keys()[0]
        
        self._setLogDirectory(waveTestStore, testName)
        
        self._createLogDirectory()
        
        if waveTestStore['LogsAndResultsInfo'].get('GeneratePdfReport', 'True') == "True":
            self.generatePdfReportF = True
        else:
            self.generatePdfReportF = False
            
        if waveTestStore['LogsAndResultsInfo'].get('GeneratePCAPlog', 'True') == "True":
            self.GeneratePCAPlog = True
        else:
            self.GeneratePCAPlog = False
        
        # set the random seed
        self.RandomSeed = int(waveTestStore['TestParameters']['RandomSeed'])

        if len(waveMappingStore) > 5:
            self.connectMode = self._getTrafficMode(waveMappingStore)
            flowType = str(waveMappingStore[5]['Type'])
        else:
            flowType = 'UDP'
                
        self.createClientGroupObjs(waveClientTableStore, 
                                   waveSecurityStore,
                                   flowType,
                                   self.connectMode
                                   )    
                
        self._enabledGroups = self._allEnabledGroups()        
        #Ugly ugly hack to connect APs which don't broadcast SSIDs
        #(ssid hidden). If it weren't for the time constraint for 2.4.2, 
        #would look for better approach
        WaveEngine.setPortBssidSsid(wavePortStore)
        
        self._loadTestGenericParams(waveTestStore, 
                                    waveMappingStore,
                                    testName)
        
        self._loadPortOptions(waveChassisStore, waveTestStore)

        # translate the various WaveApps dictionaries to WaveEngine variables
        self.CardMap  = WaveEngine.Import_CardMap(waveChassisStore)
        
        self._loadFlowInfo(waveMappingStore, waveTestStore)

        (self.SourceClients, self.DestClients) = self.Import_ClientLists(waveMappingStore)      
        
        self._createPortBssidDict()
        
        self._createLoginList()

        if testName in self.meshTestList:
            # Blog Mode only applies to Mesh test for now
            self._loadInterferenceRates(waveBlogStore)
            
        # Payload
        self._loadPayLoadInfo(waveTestStore)
        
        self._loadMedCapacityData(testName, waveTestSpecificStore[testName])

        self.isTestEnabled()
        return True

    def createClientGroupObjs(self, 
                              waveClientTableStore,
                              waveSecurityStore,
                              testTrafficType,
                              clientConnectMode):
        for group in waveClientTableStore:
            self.clientgroupObjs[group] = ClientGroup(waveClientTableStore[group],
                                                         waveSecurityStore[group],
                                                         testTrafficType,
                                                         clientConnectMode)
        
    def _setLogDirectory(self, waveTestStore, testName):        
        # set the logging directory
        self.LoggingDirectory = waveTestStore['LogsAndResultsInfo']['LogsDir']
        if waveTestStore['LogsAndResultsInfo'].get('TestNameDir', 'False') == "True":    #Using .get() for backward compatibility with existing wml files which won't have this key
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, self.testDir[testName])
        if waveTestStore['LogsAndResultsInfo']['TimeStampDir'] == "True":
            timeStr = time.strftime("%Y%m%d-%H%M%S", time.localtime(time.time()))
            self.start_time=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))
            self.LoggingDirectory = os.path.join(self.LoggingDirectory, timeStr)

    def _createLogDirectory(self):
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
                    msg = "Unable to create logging directory %s.\n%s\n" % (self.LoggingDirectory, str(e))
                    raise Exception, msg
    
    def _loadTestGenericParams(self,
                               waveTestStore, 
                               waveMappingStore,
                               testName):
        self.Trials           = int(waveTestStore['TestParameters']['NumTrials'])
        self.FlowLearningTime = int(waveTestStore['Learning']['FlowLearningTime'])
        self.ClientLearningTime = int(waveTestStore['Learning']['ClientLearningTime'])
        self.SettleTime       = float(waveTestStore['TestParameters']['SettleTime'])
        self.TransmitTime     = float(waveTestStore['TestParameters']['TrialDuration'])
        self.IntendedTransmitTime     = self.TransmitTime
        
        #This sets association rate and association timeout on all the client groups
        #All the client groups shall have the same values for all the 2 parameters below
        #because those params are stored in the waveTestStore dict
        self.AssociateRate    = float(waveTestStore['Connection']['AssocRate'])
        self.AssociateTimeout = float(waveTestStore['Connection']['AssocTimeout'])
        # Note: we removed Association Retry from the UI because we think it's
        # confusing the user and doesn't help the variable connection process at
        # all. 
        self.AssociateRetries = 0
        self.ConnectionType = str(waveTestStore['Connection']['ConnectionType'])
        
        self._setARPrate(waveTestStore, waveMappingStore, testName)
        self.ARPRetries       = int(waveTestStore['Learning']['ArpNumRetries'])
        self.ARPTimeout       = float(waveTestStore['Learning']['ArpTimeout'])
        self.AgingTime        = int(waveTestStore['Learning']['AgingTime'])

        self._loadDUTinfo(waveTestStore)
        #self.UpdateInterval   = float(waveTestStore['WaveEngineConfig']['UpdateInterval'])
        #self.DisplayPrecision = int(  waveTestStore['WaveEngineConfig']['DisplayPrecission'])

    def _setARPrate(self, 
                    waveTestStore, 
                    waveMappingStore, 
                    testName):
        ignoreARPrateF = False
        loopbackTests = ['unicast_latency', 
                         'unicast_max_forwarding_rate',
                         'unicast_packet_loss', 
                         'unicast_unidirectional_throughput']
        trafficMode = self._getTrafficMode(waveMappingStore)
        if testName in loopbackTests and trafficMode == 'loopback':
                #When test is in 'loopback' mode we don't do arps, we ignore arping
                #by setting the rate to 0 
                self.ARPRate = 0
        elif self._anyClientBehindNAT():
            #When we have any client behind NAT, ARP rates aren't feasible
            #over 5 per sec
            WaveEngine.OutputstreamHDL('\nAt least one client group is behind a NAT device.\nIgnoring the user configured ARP rate and setting it to 5 per second\n', WaveEngine.MSG_WARNING)
            self.ARPRate = 5
        else:
            self.ARPRate = float(waveTestStore['Learning']['ArpRate'])
    
    def _anyClientBehindNAT(self):
        """
        Answers if any of the enabled group is behind NAT
        """
        for groupName in self._enabledGroups:
            return self.clientgroupObjs[groupName].isBehindNAT()
           
        return False
    
    def _loadPortOptions(self, waveChassisStore, waveTestStore):
        # Make sure that the ClientContention is a value of 0 through 100
        MagicNumber = int(waveTestStore['TestParameters']['ClientContention'])
        if isnum(MagicNumber):
            if int(MagicNumber) > 100:
                MagicNumber = 100
            elif int(MagicNumber) < 0:
                MagicNumber = 0
            else:
                #Since VCL only looks at the ten's value, round the number to match in the timelog
                MagicNumber = 10 * int(MagicNumber/10)
        else:
            MagicNumber = 0
        
        self.testOptions['ContentionProbability'] = MagicNumber
        
        self.PortOptions['ContentionProbability'] = {}
        self.PortOptions['EnableRxAttenuation'] = {}
        for chassis in waveChassisStore:
            for card in waveChassisStore[chassis]:
                for port in waveChassisStore[chassis][card]:
                    attenVal = waveChassisStore[chassis][card][port]['EnableRxAttenuation']
                    self.PortOptions['EnableRxAttenuation'][port] = attenVal
                    self.PortOptions['ContentionProbability'][port] = self.testOptions['ContentionProbability']
                    
    def _loadFlowInfo(self, waveMappingStore, waveTestStore):
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].interface in WaveEngine.WiFiInterfaceTypes:
                self.flowPhyRates[groupName] = self.clientgroupObjs[groupName].dataPhyRate

                if self.clientgroupObjs[groupName].Wlan80211eQoSEnabled:
                    self.flowWlan80211eQoSAC[groupName] = self.clientgroupObjs[groupName].Wlan80211eQoSAC 
        
        # Import the flow information
        if len(waveMappingStore) > 5:
            if waveMappingStore[3] == 'One To One':
                self.FlowMap = WaveEngine.CreateFlows_Pairs   
            elif waveMappingStore[3] == 'Many To One':
                self.FlowMap = WaveEngine.CreateFlows_Many2One    
            elif waveMappingStore[3] == 'Mesh':
                self.FlowMap = WaveEngine.CreateFlows_Pairs                                               
            else:
                WaveEngine.OutputstreamHDL("Unable to understand the flow mapping of '%s'" % (waveMappingStore[3]), WaveEngine.MSG_ERROR)
                self.FlowMap = WaveEngine.CreateFlows_Pairs
            if waveMappingStore[4].lower() == 'unidirectional':
                self.BiDirectional = False
            else:
                self.BiDirectional = True       
            self.FlowOptions  = {}
            self.FlowOptions['Type'] = str(waveMappingStore[5]['Type'])
            self.FlowOptions['PhyRate'] = float(waveMappingStore[5]['PhyRate'])
            if 'SourcePort' in waveMappingStore[5].keys():
                self.FlowOptions['srcPort'] = int(waveMappingStore[5]['SourcePort'])
            if 'DestinationPort' in waveMappingStore[5].keys():
                self.FlowOptions['destPort'] = int(waveMappingStore[5]['DestinationPort'])
            self.trafficParams = waveTestStore['Traffics']    
            if str(waveMappingStore[5]['Type']) == 'ICMP':
                self.FlowOptions['type'] = int(self.trafficParams.get('Type', 0))  # icmp type
                self.FlowOptions['code'] = int(self.trafficParams.get('Code', 0))  # icmp code
            if str(waveMappingStore[5]['Type']) == 'TCP':
                self.biFlow = True
                # Make sure the traffic dir is unidirectional for stateful TCP
                # FIXME: Remove this line when we support bidirectional TCP flow
                self.BiDirectional = False    


    
    def _loadDUTinfo(self, waveTestStore):
        self.DUTinfo = {}
        self.DUTinfo['WLAN Switch Model'] = waveTestStore['DutInfo']['WLANSwitchModel']
        self.DUTinfo['WLAN Switch Version'] = waveTestStore['DutInfo']['WLANSwitchSWVersion']
        self.DUTinfo['AP Model'] = waveTestStore['DutInfo']['APModel']
        self.DUTinfo['AP SW Version'] = waveTestStore['DutInfo']['APSWVersion']
    
    def _createPortBssidDict(self):
        # create of dict of 'groupName name' : (port name, BSSID). 
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].interface in WE.WiFiInterfaceTypes:
                self.grpBssidDict[groupName] = (self.clientgroupObjs[groupName].portName,
                                                self.clientgroupObjs[groupName].bssid)       

    
    def _createLoginList(self):
        """
        Temp fix for getting the security increment mode work.
        # CHB Add support for user/password list.
        """ 
        # Login List
        self.Logins = {}
        for groupName in self._enabledGroups:
            groupSecConfig = self.clientgroupObjs[groupName].securityConfig
            
            # loop thru all client groups and extract login info
            loginMethod = str(groupSecConfig.get('LoginMethod', 'Single'))
            loginFile   = str(groupSecConfig.get('LoginFile', ''))
            baseUser    = str(groupSecConfig.get('Identity', ''))
            basePass    = str(groupSecConfig.get('Password', ''))
            numClients  = int(str(self.clientgroupObjs[groupName].numClients))
            loginList   = []

            if loginMethod.lower() == 'increment':
                # auto-increment
                # generate list of logins
                for c in range(0, numClients):
                    # generate new username and password from base values
                    newUser = str(baseUser + "%04d" % (c + 1))
                    newPass = str(basePass + "%04d" % (c + 1))
                    loginList.append((newUser, newPass))
                # save this client's list of logins to the main dictionary.
                self.Logins[groupName] = loginList[:]
            elif loginMethod.lower() == 'file':
                # load login data from file.
                # FIXME
                msg = "Login File Mode not implemented."
                raise Exception, msg
                
                # else single mode and nothing to add
            # else no security
            # next group
        # else no client groups       
    
    def _loadInterferenceRates(self, waveBlogStore):
        self.waveBlogStore = {} 
        self.waveBlogStore = waveBlogStore
        for portName in self.waveBlogStore:
            if self.waveBlogStore[portName]['BlogMode'] == 'True':
                blogBins = self.waveBlogStore[portName]['BlogBinSetUpConfig'].keys()
                blogBins.sort()                
                for eachBin in blogBins:
                    binLow = int(self.waveBlogStore[portName]['BlogBinSetUpConfig'][eachBin]['BinLow'])
                    binHigh = int(self.waveBlogStore[portName]['BlogBinSetUpConfig'][eachBin]['BinHigh'])
                    hitRate = int(self.waveBlogStore[portName]['BlogBinSetUpConfig'][eachBin]['BinStrikeProbability'])
                    self.InterferenceRate.append((portName, eachBin, binLow, binHigh, hitRate),)        

############################################################################    
    #Methods used by those tests which use theoretical throughput object
    def _getCGpropertiesForTTobject(self):
        propertiesForTTobject = {}
        for groupName in self._enabledGroups:
            propertiesForTTobject[groupName] = self.clientgroupObjs[groupName].propertiesForTTobject
            
        return propertiesForTTobject
    
    def _loadTrafficMapping(self, waveMappingStore, waveClientTableStore):
        traffMapOption = int(waveMappingStore[0])
        self.traffic = {}
        traffMaps = {
                     0:'Ethernet to Wireless',
                     1:'Wireless to Ethernet',
                     2:'Wireless to Wireless',
                     3:'Ethernet to Ethernet'
                     }
        self.traffic['Map'] = traffMaps[traffMapOption]
        trafficMaps = []
        srcList = waveMappingStore[1]
        destList = waveMappingStore[2]
        trafficMapType = waveMappingStore[3]
        if trafficMapType == 'One To One':
            for source, destination in zip(srcList, destList):
                srcPort = waveClientTableStore[source]['PortName']
                destPort = waveClientTableStore[destination]['PortName']
                trafficMap = [srcPort, destPort]
                trafficMaps.append(trafficMap)
                
        self.traffic['Maps'] = trafficMaps
        self.traffic['direction'] = waveMappingStore[4]
        self.traffic['Mode'] = self._getTrafficMode(waveMappingStore)
            
    def _getTrafficMode(self, waveMappingStore):
        trafficMode = 'infrastructure'
        if len(waveMappingStore) > 6:
            trafficMode = waveMappingStore[6]
            
        return trafficMode
    
    def _getTraffMap(self):
        
        return self.traffic['Map']
    
    def _getTrafficMappingInfo(self):
        
        trafficInfo = {}
        trafficInfo['MapType'] = self.traffic['Map']    
        trafficInfo['Maps'] = self.traffic['Maps']
        trafficInfo['Mode'] = self.traffic['Mode']
        trafficInfo['direction'] = self.traffic['direction']
        
        return trafficInfo
                
    def _getSingletonGroups(self):
        singletonGroups = []
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].numClients == 1:
                singletonGroups.append(groupName) 
        
        return singletonGroups
    
    def _getTheoretRatesBasedOnWEcalc(self, FrameSize,
                                       clientList = None,
                                       flowList = None,
                                       traffic = None):
        """
        This gives the theoreticals calculated by the 
        WaveEngine.TheoreticalThroughput when there is no user specified rate 
        for this frame size
        
        traffic = 'Wireless at on end' is used as part of quick fix to 
        incorporate user specified throughput capability into mesh tests.

        """
        frameSizeStr = str(FrameSize)
        if not clientList:
            clientList = self.ListOfClients
        if not flowList: 
            flowList = self.FlowList
            
        if frameSizeStr in self._userSpecifiedMedCapacityRates:
            TheoreticalMFR = self._userSpecifiedMedCapacityRates[frameSizeStr]
            TheoreticalBPS = self._getBPSfromMFR(FrameSize, TheoreticalMFR,
                                                 traffic)
        else:
            # VPR 4269: use the new Theoretical Calculation from Jerry
            MaxRates = WaveEngine.TheoreticalThroughput(clientList,
                                                        flowList)            
            #Scan the system now
            MaxRates.QuerySystem()
            #Options
            #MaxRates.SetOptions('RTSthreshold', 256)
            # Debug info Jerry might need to fix VPRs
            #WaveEngine.OutputstreamHDL(MaxRates.PrintDebug(), WaveEngine.MSG_DEBUG)

            TheoreticalMFR = MaxRates.ComputeFPS(FrameSize)
            TheoreticalBPS = MaxRates.ComputeBPS(FrameSize)   
    
        return TheoreticalMFR, TheoreticalBPS  
    
    def getPerFlowRateAndMediumCapacityCalc(self):
        autoPerFlowRateAndMedCapCalc = self._getCalculator('perFlowRateAndMediumCap')

        perFlowRateAndMedCapCalc = CF.partial(self._perFlowRateAndMedCapacityCalc,
                                                 autoPerFlowRateAndMedCapCalc,
                                                 self._userSpecifiedMedCapacityRates)
        return perFlowRateAndMedCapCalc
    
    def getMediumCapacityCalculator(self):
        autoMediumCapacityCalculator = self._getCalculator('MediumCapacity')
        mediumCapacityCalculator = CF.partial(self._medCapacityCalucator,
                                                 autoMediumCapacityCalculator,
                                                 self._userSpecifiedMedCapacityRates)
        return mediumCapacityCalculator
    
    def _perFlowRateAndMedCapacityCalc(self, autoPerFlowRateAndMedCapacityCalc,
                                       userSpecifiedMedCapRates, frameSize):
        """
        With the earlier design of unicast_throughput test, we ended with a model
        where the test script expects one theoretical throughput rate.
        This turned out to be problem when there was traffic sent from eth clients
        (e.g., as in Eth to Wifi or as in Wifi to Eth bidirectionl), which was
        solved by using _applyGroupBasedFlowRate(). To allow user settable
        theoretical throughput values, we gotto deliver theoretical throughput
        which works with the earlier mess (and the mess 
        i.e., _applyGroupBasedFlowRate() created later), creating more mess.
        TODO- Change the script core logic. 
        
        """
        if str(frameSize) in userSpecifiedMedCapRates:
            theoreticalMFR =  float(userSpecifiedMedCapRates[str(frameSize)])
            flowMultiple = 0
            if self._shouldApplyGroupBasedRate():
                numOfAPsTransmitting = self._getNumAPs()
                groupBasedFlowMap = self._getGroupBasedFlowMap(self.FlowList)
                numOfWifiClientsTransmitting = 0
                for groupName in groupBasedFlowMap:
                    if self.clientgroupObjs[groupName].interface in WE.WiFiInterfaceTypes:
                        groupFlows = groupBasedFlowMap[groupName]
                        if groupFlows:
                            numOfWifiClientsTransmitting += self.clientgroupObjs[groupName].numClients
                
                flowMultiple = numOfAPsTransmitting + numOfWifiClientsTransmitting
            else:
                flowMultiple = len(self.FlowList)
            perFlowRate = theoreticalMFR/flowMultiple
            mpduCount = 1
        else:
            (perFlowRate, flowMultiple, 
             mpduCount, theoreticalMFR) = autoPerFlowRateAndMedCapacityCalc(frameSize)
        
        return (perFlowRate, flowMultiple, mpduCount, theoreticalMFR)
    
    def _medCapacityCalucator(self, autoMedCapacityCalculator, 
                             userSpecifiedMedCapRates, frameSize):
        """
        If user specified med capacity return it else, compute and return.
        """
        if str(frameSize) in userSpecifiedMedCapRates:
            return float(userSpecifiedMedCapRates[str(frameSize)])
        else:
            return autoMedCapacityCalculator(frameSize)
        
    def _getCalculator(self, calculatee):    #'calculate', eh?, yep! how is that for my english skills
        clientGroupsPhyProperties = self._getCGpropertiesForTTobject()
        singletonGroups = self._getSingletonGroups()
        trafficInfo = self._getTrafficMappingInfo()
        SUT = mediumCapacity.SUT(self.CardList, 
                                 self.ListOfClients, 
                                 clientGroupsPhyProperties, 
                                 self.FlowList,
                                 singletonGroups,
                                 trafficInfo)
        
        trafficMapType = trafficInfo['MapType']        
        if calculatee == 'MediumCapacity':
            if trafficMapType == 'Ethernet to Ethernet':
                #Pass the methods, which would later be invoked
                calculator = SUT.getEthMediumCapacityInFPS
            else:
                calculator = SUT.getWiFiMediumCapacityInFPS 
        elif calculatee == 'perFlowRateAndMediumCap':
            if trafficMapType == 'Ethernet to Ethernet':
                calculator = SUT.getEthPerFlowRateAndMediumCap
            else:
                calculator = SUT.getPerFlowRateAndMediumCap
            
        return calculator
    
    def _getBPSfromMFR(self, frameSize, theoreticalMFR,
                       trafficMapType = None):
        """
        traffic = 'Wireless at on end' is used as part of quick fix to incorporate
        user specified throughput capability into mesh tests.
        """
        if not trafficMapType:
            trafficInfo = self._getTrafficMappingInfo()
            trafficMapType = trafficInfo['MapType']
        if trafficMapType == 'Ethernet to Ethernet':
             return self._getEthBPSfromMFR(frameSize, theoreticalMFR)
        else:
             return self._getWifiBPSfromMFR(frameSize, theoreticalMFR)
         
    def _getEthBPSfromMFR(self, FrameSize, theoreticalMFR):
        return ((8 * FrameSize )* theoreticalMFR)
        
    def _getWifiBPSfromMFR(self, FrameSize, theoreticalMFR):
        
        return ((8 * (FrameSize + 18)) * theoreticalMFR)
############################################################################
    
    def _loadPayLoadInfo(self, waveTestStore):
        traffic = waveTestStore['Traffics']         # dictionary
        payloadContent = str(traffic.get('Content', 'All Zeros'))
        payloadPattern = str(traffic.get('UserPattern', 'fixed'))
        payloadData    = str(traffic.get('PayloadData', "Veriwave"))

        if payloadPattern in [ '1', 'fixed' ]:
            payloadMode = 'fixed'
        else:
            payloadMode = 'repeating'
        payload = ''
        if payloadContent in [ '0', 'All Zeros' ]:
            payload = '00:00:00:00'
        elif payloadContent in [ '1', 'All Ones' ]:
            payload = 'ff:ff:ff:ff'
        elif payloadContent in [ 'Custom' ]:
            if isHexString(payloadData):
                payload = str(payloadData)
            else:
                payload = ascii2hex(payloadData)
        elif isHexString(payloadContent):
            payload = str(payloadContent)
        else:
            msg = "Invalid payload setting."
            raise Exception, msg
        payloadLen = len(payload)/3 + 1
        if payloadLen > 256:
            msg = "Payload pattern is longer than 256 bytes."
            raise Exception, msg
        
        self.FlowOptions[ 'Payload' ] = payload
        if self.biFlow == False: # PayloadLen doesn't apply to 'biflow'
            self.FlowOptions[ 'PayloadLen' ] = payloadLen
        self.FlowOptions[ 'PayloadMode' ] = payloadMode
    
    def _loadMedCapacityData(self, testName, testSpecificConfig):
        self._userSpecifiableMedCapacityTests = ['unicast_max_forwarding_rate',
                                                 'tcp_goodput',
                                                 'unicast_packet_loss',
                                                 'unicast_unidirectional_throughput',
                                                 "mesh_max_forwarding_rate_per_hop", 
                                                 "mesh_throughput_per_hop", 
                                                 "mesh_throughput_aggregate"    
                                                 ]
        self._userSpecifiedMedCapacityRates = odict.OrderedDict()
        if testName in self._userSpecifiableMedCapacityTests:
            if testSpecificConfig['MediumCapacity']['Mode'] == 'Specify':
                #Convert the give tcp segment size to L2 framesize, as that is the metric for medium capacity calculation
                if testName == 'tcp_goodput':
                    for frameSize in testSpecificConfig['MediumCapacity']['SpecifiedMediumCapacityRates']:
                        frameRate = testSpecificConfig['MediumCapacity']['SpecifiedMediumCapacityRates'][frameSize]
                        l2FrameSize = str(self.calculateL2FrameSize(int(frameSize)))
                        self._userSpecifiedMedCapacityRates[l2FrameSize] = self._convertMbpsToFrameRate(frameRate,
                                                                            l2FrameSize)
                else:
                    for frameSize in testSpecificConfig['MediumCapacity']['SpecifiedMediumCapacityRates']:
                        specifiedRate = testSpecificConfig['MediumCapacity']['SpecifiedMediumCapacityRates'][frameSize]
                        self._userSpecifiedMedCapacityRates[frameSize] = self._convertMbpsToFrameRate(specifiedRate,
                                                                                                      frameSize)

    def _convertMbpsToFrameRate(self, value, frameSize):
        value = float(value)
        frameSize = int(frameSize)
        return (value* 1000000)/(8 * frameSize)     
    
    def _anyUserSpecifiedTheoreticals(self, testName = 'NotGoodput'):
        userSpecifiedFrameSizeList =  self._userSpecifiedMedCapacityRates.keys()
        if testName == 'tcp_goodput':
            frameSizeList = [self.calculateL2FrameSize(segSize) for segSize in 
                             self.FrameSizeList]
        else:
            frameSizeList = [str(frameSize) for frameSize in self.FrameSizeList]
        
        return bool(set(userSpecifiedFrameSizeList).intersection(set(frameSizeList)))
    
    def _getMedCapacityLegend(self):
        legend = 'Medium Capacity'
        if self._anyUserSpecifiedTheoreticals():
            legend += "(<i>At least one of the Theoretical values shown is user specified.</i>)"

    def loadFile(self, filename):
        """
        Given a filename, load a WaveApp-generated XML configuration
        into the storage dictionaries.
        Returns True for success, False for error.
        """

        try:
            myParser = wmlParser.parseWml(filename)
            (waveChassisStore, 
              wavePortStore, 
              waveClientTableStore, 
              waveSecurityStore, 
              waveTestStore, 
              waveTestSpecificStore, 
              waveMappingStore, 
              waveBlogStore) = myParser.parseWmlConfig(filename) 
        except:
            WaveEngine.OutputstreamHDL("ERROR: loadFile could not parse '%s'\n" % (str(filename)), WaveEngine.MSG_ERROR)
            return False
        else:
            # no errors, copy over new dictionaries.
            self.loadData(waveChassisStore, 
                           wavePortStore, 
                           waveClientTableStore, 
                           waveSecurityStore, 
                           waveTestStore, 
                           waveTestSpecificStore, 
                           waveMappingStore, 
                           waveBlogStore)
        return True
                
    def initailizeCSVfile(self):
        import os.path
        self.ResultsForCSVfile = []
        
        #Print Version fields for CSV file
        for (key, value) in self.OtherInfoData.items():
            self.ResultsForCSVfile.append((key, value))        
        self.ResultsForCSVfile.append(('WaveEngine Version', WaveEngine.full_version))
        self.ResultsForCSVfile.append(('Framework Version', WaveEngine.action.getVclVersionStr()))
        self.ResultsForCSVfile.append(('Firmware Version', WaveEngine.chassis.version))
        self.ResultsForCSVfile.append(('', ''))        
        #___________________________________DataExport___________________________________ 
        self.Version_list_db = [('WaveEngineVersion', WaveEngine.full_version),('FrameworkVersion', WaveEngine.action.getVclVersionStr()),('FirmwareVersion', WaveEngine.chassis.version)]
        self.ResultsForCSVfile.append(('TestID', str(self.TestID)))
        self.start_time=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))
        #___________________________________DataExport___________________________________ 
        for eachKey in self.DUTinfo.keys():
            self.ResultsForCSVfile.append((eachKey, self.DUTinfo[eachKey]))
        self.ResultsForCSVfile.append((),)
        FullPathFilename = os.path.join(self.LoggingDirectory, self.CSVfilename)
        try:
            _Fhdl = open(FullPathFilename, 'w')
            _Fhdl.close()
        except:
            WaveEngine.OutputstreamHDL("Error: CSV file %s is locked by another program.\n" % (FullPathFilename), WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException
        
        #Print Version Number
        for (key, value) in self.OtherInfoData.items():
            WaveEngine.OutputstreamHDL("%s: %s\n" % (key, value), WaveEngine.MSG_OK)
            WaveEngine.WriteDetailedLog([ key, value ])
        WaveEngine.PrintVersionInfo()
        WaveEngine.WriteDetailedLog(('TestID', str(self.TestID)))
        for eachKey in self.DUTinfo.keys():
            WaveEngine.WriteDetailedLog([eachKey, self.DUTinfo[eachKey]])
        WaveEngine.WriteDetailedLog([''])
        
    def configurePorts(self):
        self.isTestEnabled()
        
        self.setCardLists()
        
        if WaveEngine.ConnectPorts(self.CardList, self.CardMap, self.PortOptions) < 0:
            raise WaveEngine.RaiseException
        
        # VPR 4821: wait for Ethernet link to be up
        if WaveEngine.WaitforEthernetLink(self.CardList) == -1:
            raise WaveEngine.RaiseException
        
        # if traffic type is TCP, we need to enable TCP on the ports
        flowType = self.FlowOptions.get('Type', '')
        if flowType == 'TCP':
            WaveEngine.PortEnableFeature(self.CardList, 'tcp')
    
    def setCardLists(self):
        """
        set self.CardList, which is present for all the tests.
        For those tests in which wavemapping store is valid, we have
        self.SourceClients and self.DestClients; For these tests create
        self.SrcCardList, self.DesCardList
        """
        clientTuples = self.getClientTuples()
        
        self.CardList = self.getCardList(clientTuples)
        
        if self.SourceClients:
            self.SrcCardList = self.getCardList(self.SourceClients)
            
        if self.DestClients:
            self.DesCardList = self.getCardList(self.DestClients)
            
    def getCardList(self, clientTuples):
        """
        clientTuples is the clientTuple in the structure returned by 
        WaveEngine.Import_ClientLists() and expected by 
        WaveEngine.CreateClients().
        
        Return the list of cards used by all the clients in the clientTuples 
        """
        cardList = []
        # Make sure the list does not have duplicates
        for CurrentClient in clientTuples:
            PortList = CurrentClient[1]
            if isinstance(PortList, list):
                for PortName in PortList:
                    if not PortName in cardList:
                        cardList.append(PortName)
            else:
                if not PortList in cardList:
                    cardList.append(PortList)

        return  cardList
    
    
    def _getSrcandDestCardLists(self):
        #VPR 4700 - create my own cardLists instead of Basetest
        SrcCardList = []
        DesCardList = [] 
        for eachflow in self.FlowList.keys():
            ( src_port, src_client, des_port, des_client ) = self.FlowList[eachflow]
            if not src_port in SrcCardList:
                SrcCardList.append(src_port)
            if not des_port in DesCardList:
                DesCardList.append(des_port)
        
        return SrcCardList, DesCardList
     
    def getClientTuples(self):
        clientTuples = self.SourceClients + self.DestClients
        
        return  clientTuples
         
    def VerifyBSSID_MAC(self):
        # set random seed for psuedo-random MAC addresses that are repeatable.
        random.seed(self.RandomSeed)
        if self.connectMode != 'loopback':
            if  not WaveEngine.GroupVerifyBSSID_MAC([self.SourceClients, self.DestClients], self.BSSIDscanTime):
                self.SavePCAPfile = True
                raise WaveEngine.RaiseException
            
    def _createDictOfClientTuples(self, listOfclientTuples):
        """
        For those tests which rely on self.SourceClients, self.DestClients which
        are list of the client tuples, this method converts the list into a dict
        with the group name as key, need this structure of the client tuples
        for the new createClients() which accepts a dict of client tuples
        """
        clientTupleDict = {}
        for groupTuple in listOfclientTuples:
            groupName = groupTuple[0]
            clientTupleDict[groupName] = [groupTuple]
            
        return clientTupleDict
    
    def _updateClientLists(self, srcClients, destClients):
        #Re-initialise
        self.ListofSrcClient = odict.OrderedDict()
        self.ListofDesClient = odict.OrderedDict()
        self.ListOfClients = odict.OrderedDict()
        for group in srcClients:
            self.ListofSrcClient.update(srcClients[group])
        
        for group in destClients:
            self.ListofDesClient.update(destClients[group])
            
        self.ListOfClients.update(self.ListofSrcClient)
        self.ListOfClients.update(self.ListofDesClient)
        self.TotalClients  = len(self.ListOfClients)
        
    def createClients(self, clientTuples = {}):
        """
        Method for those tests which do not have clients broken down to 
        self.SourceClients and self.DestClients
        """
        if clientTuples:
            createdClients, clientList = self._createClientsFromTuples(clientTuples)
            return (createdClients, clientList)
        else:
            #self._creatClientsFromSrcDestClients()
            #self.createClientGroups()
            self._createClientsFromClientGroups()
            
        if self.connectMode == 'loopback':
            self._setAdhocMode()
    
    def _createClientsFromTuples(self, clientTuples):
        from odict import OrderedDict
        
        createdClients = OrderedDict()
        clientList     = OrderedDict()
        #self.doPortScan(clientTuples)
        random.seed(self.RandomSeed)
        #Verify BSSID and MACs
#        allClients = []
#        for group in clientTuples:
#            allClients.append([clientTuples[group]])
#        self.VerifyBSSID_MAC(allClients)
        
        for group in clientTuples.keys():
            createdClients[group] = WaveEngine.CreateClients(clientTuples[group],
                                                            LoginList=self.Logins)
            self.clientgroupObjs[group].addClients(createdClients[group])
            clientList.update(createdClients[group])
            
        return (createdClients, clientList)
    
    """
    def createClientGroups(self):
        #Modify this logic of creating client groups, for now working on the 
        #model of self.SourceClients, self.DestClients being mutually exclusive
        for eachGroup in self.SourceClients + self.DestClients:
            groupName = eachGroup[0]
            mpduAggregFlag = self._getMPDUaggregationInfo(groupName)
            groupInfo = eachGroup + (mpduAggregFlag,)
            self.clientgroupObjs[groupName] = ClientGroup(*groupInfo)
    """
            
    def _createClientsFromClientGroups(self):
        sourceGroups, destGroups = self._getSrcDestGroups()
        
        for groupName in self._enabledGroups:

            groupClientTuple = self.clientgroupObjs[groupName].groupTuple
            try:
                #sending self.Logins which contains all the groups info is OK.
                createdClients = WaveEngine.CreateClients([groupClientTuple],
                                                         LoginList=self.Logins)
            except:
                WaveEngine.OutputstreamHDL("Failed to create the clients, terminating test.", 
                                           WaveEngine.MSG_ERROR)
                raise WaveEngine.RaiseException
            
            self.clientgroupObjs[groupName].clients = createdClients
            
            #Get rid of this notion of client groups being either source or 
            #destination (self.ListofSrcClient, self.ListofDesClient).
            #Below ought to be changed for making more shift of paradigm 
            #(clientgroup, client treated as objects which uses self.clientgroupObjs)
            if groupName in sourceGroups:
                self.ListofSrcClient.update(createdClients)
            elif groupName in destGroups:
                self.ListofDesClient.update(createdClients)
                
            self.ListOfClients.update(createdClients)
        
        if (len(self.ListofSrcClient) < len(self.SourceClients) 
                or 
           len(self.ListofDesClient) < len(self.DestClients)):
            
            raise WaveEngine.RaiseException
        
        self.TotalClients  = len(self.ListOfClients)
    
    def _getSrcDestGroups(self):
        sourceGroups = []
        destGroups =[]
        
        for eachGroup in self.SourceClients:
            groupName = eachGroup[0]
            sourceGroups.append(groupName)
        for eachGroup in self.DestClients:
            groupName = eachGroup[0]
            destGroups.append(groupName)
        
        return sourceGroups, destGroups
    """
    def _creatClientsFromSrcDestClients(self):
        try:
            self.ListofSrcClient = WaveEngine.CreateClients(self.SourceClients, 
                                                            LoginList=self.Logins)
            self.ListofDesClient = WaveEngine.CreateClients(self.DestClients, 
                                                            LoginList=self.Logins)
        except:
            WaveEngine.OutputstreamHDL("Failed to create the clients, terminating test.", 
                                       WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException
    
        if len(self.ListofSrcClient) < len(self.SourceClients) \
                or \
           len(self.ListofDesClient) < len(self.DestClients):
            
            raise WaveEngine.RaiseException
        
        self.ListOfClients = {}
        self.ListOfClients.update(self.ListofSrcClient)
        self.ListOfClients.update(self.ListofDesClient)
        self.TotalClients  = len(self.ListOfClients)
    """
    
    def _setAdhocMode(self):
        # If loopback mode, set the BSSID to the destination MAC address
        try:
            WaveEngine.SetLoopbackMode(self.ListofSrcClient, self.ListofDesClient)
        except:
            WaveEngine.OutputstreamHDL("Failed to set the ad hoc mode, terminating test.", WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException
        
    def getClientList(self):
        """
        Return the clients to be connected, these are clients created by
        WaveEngine.CreateClients() or similary method.
        """
        return self.ListOfClients
    
    def connectClients(self, clientList = ()):
        if not clientList:
            clientList = self.getClientList()
            
        AssociateRate     = float(self.AssociateRate)
        AssociateRetries  = float(self.AssociateRetries)
        AssociateTimeout  = float(self.AssociateTimeout)
        TotalTimeout = ((len(clientList)/AssociateRate) + 
                        AssociateTimeout * (1 + AssociateRetries))
        ConnType = self.ConnectionType
        
        if WaveEngine.ConnectClients(clientList, AssociateRate, 
                                     AssociateRetries, AssociateTimeout, 
                                     TotalTimeout, ConnType) < 0:
            self.SavePCAPfile = True
            self.Print("Connecting Clients Failed\n", 'ERR')
            raise WaveEngine.RaiseException

############################### connectTcpFlows ################################
# this function handles TCP connect, disconnect and resetConnection operations
#
# input:
# - self.FlowList: dict of biflows
# - operation:
#   'connect': issue biflow.connect() to initiate the TCP 3-way handshake for all biflows.
#              The achieved state will be 'READY' for all biflows
#   'disconnect': issue biflow.disconnect() to disconnect the established TCP connection
#                 The achieved state will be 'IDLE' for all biflows.
#   'reset': issue biflow.resetConnection() to reset the TCP connection. Note that it
#            will initiate the reset on both side to guarantee that we're back to 'IDLE' state.
# output:
# - status: -1 if TCP operation failed, 0 if successful
#
    def connectTcpFlows(self, flowList, operation='connect'):
        if flowList == []:
            # Empty list
            return
        if operation == 'connect':
            status = WaveEngine.ConnectBiflow(flowList.keys())
        elif operation == 'disconnect':
            status = WaveEngine.ConnectBiflow(flowList.keys(), totalTimeOut=10, 
                                   expectedState=WaveEngine.BIFLOW_STATE_IDLE, operation='disconnect')
        elif operation == 'resetConnection':
            status = WaveEngine.ConnectBiflow(flowList.keys(), totalTimeOut=10, 
                                   expectedState=WaveEngine.BIFLOW_STATE_IDLE, operation='resetConnection')  
        else:
            WaveEngine.OutputstreamHDL("Error: invalid operation for connectTcpFlows()", WaveEngine.MSG_ERROR)
            return -1   
        return status
        
    def configureFlows(self, numOfSession=1, mapType='One To One', connectBiflow=True):        
        # Set the flows up initially with the learning parameters       
        self.FlowOptions['NumFrames']    = self.FlowOptions.get('NumFrames', int(self.FlowLearningTime * self.FlowLearningRate))
        self.FlowOptions['IntendedRate'] = self.FlowOptions.get('IntendedRate', self.FlowLearningRate)
        self.FlowOptions['RateMode']     = 'pps'
                
        srcClientKeys = self.ListofSrcClient.keys()
        dstClientKeys = self.ListofDesClient.keys()
        #Sort the client lists to keep the flow mappings in sync
        #with the display in the mapping page
        srcClientKeys.sort()
        dstClientKeys.sort()
        
        #patt = re.compile(r'Group_\d+_\d+') # Group_d_ddd  
        Prefix = ''
        hasPorts = False
        if self.trafficParams.has_key('SourcePort') and self.trafficParams.has_key('DestinationPort'):
            self.FlowOptions['srcPort'] = self.trafficParams['SourcePort']
            self.FlowOptions['destPort'] = self.trafficParams['DestinationPort']
            incrSourcePort = 0
            if self.trafficParams.get('IncrSourcePort', 'False') == 'True':
                incrSourcePort = 1
            incrDestPort = 0
            if self.trafficParams.get('IncrDestPort', 'False') == 'True':
                incrDestPort = 1            
            hasPorts = True
            
        biflowDict = {}
        
        srcGrpList, destGrpList = self._getSrcDestGrpList(mapType)
        
        for srcClientGrp, dstClientGrp in zip(srcGrpList, destGrpList):
            srcGroupName = srcClientGrp[0]
            dstGroupName = dstClientGrp[0]

            ListofSrcClient, ListofDesClient = self._getListofSrcDestClients(mapType,
                                                                             srcClientKeys,
                                                                             dstClientKeys,
                                                                             srcClientGrp,
                                                                             dstClientGrp)
                    
            for srcClientName, dstClientName in zip(ListofSrcClient, ListofDesClient):    
                if self.flowPhyRates.has_key(srcGroupName):  
                    self.FlowOptions['PhyRate'] = self.flowPhyRates[srcGroupName] 
                elif self.flowPhyRates.has_key(dstGroupName): 
                    self.FlowOptions['PhyRate'] = self.flowPhyRates[dstGroupName]                     
                # FIXME: uncomment these 4 lines when VPR 4698 is fixed
                #if self.flowWlan80211eQoSAC.has_key(srcGroupName):
                #    self.FlowOptions['QOS'] = WaveEngine.WLAN_80211E_QOS_AC_TO_UP_MAP[self.flowWlan80211eQoSAC[srcGroupName]]    
                #elif self.FlowOptions.has_key('QOS'): 
                #    del self.FlowOptions['QOS']                
                if hasPorts == True:
                    if incrSourcePort == 0:  
                        self.FlowOptions['srcPort'] = self.trafficParams['SourcePort']
                    if incrDestPort == 0: 
                        self.FlowOptions['destPort'] = self.trafficParams['DestinationPort']                                                       
                for i in range(numOfSession):
                    if hasPorts == True and numOfSession > 1:
                        Prefix = str(self.FlowOptions['srcPort']) + '_' + str(self.FlowOptions['destPort']) + '_'  
                    flowInstance = self.FlowMap(
                        dict([(srcClientName, self.ListofSrcClient[srcClientName])]), 
                        dict([(dstClientName, self.ListofDesClient[dstClientName])]), 
                        self.BiDirectional, self.FlowOptions, Prefix) 
                    if self.FlowOptions['Type'] == 'TCP':
                        biflowDict.update(flowInstance)
                    if i == 0 and self.FlowOptions['Type'] != 'TCP':
                        # only call doArpExchange() for non TCP traffic
                        # If client pair has multiple session, updates ArpList dict 
                        # only for the 1st client
                        self.ArpList.update(flowInstance)
                    self.FlowList.update(flowInstance)
                    if hasPorts == True:
                        nextSrcPort = (int(self.FlowOptions['srcPort']) + 1) & 0xffff
                        nextDestPort = (int(self.FlowOptions['destPort']) + 1) & 0xffff
                        if nextSrcPort == 0:
                            nextSrcPort = 1
                        if nextDestPort == 0:
                            nextDestPort = 1
                        self.FlowOptions['srcPort'] = str(nextSrcPort)
                        self.FlowOptions['destPort'] = str(nextDestPort)                                                    
                
        self._saveBiFlowInfo(biflowDict, connectBiflow)
        
        self._createFlowGroup(self.FlowList, "XmitGroup")

        self.TotalFlows = len(self.FlowList)        
        
        self._configureClientObjectsFlows(self.FlowList)
    
        if self.connectMode == 'loopback':
            self.setFlowLoopbackMode()

        self.setFlowAMPDUaggregation()
        
        self.setNATflag()
    
    def _createFlowGroup(self, flowList, flowGroupName):
        
        self.flowGroupObjs[flowGroupName] = FlowGroupObj(flowList, flowGroupName)
        
        if len(flowList) > 0:    
            WE.CreateFlowGroup(flowList, flowGroupName)
        else:
            WE.VCLtest("flowGroup.create('%s')" %flowGroupName)
            
    def _destroyFlowGroup(self, flowGroupName):
        del self.flowGroupObjs[flowGroupName]
    
    def _addFlowToFlowGroup(self, flowGroupName, flowName):
        WE.VCLtest("flowGroup.read('%s')"%flowGroupName)
        WE.VCLtest("flowGroup.add('%s')" %flowName)
        WE.VCLtest("flowGroup.write('%s')"%flowGroupName)  
        self.flowGroupObjs[flowGroupName].addFlowName(flowName)
        
    def _isFlowGroupReadyToTransmit(self, flowGroupName):
        if flowGroupName not in self.flowGroupObjs:
            self.Print("Property of an invalid Flow Group '%s' requested"%flowGroupName, 
                       'WARN')
        else:
            return self.flowGroupObjs[flowGroupName].isReadyToStart()
        
        return None
    
    def _waitUntilFlowGroupReadyToStart(self, flowGroupName):
        while True:
            readyState = self._isFlowGroupReadyToTransmit(flowGroupName)
            if readyState == False:
                self.Print('\nWaiting for the flows to stop...','OK')
                time.sleep(0.1)
            else: 
                return readyState
    
    def _startFlowGroup(self, flowGroupName):
        """
        """
        readyState = self._waitUntilFlowGroupReadyToStart(flowGroupName)
        if readyState == None:
            #raise exception?
            return None
        elif readyState: 
            WE.VCLtest("action.startFlowGroup('%s')" %flowGroupName)
    
    def _doFlowLearning(self, FuncRealTime, PassedParam):
        if self.FlowLearningTime > 0:
            #Do the Flow learning
            PassedParam['Title'] = "Training DUT/SUT:"
            self._transmitIteration(self.FlowLearningTime, 0, 
                                         self.UpdateInterval, "XmitGroup", 
                                         True, FuncRealTime, PassedParam)
            WaveEngine.OutputstreamHDL("\n", WaveEngine.MSG_OK)
    
            if self.FlowOptions['Type'] == 'TCP':
                # Wait for 2 seconds to make sure we get all the TCP ACKs
                WaveEngine.Sleep(2, 'TCP settling time') 
                
    def _transmitIteration(self, TXtime, RXtime, UpdateTime, GroupName, 
                           StopTX, UpdateFunction, PassedParameters):
        readyState = self._waitUntilFlowGroupReadyToStart(GroupName)
        if readyState == None:
            return None
        elif readyState:
            retVal = WE.TransmitIteration(TXtime, RXtime, UpdateTime, 
                                          GroupName, StopTX, UpdateFunction, 
                                          PassedParameters)

        return retVal
    
    def _transmitIterationWithBlogCards(self, TXtime, RXtime, UpdateTime, 
                                        GroupName, StopTX, UpdateFunction, 
                                        PassedParameters, waveBlogStore):
        readyState = self._waitUntilFlowGroupReadyToStart(GroupName)
        if readyState == None:
            return None
        elif readyState:
            WE.TransmitIterationWithBlogCards(TXtime, RXtime, UpdateTime, 
                                            GroupName, StopTX, UpdateFunction, 
                                            PassedParameters, waveBlogStore)
            
    def _getSrcDestGrpList(self, mapType):
        srcGrpList = []
        destGrpList = []
        if mapType == 'One To One':
            # handle different number of src & dest client groups here.
            tmpSrcGrps = []
            tmpDstGrps = []
            for item in self.SourceClients:
                for i in range(item[7][0]):
                    tmpSrcGrps.append(item[0])
            for item in self.DestClients:
                for i in range(item[7][0]):
                    tmpDstGrps.append(item[0])    
            tmpGrpDict = odict.OrderedDict()
            for srcGrpName, dstGrpName in zip(tmpSrcGrps, tmpDstGrps):
                if tmpGrpDict.has_key(srcGrpName+"#"+dstGrpName):
                    tmpGrpDict[srcGrpName+"#"+dstGrpName] += 1
                else:
                    tmpGrpDict[srcGrpName+"#"+dstGrpName] = 1
            for key, item in tmpGrpDict.iteritems():
                grpList = re.split('#', key) 
                srcGrpList.append((grpList[0], item))  
                destGrpList.append((grpList[1], item))                                    
        else:
            for item in self.SourceClients:
                # append group name and num of clients
                srcGrpList.append((item[0], item[7][0])) 
            for item in self.DestClients:
                destGrpList.append((item[0], item[7][0]))
                
        return srcGrpList, destGrpList
    
    def _getListofSrcDestClients(self, mapType, srcClientKeys, dstClientKeys,
                                 srcClientGrp, dstClientGrp):
        ListofSrcClient = []
        ListofDesClient = []
        if mapType == 'Many To One':
            dstClientName = dstClientKeys.pop(0)
            for i in range(srcClientGrp[1]):
                ListofSrcClient.append(srcClientKeys.pop(0))
                ListofDesClient.append(dstClientName)                 
        elif mapType == 'One To Many':
            srcClientName = srcClientKeys.pop(0)
            for i in range(dstClientGrp[1]):
                ListofSrcClient.append(srcClientName)
                ListofDesClient.append(dstClientKeys.pop(0))           
        else:
            for i in range(srcClientGrp[1]):  
                ListofSrcClient.append(srcClientKeys.pop(0))                
                ListofDesClient.append(dstClientKeys.pop(0))
                
        return ListofSrcClient, ListofDesClient
    
    def _saveBiFlowInfo(self, biflowDict, connectBiflow):
        self.biflowDict = biflowDict
        self.connectBiflow = connectBiflow
    
    def _getBiFlowInfo(self):
        return self.biflowDict, self.connectBiflow
    
    def _configureClientObjectsFlows(self, flowList):
        """
        For each client object in self.clientgroupObjs[group], 
        assign their flow information (flows, originating flows,
        destinating flows etc)
        We don't have client group based flow information, agree, we have it 
        in the above configureFlows() method, but it ain't easily decipherable
        thus we for now use the client based info, which is present in the flow
        tuple
        """
        #Get client to clientGroup map
        allClients = self._getAllClients()
        for flowName in flowList:
            ( src_port, src_client, des_port, des_client ) =  flowList[flowName]
            clientObj = allClients[src_client]
            peerName, peerPort = des_client, des_port
            self._addFlowToClient(clientObj, flowName, 
                                  peerName, peerPort,
                                  'sent')
            
            clientObj = allClients[des_client]
            peerName, peerPort = src_client, src_port
            self._addFlowToClient(clientObj, flowName, 
                                  peerName, peerPort,
                                  'received')
                                    
        return True
        
    def _getAllClients(self):
        """
        Return clients only on those ports which are enabled 
        """
        allClients = {}
        for groupName in self._enabledGroups:
            thisGroupClients = self.clientgroupObjs[groupName].clients
            allClients.update(thisGroupClients)
        
        return allClients
    
    def _getGroupNameOfClient(self, clientName):
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].isTheClientMember(clientName):
                return groupName
        
        print "Couldn't find a Group of the client %s"%clientName
         
    def _addFlowToClient(self, clientObj, 
                         flowName, 
                         peerName, peerPort,
                         type):
        if type == 'sent':
            clientObj.addOriginatingFlow(flowName, peerName, peerPort)
        elif type == 'received':
            clientObj.addDestinatingFlow(flowName, peerName, peerPort)
    
        return True
            
    def setFlowLoopbackMode(self):
        """
        Disable AC params for loopback mode
        """
        for groupName in self._enabledGroups:
            groupClients = self.clientgroupObjs[groupName].clients
            
            for clientName in groupClients:
                
                originatingFlows = groupClients[clientName].getOriginatingFlows()
                
                flowType, flowModType = self._getFlowTypeFlowModType()
                
                if originatingFlows:
                    for flowName in originatingFlows.keys():
                        if self.biFlow == True:
                            self._setBiflowACparamsfromBSS(flowName, 
                                                           flowType, 
                                                           flowModType)
                        else:
                            self._setFlowACparamsfromBSS(flowName, 
                                                         flowType, 
                                                         flowModType)

    def _setBiflowACparamsfromBSS(self, flowName, flowType, flowModType):
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName))

        self._setBiflowACparamsInAdirection(flowModType, 'Forward')
        self._setBiflowACparamsInAdirection(flowModType, 'Reverse')
        
        WaveEngine.VCLtest("%s.write('%s')" % (flowType, flowName))
 
    def _setBiflowACparamsInAdirection(self, flowModType, direction):
        WaveEngine.VCLtest("%s.readBiflow('%s')" % (flowModType, direction))
        WaveEngine.VCLtest("%s.setAcParamFromBss('%s')" % (flowModType, 'off'))  
        WaveEngine.VCLtest("%s.modifyBiflow('%s')" % (flowModType, direction))

    def _setFlowACparamsfromBSS(self, flowName, flowType, flowModType):
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName))
        WaveEngine.VCLtest("%s.readFlow()" % (flowModType))
        WaveEngine.VCLtest("%s.setAcParamFromBss('%s')" % (flowModType, 'off'))  
        WaveEngine.VCLtest("%s.modifyFlow()" % (flowModType))
        WaveEngine.VCLtest("%s.write('%s')" % (flowType, flowName))


    def _getFlowTypeFlowModType(self):
        if self.biFlow == True:
            flowType = 'biflow'
            flowModType = 'biflowQos'
        else:
            flowType = 'flow'
            flowModType = 'wlanQos'
        
        return flowType, flowModType
    
    def getMPDUcount(self, frameSize):
        return mediumCapacity.getMPDUcount(frameSize)

    def _getAMPDUsegregatedPipeFlows(self, flowList):
        ampduFlowList = self.getAMPDUaggregateFlows()
        ampduPipeFlows = {}
        nonAmpduPipeFlows = {}
        allFlows = flowList.keys()
        for flowName in allFlows:
            if flowName in ampduFlowList:
                ampduPipeFlows[flowName] = self.FlowList[flowName]
            else:
                destClientOfFlow = self.FlowList[flowName][3]
                destGroupOfFlow = self._getGroupNameOfClient(destClientOfFlow)
                aggregInDestEnd = self.clientgroupObjs[destGroupOfFlow].isMPDUaggregationON()
                if aggregInDestEnd:
                    ampduPipeFlows[flowName] = self.FlowList[flowName]
                else:
                    nonAmpduPipeFlows[flowName] = self.FlowList[flowName]
    
        return ampduPipeFlows, nonAmpduPipeFlows
    
    def setFlowAMPDUaggregation(self):
        """
        """
        ampduAggregateFlows = self.getAMPDUaggregateFlows()
        
        self.setACandMPDUaggregation(ampduAggregateFlows, 'Best Effort')
    
    def setACandMPDUaggregation(self, ampduAggregateFlows, category):
        #Only best effort required
        if category == 'Best Effort':
            if self.biFlow == True:
                flowType = 'biflow'
                flowModType = 'biflowQos'
            else:
                flowType = 'flow'
                flowModType = 'wlanQos'
            for flowName in ampduAggregateFlows:
                if self.biFlow == True:
                    self._setBiflowACandMPDUaggregation(flowName,flowType, flowModType)
                else:
                    self._setFlowACandMPDUaggregation(flowName,flowType, flowModType)
                    
    def _setBiflowACandMPDUaggregation(self, flowName,flowType, flowModType):
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName))
        
        self._setBiflowACandMPDUaggregInAdirection(flowModType, 'Forward')
        
        self._setBiflowACandMPDUaggregInAdirection(flowModType, 'Reverse')
        
        WaveEngine.VCLtest("%s.write('%s')" % (flowType, flowName))

    def _setBiflowACandMPDUaggregInAdirection(self, flowModType,
                                              direction):
        WaveEngine.VCLtest("%s.readBiflow('%s')" % (flowModType, direction))
        WaveEngine.VCLtest("%s.setTid(%s)" % (flowModType, 0))    
        WaveEngine.VCLtest("%s.setTgaPriority(%s)" % (flowModType, 0))
        WaveEngine.VCLtest("%s.setUserPriority(%s)" % (flowModType, 0))

        if direction == 'Forward':
            aggregSwitch = 'on'
        elif direction == 'Reverse':
            aggregSwitch = 'off'
        else:
            print 'Invalid Biflow direction'
        WaveEngine.VCLtest("%s.setMPDUAggregationEnable('%s')" % (flowModType, 
                                                                  aggregSwitch))

        if self.connectMode == 'loopback':
            WaveEngine.VCLtest("%s.setAcParamFromBss('%s')" % (flowModType, 'off'))  
        
        WaveEngine.VCLtest("%s.setAckPolicy('block')" % (flowModType))
        WaveEngine.VCLtest("%s.modifyBiflow('%s')" % (flowModType, direction))

    def _setFlowACandMPDUaggregation(self, flowName,flowType, flowModType):
        WaveEngine.VCLtest("%s.read('%s')" % (flowType, flowName))
    
        WaveEngine.VCLtest("%s.readFlow()" % (flowModType))
        WaveEngine.VCLtest("%s.setTid(%s)" % (flowModType, 0))    
        WaveEngine.VCLtest("%s.setTgaPriority(%s)" % (flowModType, 0))
        WaveEngine.VCLtest("%s.setUserPriority(%s)" % (flowModType, 0))
        WaveEngine.VCLtest("%s.setMPDUAggregationEnable('%s')" % (flowModType, 'on'))
        if self.connectMode == 'loopback':
            WaveEngine.VCLtest("%s.setAcParamFromBss('%s')" % (flowModType, 'off'))  
        WaveEngine.VCLtest("%s.setAckPolicy('block')" % (flowModType))
        WaveEngine.VCLtest("%s.modifyFlow()" % (flowModType))
        WaveEngine.VCLtest("%s.write('%s')" % (flowType, flowName))

    def getAMPDUaggregateFlows(self):
        """
        Return a list of flow names for which ampdu aggregation is to be set
        """
        ampduAggregateFlows = []
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].isMPDUaggregationON():
                groupClients = self.clientgroupObjs[groupName].clients
                for clientName in groupClients:
                    originatingFlows = groupClients[clientName].getOriginatingFlows()
                    if originatingFlows:
                        ampduAggregateFlows += originatingFlows.keys()
                    
        return ampduAggregateFlows
    
    def _connectBiFlows(self):
        biflowDict, connectBiflow = self._getBiFlowInfo()
        if biflowDict != {} and connectBiflow == True:
            # do biflow.connect
            if WaveEngine.ConnectBiflow(biflowDict.keys()) < 0:
                self.SavePCAPfile = True
                raise WaveEngine.RaiseException
            
    def setQoShandshakeFlag(self):
        # Skip the QoS handshakes if in loopback mode
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].isMPDUaggregationON():
                groupClients = self.clientgroupObjs[groupName].clients
                clientNames = groupClients.keys()
                for clientName in clientNames:
                    WaveEngine.VCLtest("mc.read('%s')"%clientName)
                    WaveEngine.VCLtest("mc.doQosHandshake('%s')"%clientName)
                    if self.connectMode != 'loopback':
                        if not self.pollMCstatus(clientName, 7, 5.0):
                            WaveEngine.OutputstreamHDL("Didn't succeed with the QoS Handshake", WaveEngine.MSG_ERROR)

    def pollMCstatus(self, clientName, expectedState, timeout):
        timeStart = time.time()
        while True:
            state = WaveEngine.VCLtest("mc.checkStatus('%s')"%clientName)
            if state == expectedState:
                return True
            else:
                time.sleep(0.1)
            if time.time() > timeStart + timeout:
                return False
            
    def setNATflag(self):
        for groupName in self._enabledGroups:
            if self.clientgroupObjs[groupName].isBehindNAT():
                groupClients = self.clientgroupObjs[groupName].clients
                for clientName in groupClients:
                    clientObj = groupClients[clientName]
                    destinatingFlows = clientObj.getDestinatingFlows()
                    self._setNATflagOnFlows(destinatingFlows)

    def _setNATflagOnFlows(self, flows):
        flows, biflows = self._segregateFlowsAndBiflows(flows)        
        for flowName in flows:
            WaveEngine.VCLtest("flow.read('%s')"%flowName)
            WaveEngine.VCLtest("flow.setNatEnable('on')")
            WaveEngine.VCLtest("flow.write('%s')"%flowName)
             
    def _segregateFlowsAndBiflows(self, allFlows):
        """
        Given a collection of flows and biflows, return segregated flows, biflows
        
        """
        #Relying heavily on self.biflowDict, assuming this dict is updated 
        #during relevant operations (adding, deleting) on all biflows in all 
        #the tests.  
        flows = []
        biflows = []
        for flowName in allFlows:
            if flowName in self.biflowDict:
                biflows.append(flowName)
            else:
                flows.append(flowName)
            
        return flows, biflows
    
    def configureReEducationalFlows(self, GroupName, FlowOptions={}):
        if self.ReEducationTime == -1:
            return 
        
        #Find the clients the are recievers only
        TXclients = []
        RXclients = {}
        for eachKey in self.FlowList.keys():
            (src_port, src_client, des_port, des_client) = self.FlowList[eachKey]
            if src_client not in TXclients:
                TXclients.append(src_client)
            if not RXclients.has_key(des_client):
                RXclients[des_client] = []
            RXclients[des_client].append(src_client)
        for eachKey in RXclients.keys():
            if eachKey in TXclients:
                del RXclients[eachKey]
             
        #Now create a flows from a RXclient back to one of the TXclients
        ListofSrcClient = []
        ListofDesClient = []
        for SrcClientName in RXclients.keys():
            #FIXME - instead of picking the first one, pick a random one
            DesClientName = RXclients[SrcClientName][0]
            ListofSrcClient.append(SrcClientName)
            ListofDesClient.append(DesClientName)

        FlowOptions['NumFrames'] = WaveEngine.MAXtxFrames
        if not FlowOptions.has_key('IntendedRate'):
            FlowOptions['IntendedRate'] = 100.0 / float(len(ListofSrcClient))
            FlowOptions['RateMode']     = 'pps'

        #CreateFlows
        self.ReEducationFlowList = WaveEngine.CreateFlows_Custom(ListofSrcClient, ListofDesClient, self.ListOfClients, FlowOptions, Prefix='EDU')
        self._createFlowGroup(self.ReEducationFlowList, GroupName)

        
    def _applyFlowRate(self, flowRateInfo, frameSize, numMPDUperAMPDU = None):
        """
        Given flow rate is the total intended load across the SUT. When 
        aggregation is enabled, each flow from/to such client (client with
        aggregation) should have a rate which is 'n' times the flow rate to/from
        client without aggregation where n = number of MPDUs per AMPDU for that
        frame size
        """
        ampduPipeFlows, nonAmpduPipeFlows = self._getAMPDUsegregatedPipeFlows(self.FlowList)
        if numMPDUperAMPDU is None:
            numMPDUperAMPDU = self.getMPDUcount(frameSize)

        (loadToBeAppliedOnMPDUflows, 
         loadToBeAppliedOnAMPDUflows) = self._getAggregateLoadToBeApplied(len(ampduPipeFlows), 
                                                                          len(nonAmpduPipeFlows),
                                                                          numMPDUperAMPDU, 
                                                                          flowRateInfo)  
               
        if nonAmpduPipeFlows:
            self.modifyFlows(loadToBeAppliedOnMPDUflows, frameSize, 
                             flowList = nonAmpduPipeFlows)
        
        if ampduPipeFlows:
            self.modifyFlows(loadToBeAppliedOnAMPDUflows, frameSize, 
                             flowList = ampduPipeFlows)
    
        if 'PerFlowRate' in flowRateInfo:
            return loadToBeAppliedOnMPDUflows + loadToBeAppliedOnAMPDUflows
        
    def _getAggregateLoadToBeApplied(self, 
                                     ampduFlowCount, nonAMPDUflowCount,
                                     numMPDUperAMPDU, 
                                     flowRateInfo):
        #Each AMPDU flow is equivalent to 'numMPDUperAMPDU' mpdu flows.
        totalEquivalentMPDUflows = ((ampduFlowCount * numMPDUperAMPDU) + 
                                        nonAMPDUflowCount)            
        if 'PerFlowRate' in flowRateInfo:
            loadToBeAppliedOnMPDUflows = (flowRateInfo['PerFlowRate'] *
                                          nonAMPDUflowCount)
            
            loadToBeAppliedOnAMPDUflows = (flowRateInfo['PerFlowRate'] * 
                                           numMPDUperAMPDU *
                                           ampduFlowCount) 

        elif 'AggregateFlowRate' in flowRateInfo:

            loadToBeAppliedOnMPDUflows = (float(flowRateInfo['AggregateFlowRate']) * 
                                          (1.0 * nonAMPDUflowCount /
                                           totalEquivalentMPDUflows)
                                          )
    
            loadToBeAppliedOnAMPDUflows = (flowRateInfo['AggregateFlowRate'] - 
                                           loadToBeAppliedOnMPDUflows)
        
            #Use floor, ciel on loadToBeAppliedOnMPDUflows and 
            #loadToBeAppliedOnAMPDUflows to negate the effects of  fractional 
            #division of frame rate
            loadToBeAppliedOnMPDUflows = math.ceil(loadToBeAppliedOnMPDUflows)
            loadToBeAppliedOnAMPDUflows = math.floor(loadToBeAppliedOnAMPDUflows)
        
        return loadToBeAppliedOnMPDUflows, loadToBeAppliedOnAMPDUflows
    
    def modifyFlows(self, FrameRate, FrameSize, XmitTime=None, Options={}, 
                    flowList=None, doTcpConnect=True):
        """
        VPR 4311: splitting the ILOAD evenly for multiple clients will cause
        the ILOAD to be less/more than what the user wanted because of the 
        rounding of the number of frames for each client to the nearest integer.
        The workaround we have here is by adjusting the transmit time so the 
        real ILOAD can match what the user wanted. 
        """
        if XmitTime == None:
            XmitTime = self.IntendedTransmitTime
        if flowList == None:
            flowList = self.FlowList
        FrameRatePerPort = FrameRate / float(len(flowList))
        TotalFrames = FrameRate * XmitTime
        NumFrames = TotalFrames /float(len(flowList))
        NumFramesInt = int(NumFrames)
        TotalFrames = NumFramesInt * len(flowList)
 
        AdjustedXmitTime = TotalFrames / FrameRate
        if NumFramesInt == 0:
            WaveEngine.OutputstreamHDL("\nError: System cannot handle frame rate: %d\n" % (FrameRate), WaveEngine.MSG_ERROR)
            raise WaveEngine.RaiseException    
        if XmitTime != AdjustedXmitTime:        
            self.TransmitTime = AdjustedXmitTime
            WaveEngine.OutputstreamHDL("\rAdjusting the transmit time to %.4f sec to achieve the aggregate ILOAD of %d fps" % 
                                       (AdjustedXmitTime, FrameRate), WaveEngine.MSG_OK)
        else:
            self.TransmitTime = XmitTime   
        flowOptions = {'FrameSize': FrameSize, 'IntendedRate': FrameRatePerPort, 
                       'NumFrames': NumFramesInt, 'RateMode': 'pps'}   
        if Options != {}:
            flowOptions.update(Options)         
        if self.FlowOptions.has_key('Type'):    
            flowOptions['Type'] = self.FlowOptions['Type']
        WaveEngine.ModifyFlows(flowList, flowOptions, doTcpConnect)                                   

    def getConnectClientsInfo(self):
        print "In getConnectClientsInfo"
    
    def doArpExchanges(self, 
                       flowList = None, 
                       flowGroupName = None, 
                       arpRate = None, 
                       arpRetries = None, 
                       arpTimeout = None):
                       
        if not flowList:
            flowList = {}
            flowList.update(self.ArpList)
            flowList.update(self.ReEducationFlowList)
        if not flowGroupName:
            flowGroupName = "Obsolete"
        if not arpRate:
            arpRate = self.ARPRate
        if not arpRetries:
            arpRetries = self.ARPRetries
        if not arpTimeout:
            arpTimeout = self.ARPTimeout
            
            
        if WaveEngine.ExchangeARP(flowList, flowGroupName, 
                                  arpRate, arpRetries, arpTimeout) < 0.0:
            self.SavePCAPfile = True
            raise WaveEngine.RaiseException
    
    def writeRSSIinfo(self, time = 0):
        """
        Write the RSSI info of the list of transmitters (AP's in infrastructure
        mode, transmit clients in case of loopback)
        """
        if self.connectMode == 'loopback':
            #In loopback only flowDictionary needs to be passed
            if not self.FlowList :
                 self.Print("Requesting RSSI information without creating  flows", 
                            'ERR')
            else:
                WaveEngine.writeLoopBackRSSIinformation(self.FlowList)
        elif self.connectMode == 'infrastructure':
            if not self.ListOfClients:
                self.Print("Requesting RSSI information without creating clients", 
                           'ERR')
            else:
                WaveEngine.WriteAPinformation(self.ListOfClients, Time = time)
                
    def insertAPinfoTable(self, RSSIfileName = None, reportObject = '',
                          text1 = '', text2 = ''):
        """
        Insert the AP signal strength information into the report 'MyReport'
        """
        if not text1:
            text1 = "The following table shows the SUT details. The received signal strength indication (RSSI) from the SUT is sampled on each port at the start of each trial and averaged over all of the trials."
        if not text2:
            text2 = "RSSI values should be between -25 dBm and -35 dBm. If the RSSI is not in this range, modify the external attenuation to bring it into this range."
        
        if not reportObject:
            reportObject = self.MyReport
        
        reportObject.InsertHeader( "Access Point Information" )
        reportObject.InsertParagraph(text1)
        APinfo = self.AnalyizeRSSIdata( WaveEngine.ReadAPinformation(RSSIfileName) )
        reportObject.InsertDetailedTable( APinfo,
                                           columns = [ 1.5*inch, 0.60*inch,
                                                      1.25*inch, 1.55*inch,
                                                      0.40*inch, 0.40*inch,
                                                      0.40*inch ] )
        reportObject.InsertParagraph(text2)
        
    def PrintReport(self):
        #Dummy Template
        MyReport = WaveReport(self.ReportFilename)
        MyReport.Title("VeriWave Report Generator", self.DUTinfo)
        MyReport.InsertHeader("Overview")
        MyReport.InsertParagraph("If you are reading this, then the poor soul who wrote the test forgot to create a report.")
        MyReport.InsertHeader("Other Stuff")
        MyReport.InsertBogus(20)
        MyReport.Print()
   
    def AnalyizeRSSIdata(self, data):
        CompiledData = odict.OrderedDict()
        for line in data:
            if len(line) != 6:
                continue
            (Time, PortName, Channel, BSSID, SSID, RSSI) = line
            if not isnum(Channel):
                continue
            eachKey = (PortName, BSSID)
            if CompiledData.has_key(eachKey):
                (Channel, SSID, minRSSI, RSSItotal, maxRSSI, RSSIcount) = CompiledData[eachKey]
                if RSSI < minRSSI:
                    minRSSI = RSSI
                if RSSI > maxRSSI:
                    maxRSSI = RSSI
                CompiledData[eachKey] = (Channel, SSID, minRSSI, RSSItotal + RSSI, maxRSSI, RSSIcount + 1)
            else:
                CompiledData[eachKey] = (Channel, SSID, RSSI, RSSI, RSSI, 1)
                
        ReturnedData = [('Port Name', 'Channel', 'BSSID', 'SSID', 'Min RSSI', 'Avg RSSI', 'Max RSSI'), ]
        for eachKey in CompiledData.keys():
            (PortName, BSSID) = eachKey
            (Channel, SSID, minRSSI, RSSItotal, maxRSSI, RSSIcount) = CompiledData[eachKey]
            RSSIavg = float(RSSItotal)/float(RSSIcount)
            ReturnedData.append((PortName, Channel, BSSID, SSID, "%.1f dBm" % (minRSSI), "%.1f dBm" % (RSSIavg), "%.1f dBm" % (maxRSSI)),)
        return ReturnedData

    def SaveResults(self):
        import os.path
        #Save the results to a file
        global copy_list
        copy_list =self.ResultsForCSVfile
        WaveEngine.CreateCSVFile(os.path.join(self.LoggingDirectory, self.CSVfilename), 
                                 self.ResultsForCSVfile)

    def ReadResults(self):
        import os.path
        #Used to simulate a test run using saved data
        WaveEngine._LoggingDirectoryPath = self.LoggingDirectory
        self.ResultsForCSVfile = WaveEngine.ReadCSVFile(os.path.join(self.LoggingDirectory, self.CSVfilename))

    def updateGUIresultsPage(self):
        """
        Update CSV file info and pdf charts (if report opted by user) in the GUI
        """
        
        #Any message to the GUI goes through WaveEngine.OutputStreamHDL(), and the 
        #same is maintained for the updation of the 'Results' page (with CSV file and
        #graph charts) in the GUI too.
        WaveEngine.OutputstreamHDL("", WaveEngine.MSG_SUCCESS)
    def loadingpassfaildata (self,waveChassisStore, 
                 wavePortStore, 
                 waveClientTableStore, 
                 waveSecurityStore, 
                 waveTestStore, 
                 waveTestSpecificStore, 
                 waveMappingStore, 
                 waveBlogStore):
        
         #____________________________DataExport___________________________________
        ## Initializing the Dictionaries
        str_dicts=['waveChassisStore','wavePortStore','waveClientTableStore','waveSecurityStore','waveTestStore','waveTestSpecificStore','waveMappingStore','waveBlogStore']
        dicts=[waveChassisStore,wavePortStore,waveClientTableStore,waveSecurityStore,waveTestStore,waveTestSpecificStore,waveMappingStore,waveBlogStore]
        #print
        global dict_testcase
        dict_testcase={}
        dict_testcase=waveTestStore
        for each in dicts:
               tmp=dicts.index(each)
               self.attribute_final_list_db[str_dicts[tmp]]=each
        #print "The value of %s is \n" %self.attribute_final_list_db
        try:
            if waveTestStore['LogsAndResultsInfo'].has_key('db'):
                if  waveTestStore['LogsAndResultsInfo']['db'] =='True' :
                    self.DbSupport = waveTestStore['LogsAndResultsInfo']['db']

                    if  waveTestStore['LogsAndResultsInfo']['dbtype']:
                        self.DbType = waveTestStore['LogsAndResultsInfo']['dbtype']
                    else:
                        self.DbType = "mysql"

                    if  waveTestStore['LogsAndResultsInfo']['dbname']:
                        self.DbName = waveTestStore['LogsAndResultsInfo']['dbname']
                    else:
                        self.DbName = "veriwave"

                    if  waveTestStore['LogsAndResultsInfo']['dbusername']:
                        self.DbUserName = waveTestStore['LogsAndResultsInfo']['dbusername']
                    else:
                        self.DbUserName = "root"

                    if  waveTestStore['LogsAndResultsInfo']['dbpassword']:
                        self.DbPassword = waveTestStore['LogsAndResultsInfo']['dbpassword']
                    else:
                        self.DbPassword = "veriwave"

                    if  waveTestStore['LogsAndResultsInfo']['dbserverip']:
                        self.DbServerIP = waveTestStore['LogsAndResultsInfo']['dbserverip']
                    else:
                        self.DbServerIP = "localhost"

                else:
                    pass
              
                if os.name == "nt":
                    mypath=os.environ['HOMEPATH']
                else:
                    mypath=os.environ['HOME']
                

                myfile=os.path.join(mypath,'dbdatafiledetails')
                fileptr=open(myfile,'w')
                from wmlConfig import python_lib_dir
                print python_lib_dir
                mydata=[self.DbType,self.DbName,self.DbUserName,self.DbPassword,self.DbServerIP,python_lib_dir]
                mydata=','.join(mydata)
                print mydata
                fileptr.write(mydata)
                fileptr.close()

        except:
            pass
  
    def logintodatabase(self):

        try:
        #___________________________________DataExport___________________________________
            if self.DbSupport == "True":
                TC_dict={}
                global testname
                global dict_testcase
                if dict_testcase['LogsAndResultsInfo'].has_key('testcasename'):
                    if  dict_testcase['LogsAndResultsInfo']['testcasename']:
                        TC_dict['TestCaseName']= dict_testcase['LogsAndResultsInfo']['testcasename']
                    else:
                        try:
                            filep= open ("temp_tc.txt", "r")
                            testcasename = filep.readline()
                            TC_dict['TestCaseName']=testcasename.rstrip()
                            filep.close()
                        except:
                            TC_dict['TestCaseName']='Unable to read from file'

                if dict_testcase['LogsAndResultsInfo'].has_key('testcasedescription'):
                    if dict_testcase['LogsAndResultsInfo']['testcasedescription']:
                        TC_dict['Description']=dict_testcase['LogsAndResultsInfo']['testcasedescription']
                    else:
                        TC_dict['Description']= 'NO DESC IN CONFIG'

                TC_dict['LoggingDirectory']=self.LoggingDirectory
                TC_dict['StartTime']=self.start_time
                TC_dict['EndTime'] = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))

                if self.ExitStatus == 0:
                    TC_dict['Outcome']="PASS"
                elif self.ExitStatus == 3:
                    TC_dict['Outcome']="PF_FAIL"

                if  WE.Error_list_db[1][1]== "True":
                    TC_dict['Outcome']="ABORT"
                    for line in self.ResultsForCSVfile:
                        for var in range(0,len(line)):
                            if line[var]=="FAIL":
                                TC_dict['Outcome']="FAIL"

                if testname =='unicast_max_client_capacity':
                    temp_list=[]
                    temp_list=WE.Error_list_db[-1][1]
                    if temp_list.endswith("Information from the SUT - status code: 0"):
                        WE.Error_list_db[0]=("TestStatus",0)
                        WE.Error_list_db[1]=("TestError", "False")
                        WE.Error_list_db[-1]=("ErrorCondition","None")
                Trial_config_list_db=[]
                Trial_config_list_db=WE.Error_list_db+ self.Version_list_db
                copy_results=[]
                if WE.Error_list_db[0][1]== 0:
                    global copy_list
                    copy_results=copy_list[copy_list.index(())+1:]
                    if testname =='unicast_max_forwarding_rate' or testname == 'mesh_max_forwarding_rate_per_hop':
                        copy_results=self.ResultsforDb
                    elif testname== 'tcp_goodput':
                        tmp_st=copy_list.index(())
                        tmp_en=copy_list.index('\n')
                        copy_results= copy_list[ tmp_st+1:tmp_en]
                    elif testname=='qos_capacity':
                        copy_result=copy_list[copy_list.index(())+1:]
                        for each in  copy_result[1:]:
                            trial=each[0]
                        if trial ==1:
                            copy_results.append(copy_result[0])
                            copy_results.append(copy_result[-1])
                        else:
                            copy_results=copy_result
                    elif  testname=='qos_service':
                        copy_results=self.ResultsforDb
                        #copy_results=copy_list[copy_list.index(())+2:]
                        #print "Copy list is %s" %copy_results
                    elif (testname=='roaming_delay') or (testname=='roaming_benchmark'):
                        end_tu =('End DataSet 1',)
                        temp_ro=copy_list.index(end_tu)
                        copy_results=copy_list[copy_list.index(())+2: temp_ro ]
                    elif  testname=='voip_roam_quality':
                        star_tu=('Summary Table Details',)
                        end_tu=('Graph:Min/Avg/Max R-value bar graph',)
                        temp_st=copy_list.index(star_tu)
                        temp_end=copy_list.index(end_tu)
                        copy_results=copy_list[temp_st+1:temp_end]
                    elif testname=='aaa_auth_rate':
                        start_tu=copy_list.index(())
                        for each in copy_list[start_tu+1:]:
                            if str(each[0]).startswith('Total Num of Clients'):
                                end_tu=copy_list.index(each)
                                copy_results=copy_list[start_tu+1:end_tu]
                            else:
                                 copy_results=copy_list[copy_list.index(())+1:]
                #print "the copy list is %s" %copy_results
                import os.path
                import vw_dataExport
                db_instance =vw_dataExport.ExportData(self.DbServerIP,self.DbType,self.DbName,self.DbUserName,self.DbPassword)
                #A single call to populate the database
                db_instance.sendTrialResults(testname,TC_dict,Trial_config_list_db,self.attribute_final_list_db,copy_results)
            else:
                pass
        except:
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            msg = ""
            for text in traceback.format_exception(exc_type, exc_value,exc_traceback):
                msg += str(text)
            print msg
            WaveEngine.OutputstreamHDL("Error Occured while populating the database\n",
                                   WaveEngine.MSG_ERROR)
            pass

                 
    def CloseShop(self): 
        # Have to destroy all TCP connections before we created the capture files
        WaveEngine.DestroyBiflow()      
        try:
            if self.SavePCAPfile:
                if self.PCAPFilename == None:
                    ScriptName = re.search("([.0-9a-zA-Z_-]+).py", sys._getframe(1).f_code.co_filename)
                    self.PCAPFilename = "Hdwrlog_" + ScriptName.group(1)
                
                WaveEngine.GetLogFile(self.CardList, self.PCAPFilename, self.GeneratePCAPlog)
                
        except WaveEngine.RaiseException:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            (exc_type, exc_value, exc_traceback) = sys.exc_info()
            WaveEngine.OutputstreamHDL(str(exc_value), WaveEngine.MSG_ERROR)
        
        try:
            #Hack for making sure the .pdf is not present in the directory, when opted out
            reportFileAbsName = os.path.join(self.LoggingDirectory, self.ReportFilename)
            if os.path.exists(reportFileAbsName):
                if not self.generatePdfReportF:
                    os.remove(reportFileAbsName)
        except:
            pass
    

        try:
            WaveEngine.DisconnectAll()            
            WaveEngine.CloseLogging()
        except:
            WaveEngine.OutputstreamHDL('\n', WaveEngine.MSG_OK)
            errorMsg = 'Exception occured when closing shop, Quitting now! Chassis disconnect might not have completed.'
            WaveEngine.OutputstreamHDL(errorMsg, WaveEngine.MSG_ERROR)
        try:
            self.logintodatabase()
        except:
            errorMsg = 'Exception occured while logging results into Database'
            WaveEngine.OutputstreamHDL(errorMsg, WaveEngine.MSG_ERROR)
    #___________________________________DataExport___________________________________ 
        #When user presses the 'Stop' button just when we are printing the
        #Thank you note on the console,ignore it
        try: 
             WaveEngine.OutputstreamHDL("Thank you for using VeriWave (http://www.veriwave.com)\n", 
                                   WaveEngine.MSG_OK)

        except WaveEngine.RaiseException:
            #Stop button is pressed just when print the Thank you message, 
            #just ignore the button click and continue
            pass
            
#Define the colors used
VeriwaveBlue   = [  0/255.0, 158/255.0, 179/255.0]
VeriwaveYellow = [235/255.0, 156/255.0, 24/255.0]
VeriwaveGreen  = [206/255.0, 229/255.0, 183/255.0]
VeriwaveLtBlue = [219/255.0, 243/255.0, 244/255.0]

#
#   Create a standard template for the reports
#
try:
    from reportlab.platypus import BaseDocTemplate, Paragraph, Spacer, PageBreak, CondPageBreak, Flowable, Table, TableStyle
    from reportlab.platypus.frames import Frame
    from reportlab.platypus.doctemplate import PageTemplate, _doNothing
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.rl_config import defaultPageSize
    from reportlab.lib.units import inch
    # The following are added to get them imported for py2exe build. 
    # They are also referenced in the test.py files (e.g. unicast_latency.py)
    #
    from reportlab.graphics.shapes import Drawing, Line, String, STATE_DEFAULTS
    from reportlab.graphics.charts.linecharts import HorizontalLineChart, Label
    from reportlab.graphics.charts.barcharts  import VerticalBarChart
    from reportlab.graphics.charts.lineplots import LinePlot
    from reportlab.graphics.charts.utils import nextRoundNumber
    from reportlab.graphics.charts.axes import XCategoryAxis, YValueAxis
except:
    pass

class WaveReport:
    def __init__(self, Filename='report.pdf'):
        try:
            from reportlab.lib.units import inch
        except ImportError :
            WaveEngine.OutputstreamHDL("Error: ReportLab not Installed (http://www.reportlab.org/downloads.html)\n", WaveEngine.MSG_ERROR)
            self.Story = None
        else:
            self.Story = []
           
        from InlineImages import InlineImage
        self.ImageVeriwaveLogo = InlineImage("VW_logo")
        self.CobrandingLogo    = None
        self._filename = Filename
        try:
            _Fhdl = open(Filename, 'w')
        except:
            WaveEngine.OutputstreamHDL("Warning: Could not open %s for writing.  Report will not be created.\n" % (Filename), WaveEngine.MSG_WARNING)
            self.Story = None
            return
        self.doc = VeriwaveDocTemplate(Filename)

    def setCobrandingLogo(self, filename):
    # If the filename is a valid jpeg, bmp, or gif file, then it is scled and placed in
    # the upper righthand cornder of every page.  The upper lefthand is still reserved
    # for Veriwave logo
        if os.path.exists(filename):
            try:
                self.CobrandingLogo = Image.open(filename)
            except Exception, e:
                WaveEngine.OutputstreamHDL("Logo file '%s' error: %s\n" % (filename, str(e)), WaveEngine.MSG_WARNING)
                self.CobrandingLogo = None
                #(exc_type, exc_value, exc_tb) = sys.exc_info()
                #msg = "Fatal script error:\n"
                #for text in traceback.format_exception(exc_type, exc_value, exc_tb):
                #    msg += str(text)
                #WaveEngine.OutputstreamHDL(msg, WaveEngine.MSG_ERROR)
        else:
            WaveEngine.OutputstreamHDL("Could not open Logo file '%s'\n" % (filename), WaveEngine.MSG_WARNING)

    def Title(self, TitleName, DUT, TestID=''):
        if self.Story != None:
            self.Story.append(Title(TitleName, DUT, TestID))
        
    def InsertHeader(self, Text):
        if self.Story != None:
            self.Story.append(Header(Text))

    def InsertObject(self, Object):
        if self.Story != None:
            self.Story.append(Object)
            self.Story.append(Spacer(1, 0.2*inch))

    def InsertParagraph(self, text):
        if self.Story == None:
            return
        styles = getSampleStyleSheet()
        style = styles["Normal"]
        p = Paragraph(text, style)
        self.Story.append(p)
        self.Story.append(Spacer(1, 0.2*inch))

    def InsertParameterTable(self, data, columns=[]):
        """
        The parameter table requires three columns.
        """
        if self.Story == None:
            return
        from reportlab.lib import colors
        styles = getSampleStyleSheet()
        R, G, B = VeriwaveGreen
        LIST_STYLE = TableStyle([ ('GRID', (0, 0), (-1, -1), 1, colors.black), 
                                   ('BACKGROUND', (0, 0), (-1, 0), (R, G, B)), 
                                   ('ALIGN', (0, 0), (-1, 0), 'CENTER'), 
                                   ('ALIGN', (0, 1), (-1, -1), 'LEFT')])
        #First line contains the headers
        Length = len(data)
        _data = [ data[0] ]
        for n in range (1, Length):
            (name, value, text) = data[n]
            V = Paragraph(value, styles["BodyText"])
            P = Paragraph(text, styles["BodyText"])            
            _data.append((name, V, P))
        self.Story.append(Spacer(1, 0.1*inch))
        self.Story.append(Table(_data, colWidths=columns, style=LIST_STYLE, rowHeights=None))
        self.Story.append(Spacer(1, 0.15*inch))
    
    def InsertUserspecifiedTable(self, data1, columns=[]):
       """
          This table requires four coulmns instead of this we can change the previous procedure to 
          support any number of coulumns and we can make it genralize.I am not messing with it, instead i am creating a new proc
       """
       if self.Story == None:
            return
       from reportlab.lib import colors
       styles = getSampleStyleSheet()
       R, G, B = VeriwaveGreen
       LIST_STYLE = TableStyle([ ('GRID', (0, 0), (-1, -1), 1, colors.black),
                                   ('BACKGROUND', (0, 0), (-1, 0), (R, G, B)),
                                   ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
                                   ('ALIGN', (0, 1), (-1, -1), 'LEFT')])
       #First line contains the headers
       Length = len(data1)
       _data = [data1[0]]
       for n in range (1, Length):
            
            (name, value1, value2,value3) = data1[n]
            V1 = Paragraph(value1, styles["BodyText"])
            V2 = Paragraph(value2, styles["BodyText"])
            V3 = Paragraph(value3, styles["BodyText"])
            _data.append((name,V1,V2,V3))
       self.Story.append(Spacer(1, 0.1*inch))
       self.Story.append(Table(_data, colWidths=columns, style=LIST_STYLE, rowHeights=None))
       self.Story.append(Spacer(1, 0.15*inch)) 


    def InsertDetailedTable(self, data, columns=[]):
        """
        The Detailed Table converts floating point values to %0.1f format.
        """
        if self.Story == None:
            return
        if len(data) == 0:
            return
        from reportlab.lib import colors
        styles = getSampleStyleSheet()
        R, G, B = VeriwaveGreen
        LIST_STYLE = TableStyle([ ('GRID', (0, 0), (-1, -1), 1, colors.black), 
                                   ('BACKGROUND', (0, 0), (-1, 0), (R, G, B)), 
                                   ('ALIGN', (0, 0), (-1, 0), 'CENTER'), 
                                   ('ALIGN', (0, 1), (-1, -1), 'RIGHT')])
        _data = []
        for line in data:
            _line = ()
            for value in line:
                if isnum(value):
                    #We need to convert the 'value' to float first because, if 'value'
                    #is a float in a str format (e.g., '0.44') int(value) would raise
                    #valueError
                    floatVal = float(value)
                    if value == int(floatVal):
                        _line += (value,)
                    else:
                        # do some crude formatting of small values
                        fval = float(value)
                        if 0.0 < fval < 0.0001:
                            formatStr = "< 0.0001"
                        elif abs(fval) < 0.001:
                            formatStr = "%.4f" % fval
                        elif abs(fval) < 0.01:
                            formatStr = "%.3f" % fval
                        elif abs(fval) < 0.1:
                            formatStr = "%.2f" % fval
                        else:
                            formatStr = "%.1f" % fval
                        # insert value
                        _line += (formatStr,)
                else:
                    _line += (Paragraph(value, styles["BodyText"]),)
            for x in range(len(line), len(columns)):
                _line += ('',)
            _data.append(_line)
        self.Story.append(Table(_data, colWidths=columns, style=LIST_STYLE, rowHeights=None, repeatRows=1))
        self.Story.append(Spacer(1, 0.1*inch))

    def InsertGenericTable(self, data, columns=[]):
        """
        The generic table does not have any formatting.
        """
        if self.Story == None:
            return
        if len(data) == 0:
            return
        self.Story.append(Spacer(1, 0.1*inch))
        self.Story.append(Table(data, colWidths=columns, style=None, rowHeights=None))
        self.Story.append(Spacer(1, 0.15*inch))
    
    
    def InsertPageBreak(self, height=None):
        if self.Story != None:
            if height == None:
                self.Story.append(PageBreak())
            else:
                self.Story.append(CondPageBreak(height))

    def InsertBogus(self, Count, Index=0):
        import random
        if self.Story == None:
            return
        styles = getSampleStyleSheet()
        style = styles["Normal"]
        for i in range(Count):
            bogustext = "Text Section %d.  " % Index
            for j in range(2 + int(random.random()* 10)):
                bogustext += "Blab" + (" blab" * int(random.random()* 20)) + '.  '
            self.Story.append(Paragraph(bogustext, style))
            self.Story.append(Spacer(1, 0.2*inch))

    def InsertClientMap(self, Src, Des, bidir=False, CardMap={}):
        if self.Story != None:
            self.Story.append(ClientMap(Src, Des, bidir, CardMap))
 
    def Print(self):
        if self.Story != None:
            self.Story.append(CopyrightNotice())
            self.doc.build(self.Story, self.VeriwavePage)
            WaveEngine.OutputstreamHDL("Completed: Report %s generated.\n" % (self._filename), WaveEngine.MSG_OK)
        
    def VeriwavePage(self, canvas, doc):
        PAGE_HEIGHT=defaultPageSize[1]; PAGE_WIDTH=defaultPageSize[0]
        _LogoHeight = self.doc.topMargin * 0.50
        canvas.saveState()
        
        (LogoWidth, LogoHeight) = self.ImageVeriwaveLogo.getSize()
        scale = float(_LogoHeight)/float(LogoHeight)
        canvas.drawImage(self.ImageVeriwaveLogo, self.doc.leftMargin, PAGE_HEIGHT - self.doc.topMargin, \
                 LogoWidth*scale, LogoHeight*scale, mask=None)
        
        if self.CobrandingLogo != None:
            (LogoWidth, LogoHeight) =  self.CobrandingLogo.size
            scale = float(_LogoHeight)/float(LogoHeight)
            canvas.drawInlineImage(self.CobrandingLogo, PAGE_WIDTH - self.doc.rightMargin - LogoWidth*scale, \
                    PAGE_HEIGHT - self.doc.topMargin, LogoWidth*scale, LogoHeight*scale)
            
        R,G,B = VeriwaveBlue
        canvas.setFillColorRGB(R,G,B)
        canvas.rect(self.doc.leftMargin, 0.75 * inch, PAGE_WIDTH - self.doc.leftMargin - self.doc.rightMargin, 0.25 * inch, stroke=0, fill=1)
        canvas.setFillColorRGB(1,1,1)
        canvas.setFont("Helvetica",10)
        (Pathname, Filename) = os.path.split(self._filename)
        ReportName = os.path.split(Pathname)
        textString = os.path.join(ReportName[1], Filename)
        if len(textString) > 50:
            textString = textString[:50] + "..."
        canvas.drawString(1.1 * self.doc.leftMargin, 0.80 * inch, textString)
        canvas.drawRightString(PAGE_WIDTH - 1.1 * self.doc.rightMargin, 0.80 * inch, "Page %d" % (doc.page)) 
        canvas.restoreState()
        
###############################################################################################################
#                   F L O W A B L E S
###############################################################################################################
# Flowables are things which can be drawn and which have wrap, draw and perhaps split methods.
# Flowable is an abstract base class for things to be drawn and an instance knows its size and draws in its
# own coordinate system (this requires the base API to provide an absolute coordinate system when the
# Flowable.draw method is called). To get an instance use f=Flowable().
#
class VeriwaveDocTemplate(BaseDocTemplate):
    """A special case document template that will handle many simple documents.
       See documentation for BaseDocTemplate.  No pageTemplates are required
       for this special case.   A page templates are inferred from the
       margin information and the onFirstPage, onLaterPages arguments to the build method.
    """
    _invalidInitArgs = ('pageTemplates',)
        
    def handle_pageBegin(self):
        '''override base method to add a change of page template after the firstpage.
        '''
        self._handle_pageBegin()
        self._handle_nextPageTemplate('Later')

    def build(self, flowables, MyTemplate):
        self._calc()    #in case we changed margins sizes etc
        frameT = Frame(self.leftMargin, self.bottomMargin, self.width, self.height, id='normal')
        # Make sure there is no padding on the side margins 
        frameT._leftPadding  = 0
        frameT._rightPadding = 0 
        
        self.addPageTemplates([PageTemplate(id='First',frames=frameT, onPage=MyTemplate,pagesize=self.pagesize),
                        PageTemplate(id='Later',frames=frameT, onPage=MyTemplate,pagesize=self.pagesize)])
        BaseDocTemplate.build(self,flowables)

class Title(Flowable):
    _fixedWidth = 1
    _fixedHeight = 1
    def __init__(self, Title, DUTinfo, testId = ''):
        from InlineImages import InlineImage
        self.ImageTestedByLogo = InlineImage('TBV_logo')
        self.ImageGreenBanner  = InlineImage('covergraphic-lowres')
        self.text   = Title
        self.width   = defaultPageSize[0] - 2 * inch
        self.HeightBlue  = (3/32.0) * inch
        (width, height) = self.ImageGreenBanner.getSize()
        self.HeightGreen = height * self.width / width
        self.HeightWhite = (1/16.0) * inch
        self.HeightTest  = (1+ 1/16.0)*inch
        self.HeightSpace = 0.25 * inch
        self.height  = self.HeightBlue + self.HeightGreen + self.HeightWhite + self.HeightTest
        self.DUTdict =  DUTinfo
        self.testIdStr = testId

    def _stringWidth(self, text, fontName, fontSize):
        from reportlab.pdfbase.pdfmetrics import stringWidth
        SW = lambda text, fN=fontName, fS=fontSize: stringWidth(text, fN, fS)
        return SW(text)

    def drawOn(self, canv, x, y, _sW=0):
        canvas = canv
        canvas.saveState()
        R, G, B = VeriwaveBlue
        canvas.setFillColorRGB(R, G, B)
        canvas.rect(x, y + self.HeightGreen + self.HeightWhite + self.HeightTest, self.width, self.HeightBlue, stroke=0, fill=1)

        canvas.drawImage(self.ImageGreenBanner, x, y + self.HeightWhite + self.HeightTest, self.width, self.HeightGreen, mask=None)
        canvas.setFillColorRGB(0, 0, 0)
        canvas.setFont("Helvetica", 28)
        # Check if we have '\n' in the text
        textList = re.split('\n', self.text)
        txtheight = 17
        for txt in textList:
            canvas.drawString(x + (1/16.0) * inch, y + (txtheight/16.0) * inch + self.HeightWhite + self.HeightTest, txt)
            txtheight -= 6
        canvas.setFont("Helvetica", 14)
        canvas.drawRightString(x + self.width - 8, y + (6/16.0) * inch + self.HeightWhite + self.HeightTest, time.strftime("%B %d, %Y")) 
        canvas.drawRightString(x + self.width - 8, y + (2/16.0) * inch + self.HeightWhite + self.HeightTest, time.strftime("%H:%M:%S"))

        # test ID
        if len(self.testIdStr):
            canvas.drawString(x + (1/16.0) * inch, 
                               y + (6/16.0) * inch + self.HeightWhite + self.HeightTest, 
                               str("Test ID:"))
            canvas.drawString(x + (1/16.0) * inch, 
                               y + (2/16.0) * inch + self.HeightWhite + self.HeightTest, 
                               str(self.testIdStr))

        #Scale Logo to fix
        (width, height) = self.ImageTestedByLogo.getSize()
        LogoWidth =  2 *inch
        k = height * LogoWidth / width 
        offset = (self.HeightTest - k) / 2.0
        R, G, B = VeriwaveBlue
        canvas.setFillColorRGB(R, G, B)
        canvas.rect(x, y, self.width - LogoWidth - 1, self.HeightTest, stroke=0, fill=1)
        canvas.setFillColorRGB(0, 0, 0)
        canvas.setFont("Helvetica", 14)
        canvas.drawString(x + 0.1 * inch, y + self.HeightTest - 15, "Device Tested:") 
        
        DUTList = self.DUTdict.keys()
        DUTList.sort()
        canvas.setFillColorRGB(1, 1, 1)
        textobject = canvas.beginText()
        textobject.setTextOrigin(x + 0.3 * inch, y + self.HeightTest - 28)
        textobject.setFont("Helvetica-Oblique", 12)
        for keys in DUTList[:4]:
            textobject.textLine("%s: %s" % (keys, self.DUTdict[keys]))
        canvas.drawText(textobject)

        # In case the text goes out of the box
        R, G, B = VeriwaveBlue
        canvas.setFillColorRGB(R, G, B)
        x1 = x + self.width - LogoWidth - 1 - 3/16.0 * inch
        canvas.rect(x1, y, 3/16.0 * inch, self.HeightTest, stroke=0, fill=1)
        canvas.setFillColorRGB(1, 1, 1)
        textobject = canvas.beginText()
        textobject.setTextOrigin(x1 + 2, y + self.HeightTest - 28)
        textobject.setFont("Helvetica-Oblique", 12)
        for keys in DUTList[:4]:
            if self._stringWidth("%s: %s" % (keys, self.DUTdict[keys]), "Helvetica-Oblique", 12) + x > x1:
                textobject.textLine("...")
            else:
                textobject.textLine(" ")
        canvas.drawText(textobject)
        canvas.drawImage(self.ImageTestedByLogo, x + self.width - LogoWidth, y + offset, LogoWidth, k, mask=None)
        canvas.restoreState()

    def wrap(self, availWidth, availHeight):
        #the caller may decide it does not fit.
        return (availWidth, self.height)

    def getSpaceAfter(self):
       return self.HeightSpace

class Header(Flowable):
    _fixedWidth = 1
    _fixedHeight = 1
    def __init__(self, text):
        self.text   = text
        self.width  = 3.0 * inch
        self.height = 0.25 * inch

    def drawOn(self, canv, x, y, _sW=0):
        canvas = canv
        canvas.saveState()
        R, G, B = VeriwaveGreen
        canvas.setFillColorRGB(R, G, B)
        BulletScaler = self.height/ 100.0 
        canvas.rect(x, y , self.height, self.height, stroke=0, fill=1)
        canvas.rect(x + self.height * 2, y, 2.50 * inch, self.height, stroke=0, fill=1)
        canvas.circle(x + 30*BulletScaler + self.height, y + 50*BulletScaler, 9*BulletScaler, stroke=0, fill=1)
    
        R, G, B = VeriwaveBlue
        canvas.setFillColorRGB(R, G, B)
        canvas.circle(x + 50*BulletScaler + self.height, y + 28*BulletScaler, 8*BulletScaler, stroke=0, fill=1)
        canvas.circle(x + 63*BulletScaler + self.height, y + 50*BulletScaler, 8*BulletScaler, stroke=0, fill=1)
        canvas.circle(x + 50*BulletScaler + self.height, y + 72*BulletScaler, 8*BulletScaler, stroke=0, fill=1)
        canvas.setFont("Helvetica", 14)
        canvas.drawString(x + 0.75 * inch, y + 4, self.text)
        canvas.restoreState()

    def wrap(self, availWidth, availHeight):
        #the caller may decide it does not fit.
        return (availWidth, self.height)

    def getSpaceAfter(self):
       return (5/32.0) * inch

class CopyrightNotice(Flowable):
    _fixedWidth = 1
    _fixedHeight = 1
    def __init__(self):
        PAGE_HEIGHT=defaultPageSize[1]; PAGE_WIDTH=defaultPageSize[0]
        self.width  = PAGE_WIDTH - 2.0 * inch
        self.height = 0.60 * inch

    def drawOn(self, canv, x, y, _sW=0):
        canvas = canv
        canvas.saveState()
        canvas.setFillColorRGB(0, 0, 0)
        canvas.setFont('Times-Roman', 12)
        canvas.drawString(x, inch + 33, 'VeriWave')
        canvas.setFont('Times-Roman', 10)
        canvas.drawString(x, inch + 22, '8770 SW Nimbus Ave Beaverton, OR 97008')
        canvas.drawString(x, inch + 12, '(800) 457-5915 International: (503) 473-8350')
        R, G, B = VeriwaveBlue
        canvas.setFillColorRGB(R, G, B)
        canvas.drawString(x, inch +  2, 'http://www.veriwave.com/')
        canvas.linkURL('http://www.veriwave.com/', (x, inch , x + 2.5 * inch, inch + self.height), relative=0, thickness=0, color=None, dashArray=None)
    
        canvas.setFont('Times-Roman', 7)
        canvas.setFillColorRGB(0, 0, 0)
        canvas.drawRightString(x + self.width - 7, inch + 22, 'Copyright 2008, VeriWave, Inc. The VeriWave logo, WaveTest, WaveBlade,')
        canvas.drawRightString(x + self.width - 7, inch + 12, 'WaveManager, and VCL are trademarks of VeriWave, Inc. All other products')
        canvas.drawRightString(x + self.width - 7, inch +  2, 'and services mentioned are trademarks of their respective companies.')
        canvas.restoreState()

    def wrap(self, availWidth, availHeight):
        #the caller may decide it does not fit.
        return (availWidth, self.height)

# This is a template for the graphs
class FlowableGraph(Flowable):
    #Constanst for the spacing
    _SpaceYaxis = 14
    _SpaceXaxis = 14
    _SpaceLabel = 28 # space between chart title label and the top of the chart area.

    def __init__(self, width, height):
        self.originX      = inch
        self.originY      = inch
        self.width        = width
        self.height       = height
        self.graphCenterX = width/2
        self.graphCenterY = height/2
        self.offset       = (defaultPageSize[0] - 2 * inch - width) / 2.0
        self.valueMin     = 0
        self.valueMax     = 0
        self.validData    = False
        self.canvas       = None
        # how close can the ticks be?
        self.minimumTickSpacing = 10
        self.maximumTicks       = 7

    def _drawBox(self, x, y, width, height):
        # For debugging purposes only
        self.canvas.saveState()
        self.canvas.setStrokeColorRGB(0.2, 0.5, 0.3)
        self.canvas.setDash(1, 2)
        self.canvas.rect(x, y, width, height, stroke=1, fill=0)
        self.canvas.restoreState()

    def _getGraphRegion(self, x, y):
        x1 = x + self._SpaceXaxis
        y1 = y + self._SpaceYaxis
        w  = self.width - self._SpaceYaxis
        #When the title text is multilined (e.g., uses '\n'), make sure the text of
        #the title doesn't overflow onto the graph. Factor this multiline possibility
        #when computing the graph's height, otherwise, the graph shrinks 
        #proportionate to the lines occupied by the title.
        if self.title:
            #Calculate the number of lines the Title of the graph takes and adjust 
            #self._SpaceLabel if needed
            numLines = self.title.count('\n') + 1
            if numLines > 1:
                self._SpaceLabel *= numLines
        h  = self.height - self._SpaceXaxis - self._SpaceLabel
        return (x1, y1, w, h)
       
    def _drawLabels(self, Title, xAxis, yAxis):
        from reportlab.graphics.charts.textlabels import Label
        Label_Xaxis = Label()
        Label_Xaxis.angle = 0
        Label_Xaxis.dx = self.graphCenterX
        Label_Xaxis.dy = 0
        Label_Xaxis.boxAnchor = 's'
        Label_Xaxis.setText(xAxis)
        self.drawing.add(Label_Xaxis)

        Label_Yaxis = Label()
        Label_Yaxis.angle = 90
        Label_Yaxis.boxAnchor = 'n'
        Label_Yaxis.dx = 0
        Label_Yaxis.dy = self.graphCenterY
        Label_Yaxis.setText(yAxis)
        self.drawing.add(Label_Yaxis)
            
        Label_Graph = Label()
        Label_Graph.fontSize = 12
        Label_Graph.angle = 0
        Label_Graph.boxAnchor = 'n'
        Label_Graph.dx = self.graphCenterX
        Label_Graph.dy = self.height
        Label_Graph.setText(Title)
        self.drawing.add(Label_Graph)

    def _setScale(self, data):
        from reportlab.graphics.charts.utils import nextRoundNumber
        self.valueMax = self.valueMin = 0.0
        for eachSeries in data:
            for eachLine in eachSeries:
                for eachValue in eachLine:
                    self.validData = True
                    if eachValue > self.valueMax:
                        self.valueMax = eachValue
        if self.valueMax == self.valueMin:
            self.valueStep = self.valueMin + 0.001
            self.valueMax  = self.valueMin + 0.001
        else:
            rawInterval = (self.valueMax - self.valueMin) / min(float(self.maximumTicks-1), (float(self.height)/self.minimumTickSpacing))
            self.valueStep = nextRoundNumber(rawInterval)
            self.valueMax =  self.valueStep * (1 + int(self.valueMax/self.valueStep))

    def _stringWidth(self, text, fontName, fontSize):
        from reportlab.pdfbase.pdfmetrics import stringWidth
        SW = lambda text, fN=fontName, fS=fontSize: stringWidth(text, fN, fS)
        return SW(text)

    # Default behavior
    def _rawDraw(self, x, y):
        self._drawBox(x, y, self.width, self.height)
        
    def drawOn(self, canvas, x, y, _sW=0):
        from reportlab.graphics import renderPDF
        self.canvas = canvas
        self._rawDraw(x, y)
        renderPDF.draw(self.drawing, canvas, x, y, showBoundary=False)
        
        #For debuging boundries
        #self._drawBox(x, y, self.width, self.height)

    def drawFile(self, width, height, Filename, format='PNG', dpi=72):
        from reportlab.graphics import renderPM
        self.width  = width
        self.height = height
        self._rawDraw(0, 0)
        renderPM.drawToFile(self.drawing, Filename, fmt=format, dpi=dpi) 

    def drawTo(self, width, height, dpi=72, format='PNG'):
        from reportlab.graphics import renderPM
        self.width  = width * (72.0 / dpi)  # maintain size
        self.height = height * (72.0 / dpi)
        self._rawDraw(0, 0)
        return renderPM.drawToString(self.drawing, fmt = format, dpi=dpi)
 
    def wrap(self, availWidth, availHeight):
        #the caller may decide it does not fit.
        return (availWidth, self.height)       

    def getSpaceAfter(self):
       return (4/16.0) * inch

class ClientMap(Flowable):
    _fixedWidth = 1
    _fixedHeight = 1
    # These set the graphics sizes
    _xPosPercent = [ 0.00, 0.35, 0.42, 0.58, 0.65, 1.00 ]
    _UnitHieght    = 6 
    _Height4Port   = 30
    _Height4Client = 10
    _Height4Group  =  3

    def __init__(self, src, des, bidir, CardMap, CanSplit=True):
        self.SrcClient = src
        self.DesClient = des
        self.width     = defaultPageSize[0] - 2 * inch
        self.bidirectional = bidir
        self.CardMapRaw = CardMap
        self.CardMap = {}
        self.CanSplit = CanSplit
        
        #Estimate the height of the graph
        SrcHeight = 0
        LastPortName = ''
        for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in self.SrcClient:
            SrcHeight += self._Height4Group
            if PortName != LastPortName:
                LastPortName = PortName
                self.CardMap[PortName] = None
                SrcHeight += self._Height4Port
            if len(IncrTuple) == 3:
                if IncrTuple[0] > 4:
                    SrcHeight += self._Height4Client * 4
                else:
                    SrcHeight += self._Height4Client * IncrTuple[0]
            else:
                SrcHeight += self._Height4Client
            
        DesHeight = 0
        LastPortName = ''
        for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in self.DesClient:
            DesHeight += self._Height4Group
            if PortName != LastPortName:
                LastPortName = PortName
                self.CardMap[PortName] = None
                DesHeight += self._Height4Port
            if len(IncrTuple) == 3:
                if IncrTuple[0] > 4:
                    DesHeight += self._Height4Client * 4
                else:
                    DesHeight += self._Height4Client * IncrTuple[0]
            else:
                DesHeight += self._Height4Client
                
        self.height = SrcHeight
        if DesHeight > self.height:
            self.height = DesHeight

        #Make Icons based on the cardmap
        icon80211      = ICON_80211()
        icon80211.size = 1.5*self._UnitHieght
        icon8023       = ICON_8023()
        icon8023.size  = 1.5*self._UnitHieght
        for key in CardMap.keys():
            #Check for telling Eth to Wifi port, too weak condition check.
            if CardMap[key][5] in ('above', 'below', 'defer'):
                self.CardMap[key] = (str(CardMap[key][3]), icon80211)
            elif int(CardMap[key][4]) in (10, 100, 1000):
                if str.upper(CardMap[key][3]) == 'ON':
                    self.CardMap[key] = ('AUTO', icon8023)
                else:
                    duplex = str.upper(CardMap[key][5])
                    self.CardMap[key] = (str(CardMap[key][4])+duplex[0], icon8023)

    def _drawDebugBox(self, x, y, width, height):
        # For debugging purposes only
        self.canvas.saveState()
        self.canvas.setStrokeColorRGB(0.2, 0.5, 0.3)
        self.canvas.setDash(1, 2)
        self.canvas.rect(x, y, width, height, stroke=1, fill=0)
        self.canvas.restoreState()

    def _DrawArrow(self, x1, y1, x2, y2, Count=0):
        self.canvas.setFillColorRGB(0, 0, 0)
        self.canvas.line(x1, y1, x2, y2)
        p = self.canvas.beginPath()
        p.moveTo(x2, y2)
        p.lineTo(x2 - 3 , y2 + 2)
        p.lineTo(x2 - 3 , y2 - 2)
        p.lineTo(x2, y2)
        self.canvas.drawPath(p, stroke=1, fill=1)
        if self.bidirectional:
            p.moveTo(x1, y1)
            p.lineTo(x1 + 3 , y1 + 2)
            p.lineTo(x1 + 3 , y1 - 2)
            p.lineTo(x1, y1)
            self.canvas.drawPath(p, stroke=1, fill=1)
        if Count > 0:
            x_mid = x1 + (x2 - x1)/2.0
            y_mid = y1 + (y2 - y1)/2.0
            self.canvas.line(x_mid-5, y_mid-5, x_mid+5, y_mid+5)
            self.canvas.setFillColorRGB(0, 0, 0)
            self.canvas.setFont("Helvetica", 9)
            self.canvas.drawCentredString(x_mid, y_mid + 8, str(Count))
        
    def _DrawBottom(self, x1, y1, width, height1, height2):
        R, G, B = VeriwaveBlue
        self.canvas.setFillColorRGB(R, G, B)
        self.canvas.rect(x1, y1, width, height2 - y1, stroke=0, fill=1)
        self.canvas.roundRect(x1, y1 - self._UnitHieght, width, 2*self._UnitHieght, self._UnitHieght, stroke=0, fill=1)
        self.canvas.roundRect(x1, y1 - self._UnitHieght, width, height1 - y1 + self._UnitHieght, self._UnitHieght, stroke=1, fill=0)
        return self._UnitHieght*2

    def _DrawTop(self, x1, y1, x2, text):
        from reportlab.graphics import renderPDF
        R, G, B = VeriwaveGreen
        self.canvas.setFillColorRGB(R, G, B)
        self.canvas.roundRect(x1, y1 - 4*self._UnitHieght, x2, 4*self._UnitHieght, self._UnitHieght, stroke=0, fill=1)
        self.canvas.setFillColorRGB(0, 0, 0)

        _MaxStrLen = x2 - 4.0*self._UnitHieght
        textString = text
        if self._stringWidth(str(textString), "Helvetica", 9) > _MaxStrLen:
            while self._stringWidth(str(textString) + "...", "Helvetica", 9) > _MaxStrLen:
                textString = textString[:-1]
            textString = textString + "..."
        self.canvas.setFont("Helvetica", 9)
        self.canvas.drawString(x1 + self._UnitHieght , y1 - 2*self._UnitHieght, textString)
    
        # Add Port Icon
        if self.CardMap.has_key(text):
            (textStr, icon) = self.CardMap[text]
            self.canvas.setFont("Helvetica", 5)
            self.canvas.drawCentredString(x1 + x2 - 1.4*self._UnitHieght, y1 - 2.65*self._UnitHieght, textStr)
            d = Drawing(self._UnitHieght, self._UnitHieght)
            d.add(icon)
            renderPDF.draw(d, self.canvas, x1 + x2 - 2.2*self._UnitHieght, y1 - 1.9*self._UnitHieght, showBoundary=False)
        
        return self._UnitHieght*3

    def _stringWidth(self, text, fontName, fontSize):
        from reportlab.pdfbase.pdfmetrics import stringWidth
        SW = lambda text, fN=fontName, fS=fontSize: stringWidth(text, fN, fS)
        return SW(text)

    def _DrawText(self, x1, y1, width, text, font="Helvetica", size=9):
        strLen = self._stringWidth(str(text), font, size)
        while self._stringWidth(str(text), font, size) > width:
            text = text[:-1]
        
        self.DrawStrings.append((x1 + self._UnitHieght, y1 - 1.5*self._UnitHieght, text, font, size),) 
        return self._Height4Client                                                

    def _BuildClients(self, cur_y, leftBox, RightBox, LeftArrow, RightArrow, Clients):
        topOfBox     = 0
        topOfClients = 0
        boxWidth = RightBox - leftBox
        LastPortName = ''
        if len(Clients) == 0:
            return 0
        for (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) in Clients:
            IPnum = IPv4toInt(IPaddr)
            if PortName != LastPortName:
                if LastPortName != '':  #Draw Bottom
                    cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
                #Draw Top
                topOfBox = cur_y
                cur_y -= self._DrawTop(leftBox , cur_y, boxWidth, PortName)
                topOfClients = cur_y
                LastPortName = PortName
            # Print each client out
            cur_y -= self._Height4Group
            Count  = 1
            IPinc  = 0
            if len(IncrTuple) == 3:
                Count  = int(IncrTuple[0])
                IPinc  = IPv4toInt(IncrTuple[2])
            firstY = cur_y
            MidX = leftBox + (boxWidth / 2.0)
            if Count > 4:
                if IPnum == 0:
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, " . . .")
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, 'DHCP')
                else:
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum))
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum + IPinc))
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, "       . . .   ")
                    cur_y -= self._DrawText(leftBox, cur_y, boxWidth, int2IPv4(IPnum + IPinc * (Count -1)))
                lineY = cur_y + (firstY - cur_y)/2.0
                self._DrawArrow(LeftArrow, lineY, RightArrow, lineY, Count)
            else:
                for RepeatClient in range(Count):
                    self._DrawArrow(LeftArrow, cur_y - self._UnitHieght, RightArrow, cur_y - self._UnitHieght)
                    if IPnum == 0:
                        cur_y -= self._DrawText(leftBox , cur_y, boxWidth/2.0, 'DHCP')
                    else:
                        cur_y -= self._DrawText(leftBox , cur_y, boxWidth/2.0, int2IPv4(IPnum))
                    IPnum += IPinc
            MidY = (firstY + cur_y + self._Height4Client + 2.0) / 2.0
            if isnum(self.CardMap[PortName][0]):
                if str(Security['Method']).upper() == 'NONE':
                    textString = 'No security'
                else:
                    textString = Security['Method']
                self._DrawText(MidX, MidY, boxWidth/2.0 - 3, textString, size=6)
                if Count > 1:
                    self.DrawBrackets.append((MidX, firstY, cur_y),)
        cur_y -= self._DrawBottom(leftBox, cur_y, boxWidth, topOfBox, topOfClients)
        return cur_y
    

    def drawOn(self, canv, x, y, _sW=0):
        self.canvas = canv
        #self._drawDebugBox(x, y, self.width, self.height)
        SrcLeft_x   = self._xPosPercent[0] * self.width + x
        SrcRight_x  = self._xPosPercent[1] * self.width + x
        DUTLeft_x   = self._xPosPercent[2] * self.width + x
        DUTRight_x  = self._xPosPercent[3] * self.width + x
        DesLeft_x   = self._xPosPercent[4] * self.width + x
        DesRight_x  = self._xPosPercent[5] * self.width + x
        self.DrawStrings = []
        self.DrawBrackets = []
        DUTbottom = self._BuildClients(y + self.height, SrcLeft_x, SrcRight_x, SrcRight_x, DUTLeft_x, self.SrcClient)
        n         = self._BuildClients(y + self.height, DesLeft_x, DesRight_x, DUTRight_x, DesLeft_x, self.DesClient)
        if DUTbottom > n:
            DUTbottom = n

        # Place the DUT
        R, G, B = VeriwaveLtBlue
        widthDUT = DUTRight_x - DUTLeft_x
        self.canvas.setFillColorRGB(R, G, B)
        self.canvas.roundRect(DUTLeft_x, y, widthDUT, self.height, self._UnitHieght, stroke=1, fill=1)
        self.canvas.setFillColorRGB(0, 0, 0)
        self.canvas.setFont("Helvetica", 12)
        self.canvas.drawCentredString(DUTLeft_x + widthDUT/2.0, y + self.height/2.0, 'SUT')

        # Print the text over the graphics
        self.canvas.setFillColorRGB(1, 1, 1)
        for (x1, y1, text, font, size) in self.DrawStrings:
            self.canvas.setFont(font, size)
            if y1 >= y:
                self.canvas.drawString(x1, y1, text)
                
        self.canvas.setStrokeColorRGB(1, 1, 1)
        self.canvas.setLineWidth(0.5)
        _arcSize = 2.5
        for (x1, y1, y2) in self.DrawBrackets:
            y1 -= 0.5
            y2 -= 0.5
            midy = (y1 + y2) / 2.0
            pathobject = self.canvas.beginPath()
            pathobject.moveTo(x1 - _arcSize, y1)
            pathobject.arcTo (x1 - 2.0*_arcSize, y1 - 2.0*_arcSize           , x1           , y1 , startAng=90, extent=-90)
            pathobject.lineTo(x1           , midy + _arcSize)
            pathobject.arcTo (x1           , midy                , x1 + 2.0*_arcSize, midy + 2.0*_arcSize, startAng=180, extent=90)
            pathobject.arcTo (x1           , midy - 2.0*_arcSize , x1 + 2.0*_arcSize, midy , startAng=90, extent=90)
            pathobject.lineTo(x1           , y2 + _arcSize)
            pathobject.arcTo (x1 - 2.0*_arcSize, y2              , x1 , y2 + 2.0*_arcSize, startAng=0, extent=-90)
            self.canvas.drawPath(pathobject, fill=0, stroke=1)

    def wrap(self, availWidth, availHeight):
        self.width = availWidth
        return (self.width, self.height)       

    def split(self, availWidth, availHeight):
        if not self.CanSplit:
            return []
        #Only split if the image fills more than 3/4 of a page 
        if self.height < (defaultPageSize[1] - 2.35 * inch) * 0.75:
            return []

        #Do the split here
        SrcP1 = []
        ListSrcSplits = []
        Height = 0
        LastHeight = 0
        LastPortName = ''
        _availHeight = availHeight
        for eachLine in self.SrcClient:
            (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) = eachLine
            Height += self._Height4Group
            if PortName != LastPortName:
                LastPortName = PortName
                Height += self._Height4Port
            if len(IncrTuple) == 3:
                if IncrTuple[0] > 4:
                    Height += self._Height4Client * 4
                else:
                    Height += self._Height4Client * IncrTuple[0]
            else:
                Height += self._Height4Client
            if Height > _availHeight:
                ListSrcSplits.append(SrcP1)
                SrcP1 = []
                SrcP1.append(eachLine)
                Height -= LastHeight
                LastHeight  = 0
                _availHeight = defaultPageSize[1] - 2.35 * inch
            else:
                SrcP1.append(eachLine)
                LastHeight = Height
        ListSrcSplits.append(SrcP1)
        
        DesP1 = []
        ListDesSplits = []
        Height = 0
        LastPortName = ''
        LastHeight = 0
        _availHeight = availHeight
        for eachLine in self.DesClient:
            (BaseName, PortName, BSSID, MAC, IPaddr, Subnet, Gateway, IncrTuple, Security, Options) = eachLine
            Height += self._Height4Group
            if PortName != LastPortName:
                LastPortName = PortName
                Height += self._Height4Port
            if len(IncrTuple) == 3:
                if IncrTuple[0] > 4:
                    Height += self._Height4Client * 4
                else:
                    Height += self._Height4Client * IncrTuple[0]
            else:
                Height += self._Height4Client
            if Height > _availHeight:
                ListDesSplits.append(DesP1)
                DesP1 = []
                DesP1.append(eachLine)
                Height -= LastHeight
                LastHeight  = 0
                _availHeight = defaultPageSize[1] - 2.35 * inch
            else:
                DesP1.append(eachLine)
                LastHeight = Height
        ListDesSplits.append(DesP1)

        TotalObjects = len(ListSrcSplits)
        if len(ListDesSplits) > TotalObjects:
            TotalObjects = len(ListDesSplits)

        ReturnedObjects = []
        for n in range(TotalObjects):
            SrcP1 = []
            DesP1 = []
            if n < len(ListSrcSplits):
                SrcP1 = ListSrcSplits[n]
            if n < len(ListDesSplits):
                DesP1 = ListDesSplits[n]
            ReturnedObjects.append(self.__class__(SrcP1, DesP1, self.bidirectional, self.CardMapRaw, False)) 
        return ReturnedObjects

    def getSpaceAfter(self):
       return (4/16.0) * inch

###############################################################################################################
#                   W I D G E T S
###############################################################################################################
# Widgets are complex drawing objects used by the Flowables.  Widget are vectored and can be rotated and sized.
#
from reportlab.graphics.widgetbase import Widget
from reportlab.graphics import shapes
from reportlab.lib import colors
class ICON_8023(Widget):
    def __init__(self):
        self.x = 0
        self.y = 0
        self.size = 80
        self.strokeWidth = 1.0

    def _drawRect(self, x, y, w, h):
        startX = x + w/2.0
        self.group.add(shapes.PolyLine(points = [startX, y, x+w, y, x+w, y+h, x, y+h, x, y, startX, y], strokeWidth=self.strokeWidth, strokeColor=colors.black, strokeLineJoin = 1))
        
    def draw(self):
        u = self.size / 10.0
        self.strokeWidth = self.size / 35.0      
        self.group = shapes.Group()
        #g.transform = [1,0,0,1,self.x, self.y]

        self._drawRect(self.x + u, self.y + u, 3.0*u, 3.0*u)
        self._drawRect(self.x + 6.0*u, self.y + u, 3.0*u, 3.0*u)
        self._drawRect(self.x + 3.5*u, self.y + 6.0*u, 3.0*u, 3.0*u)
        
        self.group.add(shapes.Line(self.x , self.y + 5.0*u, self.x + 10.0*u, self.y + 5.0*u, strokeWidth= self.strokeWidth, strokeColor=colors.black))
        self.group.add(shapes.Line(self.x + 2.5*u, self.y + 4.0*u, self.x + 2.5*u, self.y + 5.0*u, strokeWidth= self.strokeWidth, strokeColor=colors.black))
        self.group.add(shapes.Line(self.x + 7.5*u, self.y + 4.0*u, self.x + 7.5*u, self.y + 5.0*u, strokeWidth= self.strokeWidth, strokeColor=colors.black))
        self.group.add(shapes.Line(self.x + 5.0*u, self.y + 6.0*u, self.x + 5.0*u, self.y + 5.0*u, strokeWidth= self.strokeWidth, strokeColor=colors.black))
        return self.group

class ICON_80211(Widget):
    def __init__(self):
        self.x = 0
        self.y = 0
        self.size = 80
        self.strokeWidth = 1.0

    def _drawCirleLine(self, StartX, StartY, number, angle, length, startCount=0):
        distX = cos(angle) * float(length) / float(number)
        distY = sin(angle) * float(length) / float(number)
        sizeDelta = self.strokeWidth * 0.75/ float(number)
        for n in range(number):
            if n < startCount:
                continue
            x = StartX + distX * n
            y = StartY + distY * n
            size = self.strokeWidth - sizeDelta * n
            self.group.add(shapes.Circle(x, y, size, fillColor=colors.black, strokeWidth= size/100.0))
        
    def draw(self):
        s = self.size # abbreviate as we will use this a lot
        u = s / 10.0
        self.strokeWidth = self.size / 30.0      
        self.group = shapes.Group()
        self.group.add(shapes.Line(self.x + 5.0*u, self.y + 0.0*u, self.x + 5.0*u, self.y + 3.3*u, strokeColor=colors.black, strokeWidth= self.strokeWidth * 1.8))

        self._drawCirleLine(self.x + 5.0*u, self.y + 4.0*u, 5, radians(45), 6.0*u, startCount = 1)
        self._drawCirleLine(self.x + 5.0*u, self.y + 4.0*u, 5, radians(67.5), 6.0*u, startCount = 2)
        self._drawCirleLine(self.x + 5.0*u, self.y + 4.0*u, 5, radians(90), 6.0*u, startCount = 0)
        self._drawCirleLine(self.x + 5.0*u, self.y + 4.0*u, 5, radians(112.5), 6.0*u, startCount = 2)
        self._drawCirleLine(self.x + 5.0*u, self.y + 4.0*u, 5, radians(135), 6.0*u, startCount = 1)
        
        #print r.dumpProperties()
        return self.group
