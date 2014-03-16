import elementtree.ElementTree as ET
import sys, string, os
import os.path
import csv
import time, threading, datetime
import odict
import WaveEngine as WE
from models.genericTestSetupModel import genericTestSetupModel as GTSM 
from models.specificTestSetupModel import specificTestSetupModel as STS
from models import portSetupModel 

global wmlMetadataAvailable
try:
    from wmlMetadata import *
    wmlMetadataAvailable = True
except ImportError:
    wmlMetadataAvailable = False

class parseWml:
    CURRENT_VERSION = "2.0"

    
    waveChassisStoreElementsList = ['CardID',
                                     'PortID',
                                     'BindStatus',
                                     'PortName',
                                     'PortType',
                                     'Band',
                                     'Channel',
                                     'SecondaryChannelPlacement',
                                     'hiddenSSIDs',
                                     'CardMode'
                                     ]

    waveChassisStoreEthernetElementsList = ['EthernetSpeed',
                                             'Duplex',
                                             'Autonegotiation'
                                             ]
    
    waveClientTableElementsList = ['Enable',
                                    'Name',
                                    'GratuitousArp',
                                    'BehindNAT',
                                    'Dhcp',
                                    'NumClients',
                                    'Interface',
                                    'CtsToSelf',
                                    'PortName',
                                    'Ssid',
                                    'Bssid',
                                    'TrafficClass',
                                    'NodeId',
                                    'Hops'
                                    ]
    
    waveClientTableIpv4List = ['SubnetMask',
                                    'BaseIp',
                                    'IncrIp',
                                    'Gateway'
                                    ]
    
    waveClientTableMacList = ['MacAddressMode',
                                   'MacAddress',
                                   'MacAddressIncr'
                                   ]
    
    waveClientTableOptionsList = [ 'phyInterface',
                                    'DataPhyRate',
                                    'MgmtPhyRate',
                                    'nPhySettings',
                                    'TxPower',
                                    'AssocProbe',
                                    'VlanEnable',
                                    'VlanUserPriority',
                                    'VlanCfi',
                                    'VlanId',
                                    'ProactiveKeyCaching',
                                    'Wlan80211eQoSEnable',
                                    'Wlan80211eQoSAC',
                                    'KeepAlive',
                                    'KeepAliveRate' 
                                    ]

    waveClientNPhySettings = [  'PlcpConfiguration',
                                'ChannelBandwidth',
                                'EnableAMPDUaggregation',
                                'ChannelModel',
                                'DataMcsIndex',
                                'GuardInterval'
                                ]

    waveSecurityList = [
                             'EthNetworkAuthMethod',
                             'Method',
                             'EncryptionMethod',
                             'ApAuthMethod',
                             'NetworkAuthMethod',
                             'KeyId',
                             'KeyWidth',
                             'KeyType',
                             'NetworkKey',
                             'RootCertificate',
                             'EnableValidateCertificate',
                             'ClientCertificate',
                             'PrivateKeyFile',
                             'Identity',
                             'Password',
                             'LoginMethod',
                             'LoginFile',
                             'AnonymousIdentity',
                             'StartIndex'
                             ]
                          

    
    tputList = ['Frame',
                 'FrameSizeList',
                 'SearchResolution',
                 'MinSearchValue',
                 'MaxSearchValue',
                 'Mode', 
                 'StartValue',
                 'MediumCapacity',
                 'ReferenceTPUTMode',
                 'ThroughputInputMode',
                 'AcceptableThroughput'
                 ]
    
    packetLossList = ['Frame',
                       'FrameSizeList',
                       'ILoadList',
                       'ILoadMode',
                       'AcceptableFrameLossRate',
                       'MediumCapacity'
                       ]
    
    maxfrList = ['Frame',
                  'FrameSizeList',
                  'SearchResolution',
                  'MediumCapacity',
                  'AcceptableForwardingRate',
                  'ForwardingRateMode' 
                  ]
    
    tcpGoodputList = ['Frame',
                       'FrameSizeList', 
                       'NumOfSessionPerClient', 
                       'TrafficDir', 
                       'TcpWindowSize',
                       'MediumCapacity',
                       'AcceptableGoodput',
                       'GoodputMode'
                       ]
    
    latencyList = ['Frame',
                        'FrameSizeList',
                        'ILoadList',
                        'ILoadMode',
                        'AcceptableMaxLatency'
                        ]
    
    authRateList = ['AuthenticationRate', 
                         'ResultSampleTime', 
                         'DisconnectClients',
                         'ExpectedAuthentications'
                         ]  
          
    callCapacityList = [ 'ClientPercentLocal',
                              'ClientFrameSize',
                              'ClientFrameRate',
                              'ClientCallDelay',
                              'ServerFrameSize',
                              'ServerFrameRate',
                              'SearchMinimum',
                              'SearchMaximum',
                              'SearchResolutionCount',
                              'ServerAcceptableLossCount',
                              'ClientAcceptableLossPercent',
                              'ClientAcceptableOLOADPercent',
                              'SampleTime' 
                              ]
    
    rateVsRangeList = [
                        'ExternalAttenuation',
                        'InitialPowerLevel',
                        'FinalPowerLevel',
                        'IncrementPowerLevel',
                        'RefPowerList',
                        'RefRateList'
                        ]
    
    maxccList = ['Frame',
                      'FrameSizeList',
                      'ILoadList',
                      'ILoadMode',
                      'MaxSearchValue',
                      'ExpectedClientConnections'
                      ]
    
    roamKeyList = ['learningDestMac', 
                        'deauth', 
                        'preauth', 
                        'disassociate', 
                        'dwellTime', 
                        'portNameList', 
                        'pmkid', 
                        'ssid', 
                        'powerProfileFlag', 
                        'learningFlowFlag', 
                        'bssidList',
                        'reassoc', 
                        'srcEndPw', 
                        'learningDestIp', 
                        'destEndPwr', 
                        'srcChangeStep', 
                        'flowPacketSize', 
                        'flowRate', 
                        'destChangeStep', 
                        'durationUnits', 
                        'learningPacketRate', 
                        'destStartPwr', 
                        'srcStartPwr', 
                        'repeatValue', 
                        'srcChangeInt', 
                        'repeatType', 
                        'destChangeInt', 
                        'renewDHCP',
                        'renewDHCPonConn' ,
                        'AcceptableRoamFailures' ,
                        'AcceptableRoamDelay'
                        ]
    
    roamCommonList = ['bssidList',
                      'portNameList',
                      'ssid'
                      ]

    # only used by wmlMetadata
    roamingBenchmarkList = ['deauth',
                            'pmkid',
                            'disassociate',
                            'learningPacketRate',
                            'dwellTime',
                            'renewDHCPonConn',
                            'flowPacketSize',
                            'preauth',
                            'flowRate',
                            'backgroundTraffic',
                            'renewDHCP',
                            'durationUnits',
                            'repeatValue',
                            'powerProfileFlag',
                            'repeatType',
                            'learningFlowFlag',
                            'reassoc',
                            'roamRate',
                            'AcceptableRoamFailures' ,
                            'AcceptableRoamDelay'
                            ]

    # only used by wmlMetadata
    qosCapacityVoiceList = ['Codec',
                            'SearchMin',
                            'SearchMax',
                            'UserPriority',
                            'TosField',
                            'TosReserved',
                            'TosDiffservDSCP',
                            'TosLowCost',
                            'TosLowDelay',
                            'TosHighThroughput',
                            'TosHighReliability',
                            'SrcPort',
                            'DestPort',
                            'ExpectedCallCapacity'
                            ]

    # only used by wmlMetadata
    qosCapacityBackgroundList = ['Type',
                                 'FrameSize',
                                 'FrameRate',
                                 'UserPriority',
                                 'TosField',
                                 'TosReserved',
                                 'TosDiffservDSCP',
                                 'TosLowCost',
                                 'TosLowDelay',
                                 'TosHighThroughput',
                                 'TosHighReliability',
                                 'SrcPort',
                                 'DestPort'
                                 ]

    # only used by wmlMetadata
    qosCapacitySlaList = ['MinRValue',
                          'MaxPktLoss',
                          'Mode',
                          'MaxLatency',
                          'MaxJitter'
                          ]

    # only used by wmlMetadata
    qosCapacityAutomapList = ['trafficDirection',
                              'splitTraffic'
                              ]

    # only used by wmlMetadata
    qosAssuranceVoiceList = ['Codec',
                             'NumberOfCalls',
                             'UserPriority',
                             'TosField',
                             'TosReserved',
                             'TosDiffservDSCP',
                             'TosLowCost',
                             'TosLowDelay',
                             'TosHighThroughput',
                             'TosHighReliability',
                             'SrcPort',
                             'DestPort'
                             ]

    # only used by wmlMetadata
    qosAssuranceBackgroundList = ['FrameSize',
                                  'FrameRate',
                                  'MinFrameRate',
                                  'MaxFrameRate',
                                  'SearchMode',
                                  'SearchStep',
                                  'Type',
                                  'UserPriority',
                                  'TosField',
                                  'TosReserved',
                                  'TosDiffservDSCP',
                                  'TosLowCost',
                                  'TosLowDelay',
                                  'TosHighThroughput',
                                  'TosHighReliability',
                                  'SrcPort',
                                  'DestPort'
                                  ]

    # only used by wmlMetadata
    qosAssuranceSlaList = ['MinRValue',
                           'MaxPktLoss',
                           'Mode',
                           'MaxLatency',
                           'MaxJitter'
                           ]

    # only used by wmlMetadata
    qosAssuranceAutomapList = ['trafficDirection',
                               'splitTraffic'
                               ]
    
    # only used by wmlMetadata
    voipQualityList = ['deauth',
                       'pmkid',
                       'disassociate',
                       'learningPacketRate',
                       'dwellTime',
                       'renewDHCPonConn',
                       'preauth',
                       'backgroundTraffic',
                       'renewDHCP',
                       'durationUnits',
                       'repeatValue',
                       'powerProfileFlag',
                       'repeatType',
                       'reassoc',
                       'roamRate',
                       'AcceptableDroppedCalls',
                       'AcceptableRValue' 
                       ]

    # only used by wmlMetadata
    voipCallTrafficOptionsList = ['baseCallDurationUnits',
                                  'callDropDelayThreshold',
                                  'DestPort',
                                  'baseCallDurationVal',
                                  'SrcPort',
                                  'TosReserved',
                                  'TosDiffservDSCP',
                                  'UserPriority',
                                  'TosField',
                                  'voipCodec',
                                  'TosLowCost',
                                  'TosLowDelay',
                                  'TosHighReliability',
                                  'TosHighThroughput',
                                  'QoSEnabled'
                                  ]
                       
    incrFrameList = ['IncrStart',
                          'IncrEnd',
                          'Step'
                          ]
    iLoadList = ['ILoadStart',
                      'ILoadEnd',
                      'ILoadStep'
                      ]
    frameTypeList = ['FrameType']
    
    keysThatNeedEval = ['FrameSizeList', 
                             'ILoadList' 
                             ]
    
    securityMethodList = ['None','WEP-Open-40',
                           'WEP-Open-128',
                           'WEP-SharedKey-40',
                           'WEP-SharedKey-128',
                          'WPA-PSK','WPA-EAP-TLS',
                          'WPA-EAP-TTLS-GTC',
                          'WPA-PEAP-MSCHAPV2',
                          'WPA-EAP-FAST',
                          'WPA2-PSK',
                          'WPA2-EAP-TLS',
                          'WPA2-EAP-TTLS-GTC',
                          'WPA2-PEAP-MSCHAPV2',
                          'WPA2-EAP-FAST',
                          'DWEP-EAP-TLS',
                          'DWEP-EAP-TTLS-GTC',
                          'DWEP-PEAP-MSCHAPV2',
                          'LEAP',
                          'WPA-LEAP','WPA2-LEAP',
                          'WPA-PSK-AES',
                          'WPA-PEAP-MSCHAPV2-AES',
                          'WPA2-PEAP-MSCHAPV2-TKIP',
                          'WPA2-EAP-TLS-TKIP',
                          'WPA2-PSK-TKIP',
                          'WPA-CCKM-PEAP-MSCHAPv2-TKIP', 
                          'WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP',
                          'WPA-CCKM-TLS-TKIP', 
                          'WPA-CCKM-TLS-AES-CCMP',
                          'WPA-CCKM-LEAP-TKIP',
                          'WPA-CCKM-LEAP-AES-CCMP',
                          'WPA-CCKM-FAST-TKIP',
                          'WPA-CCKM-FAST-AES-CCMP',
                          'WPA2-CCKM-PEAP-MSCHAPv2-TKIP',
                          'WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP',
                          'WPA2-CCKM-TLS-TKIP',
                          'WPA2-CCKM-TLS-AES-CCMP', 
                          'WPA2-CCKM-LEAP-TKIP',
                          'WPA2-CCKM-LEAP-AES-CCMP',
                          'WPA2-CCKM-FAST-TKIP', 
                          'WPA2-CCKM-FAST-AES-CCMP']

    #Blog Elements List
    waveBlogStoreElementsList = ['BlogMode', 
                                  'BlogBinSetUpConfig'
                                  ]
    blogBinSetupConfigList = ['BinLow', 
                               'BinHigh', 
                               'BinStrikeProbability'
                               ]

    # root dictionaries for the convertToWmlConfig function call, in
    # argument order.
    rootDictionaries = ['waveChassisStore',
                        'wavePortStore',
                        'waveClientTableStore',
                        'waveSecurityStore',
                        'waveTestStore',
                        'waveTestSpecificStore',
                        'waveMappingStore',
                        'waveBlogStore']
    
    def __init__(self,fileName):
        self.fileName = fileName
        
        #XML tag names cannot start with integers, prepend with a unique
        #alaphabet(s) and strip when decoding the wml file
        self.__qualifierStrForIntKeys = 'Plc-Holder-STR_'

        if wmlMetadataAvailable:
            # init copy of wmlMetadata.
            self.wmlMetadata = wmlMetadata(self)
        else:
            self.wmlMetadata = None
        
    #returns a recursive dictionary of {tag : text}
    #for all children under root
    def _generateDictionary(self, root):
        children = root.getchildren()
        if len(children) == 0:
            elementText = root.text
            if elementText == None:#It's an empty tag
                elementText = '{}' #eval() to {}
            return eval(elementText)
        newDict = odict.OrderedDict()
        for child in children:
            if child.tag in ['RoamRate', 'BgTraffic', 'RoamTraffic']:
                pass
            else:
                tag = child.tag
                if self.__qualifierStrForIntKeys in tag:
                    tag = tag.strip(self.__qualifierStrForIntKeys)
                newDict[tag] = self._generateDictionary(child)
        return newDict

    #recursively creates children tags under root for data.
    def _generateTags(self, root, data):
        if isinstance(data, dict) == False:
            root.text = repr(data)
            return
        for key in data.keys():
            tag = key
            #XML tag names cannot start with integers, prepend with a unique
            #alaphabet(s) and strip when decoding the wml file
            if tag.isdigit():
                tag = self.__qualifierStrForIntKeys + str(key)
                
            newroot = ET.SubElement(root, str(tag))
            self._generateTags(newroot, data[key])

    def _loadTestName(self, root):
        testConfigElement = root.find('TestConfig')
        testSpecificConfigElement = testConfigElement.find("Test")
        
        testNameTag = testSpecificConfigElement.find("Name")
        if testNameTag == None:
            testName = testSpecificConfigElement.text
        else:
            testName = eval(testNameTag.text)
                    
        # VPR 5133: changed the test name from AAA auth load to AAA auth rate
        if testName == 'aaa_auth_load':
            testName = 'aaa_auth_rate'
            
        self.TestName = testName
    
    def _parseVersionElement(self, version):
        if version == None:
            return

        if version.text == "1.0" or version.text == "1.1":
            version.text = "1.2"
        if version.text == "1.2":
            # upgrade 1.2 to 1.3
            #  this version adds PrivateKey and renamed Ascii to KeyType
            version.text = "1.3"
        if version.text == "1.3":
            # upgrade 1.3 to 1.4
            # this version adds EnableValidateCertificate
            version.text = "1.4"
        if version.text == "1.4":
            #this version adds client learning, flow learning and removes
            #learning time
            version.text = "1.5"
        if version.text == "1.5":
            #this version adds qos_capacity support
            version.text = "1.6"
        if version.text == "1.6":
            #this version adds qos_service support
            version.text = "1.7"
        if version.text == "1.7":
            #this version adds per-client login (user/pw) support
            version.text = "1.8"
        if version.text == "1.8":
            # version 1.9 adds Ethernet VLAN tag support
            version.text = "1.9"
        if version.text == "1.9":
            # version 1.10 adds Proactive Key Caching support
            version.text = "1.10"
        if version.text == "1.10":
            # version 1.11 adds Anonymous Identity 
            version.text = "1.11"
        if version.text == "1.11":
            # version 1.12 adds voice/bk traffic options for QoS tests
            # It also replaced the old value for bk traffic direction
            version.text = "1.12"   
        if version.text == "1.12":
            #WaveMapping Store used for roaming benchmark was added in Revision 1.53 (CVS) of 
            #this file. The data strcuture (WaveMapping store) has been changed (source/destination
            #client storage) and corresponding changes are made in this verion
            version.text =   "1.13"               
        if version.text == "1.13":
            #WaveMapping store used for roaming benchmark is removed, the data related to
            #Roam Traffic, Background Traffic mappings are moved to test specific store.
            #Also, a new element 'RoamRate' has been added to the test specific store
            version.text = "1.14"
        if version.text == "1.14":
            #Added Many to One mapping for Wireless to Ethernet traffic for max client capacity
            version.text = "1.15" 
        if version.text == "1.15":
            #Added TCP Goodput to benchmark test
            version.text = "1.16"                  
        if version.text == "1.16":
            #Added a new element 'renewDHCP' to test specific dict of roaming tests
            version.text = "1.17"            
        if version.text == "1.17":
            #Added a new element 'renewDHCPonConn' to test specific dict of roam tests
            version.text = "1.18" 
        if version.text == "1.18":
            #Added 802.11e QoS in client options & Traffic Class in client table
            version.text = "1.19"    
        if version.text == "1.19":
            #Added AAA Auth. Load test & wifi client Tx power level in client advanced tab
            #Added mesh test suite
            version.text = "1.20"     
        if version.text == "1.20":
            #Added the capability to have a list as a node element
            version.text = "1.21"    
        if version.text == "1.21":
            #Changes for 11n
            version.text = "1.22" 
        if version.text == '1.22':
            #Changes for multi-port card
            version.text = '1.23'
        if version.text == '1.23':
            #Changes for user specified theoretical throughput
            version.text = '1.24'
        if version.text == '1.24':
            #Bump up the version major number to indicate the tectonic change
            #in the file structure brought about by multi-port card changes
            #(which were actually made with version 1.23)
            version.text = '2.0'
        # check for bad version
        if not self._parsableVerion(version):
            raise WE.NotParsableVersionError
    
    def _parsableVerion(self, versionElement):
        majorNum = versionElement.text.split('.')[0]
        majorNumOfCurrVersion = self.CURRENT_VERSION.split('.')[0]
        
        return (majorNum == majorNumOfCurrVersion)
        
    def _getWaveChassisStore(self, chassisConfig, fileVersion):
        waveChassisStore = {}
        
        if not chassisConfig:
            return waveChassisStore
        
        listOfChassis = chassisConfig.getchildren()
        for eachChassisName in listOfChassis:
            chassisName = eachChassisName.text
            waveChassisStore[chassisName] = {}
            cardsList = eachChassisName.getchildren()
            for eachCardName in cardsList:
                cardName = eachCardName.text
                waveChassisStore[chassisName][cardName] = {}
                
                portInfo = self._getPortInfo(eachCardName, fileVersion)
                
                waveChassisStore[chassisName][cardName] = portInfo
        
        waveChassisStore = portSetupModel.normalizeWMLdata(waveChassisStore)
        
        return  waveChassisStore
    
    def _getPortInfo(self, cardElement, fileVersion):
        """
        TODO: portSetup.portSetup has normalizeWMLData, use it instead of the
        except-and-if's block below thus getting rid of code logic centered around
        portSetupModel.waveChassisStoreElementsList
        """
        portInfo = {}

        portInfoElementList = self._getPortInfoElementList(cardElement, 
                                                           fileVersion)            
        for portInfoElement in portInfoElementList:
            portName = portInfoElement.find('PortName').text
            dummyDict = {}
            for eachwaveChassisStoreElement in portSetupModel.waveChassisStoreElementsList:
                try:
                    text = portInfoElement.find(eachwaveChassisStoreElement).text
                except:
                    # missing parameter
                    # Card Mode added in version 1.20
                    if eachwaveChassisStoreElement == 'CardMode': text = 'TGA'  
                
                    #hiddenSSIDs added in version 1.21,
                    #ensure backward comptability
                    if eachwaveChassisStoreElement == 'hiddenSSIDs': 
                        text = ''
                    
                    if eachwaveChassisStoreElement == 'Band':
                        text = 'None' 
                    
                    if eachwaveChassisStoreElement == 'SecondaryChannelPlacement':
                        text = 'defer'
                    
                    if eachwaveChassisStoreElement == 'EnableRxAttenuation':
                        text = 'on'
                #When we have an element which is a list, convert it into a
                #python list (from its current str format).
                try:
                    if isinstance (eval(text), list):
                        text = eval(text) 
                except:
                    pass        
                                        
                dummyDict[eachwaveChassisStoreElement] = text
                if (text == "8023"):
                    for eachwaveChassisStoreEthernetElement in self.waveChassisStoreEthernetElementsList:
                        elementPos = portInfoElement.find(eachwaveChassisStoreEthernetElement)
                        dummyDict[eachwaveChassisStoreEthernetElement] = elementPos.text                              
            portInfo[portName] = dummyDict.copy()
        
        return portInfo
    
    def _getPortInfoElementList(self, cardElement,fileVersion):
        fileVersion = float(fileVersion) 
        if fileVersion < 1.22:
            portInfoElementList = [cardElement]
        elif fileVersion == 1.22:
            #Structural changes were made in rev 6236 but till 6487 wml
            #version number wasn't changed, some non-release builds during this 
            #time ended in customers' hands. Check for this case
            
            #Below, why cardElement.find('Port').find('PortName').tag and not
            #cardElement.find('Port').find('PortName')? coz elementtree says
            #bool(cardElement.find('Port').find('PortName')) is False even when 
            #there is an element, bug in elementtree?
            if (not cardElement.find('PortName')
                and (cardElement.find('Port')
                     and
                     (cardElement.find('Port').find('PortName') != None
                      and cardElement.find('Port').find('PortName').tag)
                     )
                ):
                portInfoElementList = cardElement.getchildren()
            else:
                portInfoElementList = [cardElement]
        else:             
            portInfoElementList = cardElement.getchildren()
            
        return portInfoElementList
    
    def _getWaveBlogStore(self, blogConfig):
        waveBlogStore = {}
        
        if not blogConfig:
            return waveBlogStore
        
        listOfPortNames = blogConfig.getchildren()
        for eachPortName in listOfPortNames:
            portName = eachPortName.text
            listOfBlogProperties = eachPortName.getchildren()
            portDict = {}
            for eachBlogStoreElement in listOfBlogProperties:
                blogStoreName = eachBlogStoreElement.tag
                if blogStoreName == 'BlogMode':
                    blogMode = eachBlogStoreElement.text
                    portDict[blogStoreName] = blogMode
                if blogStoreName == 'BlogBinSetUpConfig':
                    binNamesList = eachBlogStoreElement.getchildren()
                    blogPropDict = {}
                    for eachBinName in binNamesList:    
                        binName = eachBinName.tag
                        binDict = {}
                        for eachBlogSetupConfigParm in self.blogBinSetupConfigList:
                            elementPos = eachBinName.find(eachBlogSetupConfigParm)
                            binDict[eachBlogSetupConfigParm] = elementPos.text
                        blogPropDict[binName] = binDict    
                    portDict[blogStoreName] = blogPropDict
            waveBlogStore[portName] = portDict
    
        return waveBlogStore
    
    def _getWavePortStore(self, portPropertiesConfig):
        wavePortStore = {}
        
        if not portPropertiesConfig:
            return wavePortStore
        
        listOfPortNamesScanned = portPropertiesConfig.getchildren()
        for eachPortName in listOfPortNamesScanned:
            portName = eachPortName.text
            numBssidSsidPairs = eachPortName.getchildren()
            dummyDict = {}
            for eachBssidSsidPair in numBssidSsidPairs:
                bssidSsidInfo = eachBssidSsidPair.getchildren()
                bssid = bssidSsidInfo[0].text
                ssid = bssidSsidInfo[1].text
                dummyDict[bssid] = ssid
            wavePortStore[portName] = dummyDict
        
        return wavePortStore
    
    def _getClientTableStore(self, clientProfileConfig):
        waveClientTableStore = {}
        
        if not clientProfileConfig:
            return  waveClientTableStore
        
        listOfClientGroups = clientProfileConfig.getchildren()
        for eachClientGroupConfig in listOfClientGroups:
            groupName = (eachClientGroupConfig.find('Name')).text
            waveClientTableStore[groupName] = self._getClientGroupInfo(eachClientGroupConfig)
    
        return waveClientTableStore
    
    def _getClientGroupInfo(self, eachClientGroupConfig):
        #Parse the basic client group properties
        clientGroupInfoDict = {}
        for eachwaveClientTableElement in self.waveClientTableElementsList:
            try:
                text = eachClientGroupConfig.find(eachwaveClientTableElement).text

            except:
                # missing parameter
                # Traffic Class added in version 1.19
                if eachwaveClientTableElement == 'TrafficClass': 
                    text = 'Voice' 
                # NodeId & Hops added in version 1.20
                if eachwaveClientTableElement == 'NodeId': 
                    text = 'Node_0'
                if eachwaveClientTableElement == 'Hops': 
                    text = -1                         
                
                if eachwaveClientTableElement == 'BehindNAT':
                    text = 'False'      
                
                if eachwaveClientTableElement == 'CtsToSelf':
                    text = 'off'                                             
            if (eachwaveClientTableElement == "Name"):
                groupName = str(text)
            clientGroupInfoDict[eachwaveClientTableElement] = text
        #Parse the ipv4 properties for the client group
        ipv4pos = eachClientGroupConfig.find("Ipv4")
        for eachIpv4InfoElement in self.waveClientTableIpv4List:
            ipv4TagPos = ipv4pos.find(eachIpv4InfoElement)
            clientGroupInfoDict[eachIpv4InfoElement] = ipv4TagPos.text
        #Parse the mac address properties for the client group
        macPos = eachClientGroupConfig.find("Mac")
        for eachMacInfoElement in self.waveClientTableMacList:
            macTagPos = macPos.find(eachMacInfoElement)
            clientGroupInfoDict[eachMacInfoElement] = macTagPos.text
        #Parse the performance properties for the client group
        performancePos = eachClientGroupConfig.find("Performance")
    
        for eachPerformanceElement in (self.waveClientTableOptionsList):
            try:
                childElement = performancePos.find(eachPerformanceElement)
                elementTag = childElement.tag
                if elementTag == 'nPhySettings':
                    value = self._generateDictionary(childElement)
                else:
                    value = childElement.text
                
            except:
                # missing parameters
                value = ""
                # VLAN added in version 1.9
                if eachPerformanceElement == 'VlanEnable': 
                    value = False
                if eachPerformanceElement == 'VlanUserPriority': 
                    value = 0
                if eachPerformanceElement == 'VlanCfi': 
                    value = False
                if eachPerformanceElement == 'VlanId': 
                    value = 0
                # Proactive Key Caching added in version 1.10
                if eachPerformanceElement == 'ProactiveKeyCaching': 
                    value = False
                # 802.11e QoS added in version 1.19
                if eachPerformanceElement == 'Wlan80211eQoSEnable': 
                    value = False
                if eachPerformanceElement == 'Wlan80211eQoSAC': 
                    value = 'AC_BE/Best Effort'
                # wifi client Tx power level added in version 1.20
                if eachPerformanceElement == 'TxPower': 
                    value = -6
                #if eachPerformanceElement == 'BOnlyMode': value = False  
                if eachPerformanceElement == 'KeepAlive': 
                    value = False  
                if eachPerformanceElement == 'KeepAliveRate': 
                    value = 10
                if eachPerformanceElement == 'phyInterface': 
                    value = "802.11ag"
                defaultNphySettings = {
                                       'DataMCSindex': 15,
                                       'GuardInterval': 'standard',
                                       'ChannelBandwidth': 20,
                                       'PlcpConfiguration': 'mixed',
                                       'ChannelModel': 'None',
                                       'EnableAMPDUaggregation': 'False'
                                       }                                                                                    
                if eachPerformanceElement == 'nPhySettings': 
                    value = defaultNphySettings
            clientGroupInfoDict[eachPerformanceElement] = value
        #Handle bOnlyMode, which could be present in older wml files
        try:
            childElement = performancePos.find('BOnlyMode')
            value = childElement.text
            if value.lower() == 'true':
                clientGroupInfoDict['phyInterface'] = "802.11b"
        except:
            pass
    
        #All these elements get copied into the waveClientTableStore
        return clientGroupInfoDict
    
    def _getClientSecurityStore(self, clientProfileConfig):
        waveSecurityStore = {}
        
        if not clientProfileConfig:
            return waveSecurityStore
        
        listOfClientGroups = clientProfileConfig.getchildren()
        for eachClientGroupConfig in listOfClientGroups:
            groupName = (eachClientGroupConfig.find('Name')).text
            waveSecurityStore[groupName] = self._getGroupSecurityInfo(eachClientGroupConfig)
        
        return waveSecurityStore
    
    def _getGroupSecurityInfo(self, eachClientGroupName):
        #Parse the security properties for the client group
        securityDict = {}
        securityPos = eachClientGroupName.find("Security")
        securityMethod = (securityPos.find("Method")).text
        
        if securityMethod in self.securityMethodList:
            for i in range(0,len(self.waveSecurityList)):
                securityParameter = self.waveSecurityList[i]
                # handle missing PrivateKey
                # handle Ascii->KeyType translation
                try:
                    text = securityPos.find(securityParameter).text
                except:
                    if securityParameter == 'EthNetworkAuthMethod':
                        text = 'None'
                    elif securityParameter == 'StartIndex':
                        text = '1'
                    else:
                        # missing parameter
                        text = ""
                if text == None:
                    text = ""
                securityDict[securityParameter] = text
        try:
            text = securityPos.find("Ascii").text
            if str(text) == 'True':
                securityDict['KeyType'] = 'ascii'
            else:
                securityDict['KeyType'] = 'hex'
        except:
            pass # nothing to translate
        
        return securityDict
    
    def _getWaveTestStore(self, testConfigElement, trafficsElement):
        waveTestStore = {}
        
        if testConfigElement:
            waveTestStoreInfo = self._getWaveTestStoreInfo(testConfigElement)
            waveTestStore.update(waveTestStoreInfo)
                    
        #Parsing the Traffics Section from the WML file
        if trafficsElement:
            waveTestStore['Traffics'] = self._getTrafficInfo(trafficsElement)
        
        waveTestStore = GTSM.normalizeWMLdata(waveTestStore,
                                              self.TestName)
        
        return waveTestStore
    
    def _getWaveTestStoreInfo(self, testConfigPos):
        waveTestStoreInfo = {}
        
        learnFlowElement = testConfigPos.find("Learning")
        waveTestStoreInfo['Learning'] = self._getLearningFlowInfo(learnFlowElement)
        
        connPos = testConfigPos.find("Connection")
        waveTestStoreInfo['Connection'] = self._getConnectionInfo(connPos)                
            
        dutInfoPos = testConfigPos.find("DutInfo")
        waveTestStoreInfo['DutInfo'] = self._getDUTinfo(dutInfoPos)
        
        testParmPos = testConfigPos.find("TestParameters")
        waveTestStoreInfo['TestParameters'] = self._getTestParameters(testParmPos)
    
        logsAndResultsPos = testConfigPos.find("LogsAndResultsInfo")
        waveTestStoreInfo['LogsAndResultsInfo'] = self._getLogAndResultsInfo(logsAndResultsPos)
        
        return waveTestStoreInfo
    
    def _getTrafficInfo(self, trafficsInfo):
        trafficsDict = {}
        for trafficElement in GTSM.waveTestTrafficList:
            trafficType = trafficsInfo.find(trafficElement)
            trafficsDict[trafficElement] = trafficType.text
            
        if trafficType.text == "Udp":
            udpInfoPos = trafficsInfo.find(trafficType.text)
            for eachUdpElement in GTSM.waveTestUdpList:
                udpTag = udpInfoPos.find(eachUdpElement)
                trafficsDict[eachUdpElement] = udpTag.text
        
        if trafficType.text == "Icmp":
            icmpInfoPos = trafficsInfo.find(trafficType.text)
            for eachIcmpElement in GTSM.waveTestIcmpList:
                icmpTag = icmpInfoPos.find(eachIcmpElement)
                trafficsDict[eachIcmpElement] = icmpTag.text
                
        if trafficType.text == "Tcp":
            tcpInfoPos = trafficsInfo.find(trafficType.text)
            for eachTcpElement in GTSM.waveTestTcpList:
                tcpTag = tcpInfoPos.find(eachTcpElement)
                trafficsDict[eachTcpElement] = tcpTag.text
            for eachTcpFlag in GTSM.waveTestTcpFlagsList:
                tcpFlag = tcpInfoPos.find(eachTcpFlag)
                trafficsDict[eachTcpFlag] = tcpFlag.text
        
        if trafficType.text == "Raw":
            rawInfoPos = trafficsInfo.find(trafficType.text)
            for eachRawElement in GTSM.waveTestRawList:
                rawTag = rawInfoPos.find(eachRawElement)
                trafficsDict[eachRawElement] = rawTag.text
                
        payloadPos = trafficsInfo.find("Payload")
        for eachPayloadOption in GTSM.waveTestPayloadList:
            payloadTag = payloadPos.find(eachPayloadOption)
            trafficsDict[eachPayloadOption] = payloadTag.text   
    
        return trafficsDict
        
    def _getLearningFlowInfo(self, learningPos):
        learningDict = {}
        for learningParameter in GTSM.waveTestLearningList:
            #handle missing client learning and flow learning keys
            try:
                text = learningPos.find(learningParameter).text
            except:
                #missing parameter
                text = "0"
                if learningParameter == "ClientLearningTime":
                    text = "1"
                if learningParameter == "FlowLearningTime":
                    text = "2"
            learningDict[learningParameter] = text
        
        return learningDict
    
    def _getConnectionInfo(self, connPos):
        connInfoDict = {}
        for connParameter in GTSM.waveTestConnectionList:
            #handle missing connection properties
            try:
                text = connPos.find(connParameter).text
            except:
                #missing parameter
                if connParameter == "ConnectionType":
                    text = "Aggregate"
                elif connParameter == "AssocTimeout":
                    text = "20"
                elif connParameter == "AssocRate":
                    text = "2"                            
            connInfoDict[connParameter] = text
        
        return connInfoDict
    
    def _getDUTinfo(self, dutInfoPos):
        dutInfoDict = {}
        for eachDutInfoParm in GTSM.waveTestDutInfoList:
            dutInfoTag = dutInfoPos.find(eachDutInfoParm)
            dutInfoDict[eachDutInfoParm] = dutInfoTag.text
        
        return dutInfoDict
    
    def _getTestParameters(self, testParmPos):  
        testParmDict = {}
        for eachTestParm in GTSM.waveTestParametersList:
            try:
                text = testParmPos.find(eachTestParm).text
            except:
                #add new parameter called client contention
                text = "0"
                if eachTestParm == "ClientContention":
                    text = "0"
            testParmDict[eachTestParm] = text
    
        return testParmDict
    
    def _getLogAndResultsInfo(self, logsAndResultsPos):
        logsAndResultsDict = {}
        for eachLogsAndResultsParm in GTSM.waveLogsAndResultsInfoList:
            logsAndResultsParmTag = logsAndResultsPos.find(eachLogsAndResultsParm)
            if logsAndResultsParmTag != None:    #Allows new additions to the dictionary and thus ensures backward compatiblity with existing Wml files
                logsAndResultsDict[eachLogsAndResultsParm] = logsAndResultsParmTag.text
            else:    #Default values to be used by earlier wml files
                if eachLogsAndResultsParm == "GeneratePdfReport":
                    logsAndResultsDict[eachLogsAndResultsParm] = 'True'
        
        return logsAndResultsDict
    
    def _getWaveTestSpecificStore(self, testSpecificConfigElement):
        waveTestSpecificStore = {}
            
        if self.TestName in [ "roaming_delay",
                         "qos_capacity",
                         "qos_service",
                         "roaming_benchmark",
                         "voip_roam_quality",
                         "roaming_stress"]:
                  
            waveTestSpecificStore[self.TestName] = self._getWaveTestSpecificStoreForMode2(testSpecificConfigElement) 
        else:
            if testSpecificConfigElement.text != None:
                waveTestSpecificStore[testSpecificConfigElement.text] = self._getWaveTestSpecificStoreForMode1(testSpecificConfigElement)
        
        return waveTestSpecificStore
        
    def _getWaveTestSpecificStoreForMode1(self, testSpecificConfigElement):
        testSpecificDict = {}
        keyList = []
    
        # bench_latency & mesh latency
        if testSpecificConfigElement.text in ["unicast_latency",
                                    "mesh_latency_per_hop",
                                    "mesh_latency_aggregate"]:
            keyList = self.latencyList
        # bench_tput & mesh tput
        if testSpecificConfigElement.text in ["unicast_unidirectional_throughput", 
                                    "mesh_throughput_per_hop",
                                    "mesh_throughput_aggregate"]:
            keyList = self.tputList
        # bench_maxfr * mesh mfr
        if testSpecificConfigElement.text in ["unicast_max_forwarding_rate",
                                    "mesh_max_forwarding_rate_per_hop"]:
            keyList = self.maxfrList
        # tcp_tcpgoodput
        if testSpecificConfigElement.text == "tcp_goodput":
            keyList = self.tcpGoodputList   
        # aaa_auth_rate
        if testSpecificConfigElement.text == "aaa_auth_rate" or \
           testSpecificConfigElement.text == "aaa_auth_load": # VPR 5133: backward compatibility with old test name
            keyList = self.authRateList                                        
        # bench_pktloss
        if testSpecificConfigElement.text == "unicast_packet_loss":
            keyList = self.packetLossList
        # max client capacity
        if testSpecificConfigElement.text == "unicast_max_client_capacity":
            keyList = self.maxccList
        #rate vs. range test
        if testSpecificConfigElement.text == "rate_vs_range":
            keyList = self.rateVsRangeList
        # call capacity
        if testSpecificConfigElement.text == "unicast_call_capacity":
            keyList = self.callCapacityList
        if testSpecificConfigElement.text in ["voip_roam_quality", "roaming_benchmark"]:
            keyList = self.roamKeyList               
    
        # loop thru tags
        for key in keyList:
            # find node in XML
            tag = testSpecificConfigElement.find( key )
            #This is a test 
            if tag == None:
                #This is a new tag named 'Mode' added in version 1.1
                #in the throughput test 
                if key == "Mode":
                    value = "Fps"
                #This is a new tag named 'ILoadMode' added in version 1.1
                #in the latency and packet loss tests
                if testSpecificConfigElement.text == "unicast_packet_loss" or  testSpecificConfigElement.text == "unicast_latency":
                    if key == "ILoadMode":
                        value = "Custom"
                if testSpecificConfigElement.text in ["voip_roam_quality", "roaming_benchmark"]:
                    if key in ['renewDHCP', 'renewDHCPonConn']:
                        value = 0
                # 'DisconnectClients' added to AAA test
                if key == 'DisconnectClients':
                    value = 'True'
                # 'TcpWindowSize' added to TCP Goodput test
                if key == 'TcpWindowSize':
                    value = 65535
                    
                if key == 'MediumCapacity':
                #For now choosing to go with class variable which has the default 
                #user specified medium capacity config. TODO- create a class method
                #in the respective modules to normalize their datastores
                    value = STS.DefaultUserSpecifiedMedCapacityConfig    
                
            else:
                #This is for supporting version 1.0 of the WML parser
                #where MinSearchValue had a default value of 0 instead
                #of the string "Default"
                if (key == 'MinSearchValue') and (tag.text == '0'):
                    value = 'Default'
                #This is for supporting version 1.0 of the WML parser
                #where MaxSearchValue had a default value of 0 instead
                #of the string "Default"
                elif (key == 'MaxSearchValue') and (tag.text == '0'):
                    value = 'Default'
                elif (key == 'StartValue') and (tag.text == '0'):
                    value = 'Default'
                #Change in rev 1.24, user specifiable 'MediumCapacity' added 
                elif key == 'MediumCapacity':
                    value = self._generateDictionary(tag)
                else:
                    # get value from node
                    value = tag.text
            # convert to python object from string if needed
            if key in self.keysThatNeedEval:
                value = eval( value )
            # save value
            testSpecificDict[ key ] = value
        #
        if testSpecificConfigElement.text == "frame_generator":
            fgDict = dict()
            intList = ['assocId', 'subType', 'fragnum', 'duration',
                       'rCode','beaconInt','sCode','authAlgo','channel',
                       'fType','authStatus', 'authSeq']
            for fgElements in testSpecificConfigElement.getchildren():
                fgDict[fgElements.tag] = dict()
                for fgSubElements in fgElements.getchildren():
                    fgDict[fgElements.tag][fgSubElements.tag] = eval(fgSubElements.text)  
            
            testSpecificDict = fgDict 
        
        return testSpecificDict
    
    def _getWaveTestSpecificStoreForMode2(self, testSpecificConfigElement):
        #not a good fix by making SpecificStore = {} again, but
        #waveTestSpecificStore was getting an extra key of 
        #'\n' from testSpecificPos.text
        waveTestSpecificStore = {}
        TestName = self.TestName
        testSpecificDict = self._generateDictionary(testSpecificConfigElement)
        del testSpecificDict["Name"]
        
        #Handle new keys added to the roaming Test Specific dictionary, 
        #this is different than the handling of new keys in other tests
        #as done in above code (for benchmark tests) because roaming tests 
        #have test specifict data as group based too, 
        #i.e., waveTestSpecificStore{testName:{Group1Name:{data}}...} as 
        #opposed to benchmark tests which have waveTestSpecificStore{testName:{data}}
        if TestName in ["roaming_stress", "roaming_delay"]:
            for eachElement in testSpecificDict.keys():
                if eachElement not in ['RoamRate', 'BgTraffic', 'RoamTraffic'] \
                    and eachElement not in self.roamKeyList:    #i.e., the element is a Group Name
                    for eachNewKey in self.roamKeyList:        #Both the roam tests have the same key list
                        if eachNewKey not in testSpecificDict[eachElement].keys():
                            if eachNewKey == 'renewDHCP':
                                testSpecificDict[eachElement]['renewDHCP'] = 0
                            elif eachNewKey == 'renewDHCPonConn':
                                testSpecificDict[eachElement]['renewDHCPonConn'] = 0
        
        if TestName in ["voip_roam_quality", "roaming_benchmark"]:
            roamRatetag = testSpecificConfigElement.find("RoamRate")
            roamRate = roamRatetag.text
            i = 0
            roamTrafficMap = []
            roamTrafficConfig = testSpecificConfigElement.find("RoamTraffic")
            mappingConfigList = roamTrafficConfig.getchildren()
            for eachMappingConfigParm in mappingConfigList:
                mapConfigTag = eachMappingConfigParm.tag
                if mapConfigTag == "Mappings":
                    flowMapInfoTagList = eachMappingConfigParm.getchildren()
                    for eachMappingParm in flowMapInfoTagList:
                        flowMapTag = eachMappingParm.tag
                        roamTrafficMap.insert(i,[])
                        if flowMapTag == "Mapping":
                            mappingTagList = eachMappingParm.getchildren()
                            for eachMappingDetail in mappingTagList:
                                mappingDetailTag = eachMappingDetail.tag
                                if mappingDetailTag == "SourceClient":
                                    roamTrafficMap[i].insert(0, eachMappingDetail.text)
                                elif mappingDetailTag == "DestClient":
                                    roamTrafficMap[i].insert(1, eachMappingDetail.text)
                        i += 1
            testSpecificDict['roamRate'] = float(roamRate)
            testSpecificDict['roamTraffic'] = roamTrafficMap
       
        if TestName == "roaming_stress":
            roamRatetag = testSpecificConfigElement.find("RoamRate")
            roamRate = roamRatetag.text
            i = 0
            backgroundTrafficMap = [[],[]]
            bgTrafficConfig = testSpecificConfigElement.find("BgTraffic")
            mappingConfigList = bgTrafficConfig.getchildren()
            for eachMappingConfigParm in mappingConfigList:
                mapConfigTag = eachMappingConfigParm.tag
                if mapConfigTag == "Mappings":
                    flowMapInfoTagList = eachMappingConfigParm.getchildren()
                    for eachMappingParm in flowMapInfoTagList:
                        flowMapTag = eachMappingParm.tag
                        backgroundTrafficMap[0].insert(i,[])
                        if flowMapTag == "Mapping":
                            mappingTagList = eachMappingParm.getchildren()
                            for eachMappingDetail in mappingTagList:
                                mappingDetailTag = eachMappingDetail.tag
                                if mappingDetailTag == "SourceClient":
                                    backgroundTrafficMap[0][i].insert(0, eachMappingDetail.text)
                                elif mappingDetailTag == "DestClient":
                                    backgroundTrafficMap[0][i].insert(1, eachMappingDetail.text)
                                elif mappingDetailTag == "TrafficType":
                                    backgroundTrafficMap[0][i].insert(2, eachMappingDetail.text)
                                elif mappingDetailTag == "TrafficDirection":
                                    backgroundTrafficMap[0][i].insert(3, eachMappingDetail.text)
                                
                        i += 1
                elif mapConfigTag == "OtherStateInfo":
                    mapOtherStateList = eachMappingConfigParm.getchildren()
                    for eachStateInfo in mapOtherStateList:
                        mapOtherStateInfotag = eachStateInfo.tag
                        if mapOtherStateInfotag == "TraffDirectionCheckbox":
                            backgroundTrafficMap[1].insert(0, eachStateInfo.text)
                        elif mapOtherStateInfotag == "TraffTypeComboBox":
                            backgroundTrafficMap[1].insert(1, eachStateInfo.text)
            
            i = 0
            roamTrafficMap = []
            roamTrafficConfig = testSpecificConfigElement.find("RoamTraffic")
            mappingConfigList = roamTrafficConfig.getchildren()
            for eachMappingConfigParm in mappingConfigList:
                mapConfigTag = eachMappingConfigParm.tag
                if mapConfigTag == "Mappings":
                    flowMapInfoTagList = eachMappingConfigParm.getchildren()
                    for eachMappingParm in flowMapInfoTagList:
                        flowMapTag = eachMappingParm.tag
                        roamTrafficMap.insert(i,[])
                        if flowMapTag == "Mapping":
                            mappingTagList = eachMappingParm.getchildren()
                            for eachMappingDetail in mappingTagList:
                                mappingDetailTag = eachMappingDetail.tag
                                if mappingDetailTag == "SourceClient":
                                    roamTrafficMap[i].insert(0, eachMappingDetail.text)
                                elif mappingDetailTag == "DestClient":
                                    roamTrafficMap[i].insert(1, eachMappingDetail.text)
                        i += 1
            testSpecificDict['roamRate'] = float(roamRate)
            testSpecificDict['backgroundTraffic'] = backgroundTrafficMap
            testSpecificDict['roamTraffic'] = roamTrafficMap
        # Convert old value for background traffic direction
        # We no longer use 'Ethernet to Wireless' / 'Wireless to Ethernet'
        # Instead we replace them with 'Unidirectional' 
        if TestName in ["qos_capacity", "qos_service"]:
            if not testSpecificDict['Background'].has_key( 'Direction' ) or \
            testSpecificDict['Background']['Direction'].upper() in ['ETHERNET TO WIRELESS', 'WIRELESS TO ETHERNET']:
                testSpecificDict['Background']['Direction'] = 'Unidirectional'
        
        return testSpecificDict
                
    def _getWaveMappingStore(self, mappingConfig):
        waveMappingStore = []
        mappingConfigList = mappingConfig.getchildren()
        for eachMappingConfigParm in mappingConfigList:
            mapConfigTag = eachMappingConfigParm.tag
            
            if mapConfigTag == "SourceDestinationInfo":
                mapInfoTagList = eachMappingConfigParm.getchildren()
                sourceGroupList = []
                destinationGroupList = []
                flowOptionsDict = {}
                
            for eachMapInfoTagParm in mapInfoTagList:
                
                if (eachMapInfoTagParm.tag == "MappingOptions"):
                    waveMappingStore.append(eachMapInfoTagParm.text)
                
                if (eachMapInfoTagParm.tag == "Source"):
                    sourceGroupList = eval(eachMapInfoTagParm.text)
                    waveMappingStore.append(sourceGroupList)
                
                if (eachMapInfoTagParm.tag == "Destination"):
                    destinationGroupList = eval(eachMapInfoTagParm.text)
                    waveMappingStore.append(destinationGroupList)
                 
            for eachMapInfoTagParm in mapInfoTagList:
                if (eachMapInfoTagParm.tag == "MappingType"):
                    waveMappingStore.append(eachMapInfoTagParm.text)
                    
                if (eachMapInfoTagParm.tag == "FlowDirection"):
                    waveMappingStore.append(eachMapInfoTagParm.text)
    
                if (eachMapInfoTagParm.tag == "FlowOptions"):
                    flowOptionsTagList = eachMapInfoTagParm.getchildren()
                    
                    for eachFlowOption in flowOptionsTagList:
                        if (eachFlowOption.tag == "PhyRate"):
                            flowOptionsDict['PhyRate'] = eachFlowOption.text
                        
                        if (eachFlowOption.tag == "Type"):
                            flowOptionsDict['Type'] = eachFlowOption.text
                            
                        if (eachFlowOption.tag == "SourcePort"):
                            flowOptionsDict['SourcePort'] = eachFlowOption.text
                                    
                        if (eachFlowOption.tag == "DestinationPort"):
                            flowOptionsDict['DestinationPort'] = eachFlowOption.text
                                
                    waveMappingStore.append(flowOptionsDict)
                if (eachMapInfoTagParm.tag == "ConnectMode"):
                    waveMappingStore.append(eachMapInfoTagParm.text)
    
        return waveMappingStore
    
    def _doNormalizations(self, 
                          root, 
                          waveChassisStore,
                          wavePortStore,
                          waveClientTableStore,
                          waveSecurityStore,
                          waveTestStore,
                          waveTestSpecificStore,
                          waveMappingStore,
                          waveBlogStore):
        """
        To ensure forward compatibility of the wml files, check whether wml 
        files have the required parameters for the given dictionary, 
        if not (which could be the case say when the wml is of older version, 
        add those elements with default values
    
        """
        mappingConfig = root.find('MapConfig')
        waveMappingStore = self._normalizeWaveMappingStore(mappingConfig,
                                                           waveMappingStore)
        
        testConfigElement = root.find('TestConfig')
        testSpecificConfigElement = testConfigElement.find("Test") 
        waveTestSpecificStore = self._normalizeWaveTestSpecificStore(testSpecificConfigElement,
                                                                     waveTestSpecificStore)
    
    
    
        return  ( waveChassisStore,
                 wavePortStore,
                 waveClientTableStore,
                 waveSecurityStore,
                 waveTestStore,
                 waveTestSpecificStore,
                 waveMappingStore,
                 waveBlogStore )
    
    
    def _normalizeWaveMappingStore(self, mappingConfig, waveMappingStore):
        mappingConfigList = mappingConfig.getchildren()
        for eachMappingConfigParm in mappingConfigList:
            mapConfigTag = eachMappingConfigParm.tag
            
            if mapConfigTag == "SourceDestinationInfo":
                mapInfoTagList = eachMappingConfigParm.getchildren()
                
                existingElementList = mapInfoTagList
                #mappingElements would contain the elements that are added to 
                #mapping store in later versions of wml file, i.e., they wouldn't be 
                #present in earlier versions of the wml file
                mappingElements = ['ConnectMode']
                for element in mappingElements:
                    if element not in existingElementList:
                        if element == 'ConnectMode':
                            #Default connect mode is 'infrastructure'
                            #The check of len(waveMappingStore) > 1 is a hack to
                            #get around the problem we have (elsewhere, 
                            #waveMappingStore[0] is accessed to get the mapping type)
                            #when a default config is loaded, it wouldn't be so much 
                            #of a problem if waveMappingStore was rather a dictionary. 
                            if len(waveMappingStore) > 1:
                                waveMappingStore.append('infrastructure')
        
        return waveMappingStore
    
    def _normalizeWaveTestSpecificStore(self, 
                                        testSpecificConfigElement, 
                                        waveTestSpecificStore):
           
        TestName = self.TestName
        if TestName not in [ 'roaming_delay',
                             'unicast_call_capacity',
                             'qos_capacity',
                             'qos_service',
                             'roaming_benchmark',
                             'voip_roam_quality',
                             'roaming_stress',
                             'aaa_auth_rate',
                             'frame_generator',
                             'rate_vs_range' ]:
            testSpecificDict = {}
            if (waveTestSpecificStore[TestName]['Frame']) == "Increment":
                for eachIncrParm in self.incrFrameList:
                    eachIncrParmTag = testSpecificConfigElement.find(eachIncrParm)
                    testSpecificDict[eachIncrParm] = eachIncrParmTag.text
                waveTestSpecificStore[TestName].update(testSpecificDict)
            
            if (waveTestSpecificStore[TestName]['Frame']) == "Standard":
                for eachFrameTypeParm in self.frameTypeList:
                    eachFrameTypeParmTag = testSpecificConfigElement.find(eachFrameTypeParm)
                    testSpecificDict[eachFrameTypeParm] = eachFrameTypeParmTag.text
                waveTestSpecificStore[TestName].update(testSpecificDict)
            
            #If its a unicast packet loss or unicast latency test then verify if the Intended Load Mode
            #is Custom or Increment Step. If the ILoadMode is Increment Step then parse the additional
            #tags of self.ILoadList and store them as well
            if TestName == "unicast_packet_loss" or  TestName == "unicast_latency":
                if (waveTestSpecificStore[TestName]['ILoadMode']) == "Increment": 
                    for eachILoadParm in self.iLoadList:
                        eachILoadTag = testSpecificConfigElement.find(eachILoadParm)
                        testSpecificDict[eachILoadParm] = eachILoadTag.text
                waveTestSpecificStore[TestName].update(testSpecificDict)
        
        return waveTestSpecificStore
    
    
    def parseWmlConfig(self,fileName):
        """
        Read WML file and return a bunch of dictionaries.
        """
        
        #The section below parses an existing WML file and then populates the data structures
        tree = ET.parse(fileName)
        
        # if you need the root element, use getroot
        root = tree.getroot()

        self._loadTestName(root)
            
        versionElement = root.find('Version')
        fileVersion = str( versionElement.text )

        self._parseVersionElement(versionElement)

        chassisConfigElement = root.find('ChassisConfig')
        waveChassisStore = self._getWaveChassisStore(chassisConfigElement,
                                                     fileVersion)
        
        blogConfig = root.find('BlogConfig')
        waveBlogStore = self._getWaveBlogStore(blogConfig)
        
        portPropertiesConfig = root.find('PortPropertiesConfig')
        wavePortStore = self._getWavePortStore(portPropertiesConfig)
        
        clientProfileConfig = root.find('ClientProfileConfig')
        waveClientTableStore = self._getClientTableStore(clientProfileConfig)
        waveSecurityStore = self._getClientSecurityStore(clientProfileConfig)
        
        
        testConfigElement = root.find('TestConfig')
        trafficsElement = root.find('Traffics')
        waveTestStore = self._getWaveTestStore(testConfigElement, trafficsElement)
        
        testSpecificConfigElement = testConfigElement.find("Test")
        waveTestSpecificStore = self._getWaveTestSpecificStore(testSpecificConfigElement)
    
        mappingConfig = root.find('MapConfig')
        waveMappingStore = self._getWaveMappingStore(mappingConfig)
         
        ( waveChassisStore,
          wavePortStore,
          waveClientTableStore,
          waveSecurityStore,
          waveTestStore,
          waveTestSpecificStore,
          waveMappingStore,
          waveBlogStore ) = self._doNormalizations(root,
                                                   waveChassisStore,
                                                   wavePortStore,
                                                   waveClientTableStore,
                                                   waveSecurityStore,
                                                   waveTestStore,
                                                   waveTestSpecificStore,
                                                   waveMappingStore,
                                                   waveBlogStore)           
    
                                   
        return ( waveChassisStore,
                 wavePortStore,
                 waveClientTableStore,
                 waveSecurityStore,
                 waveTestStore,
                 waveTestSpecificStore,
                 waveMappingStore,
                 waveBlogStore )
                        
    def convertToWmlConfig( self,
                            fileName,
                            waveChassisStore,
                            wavePortStore,
                            waveClientTableStore,
                            waveSecurityStore,
                            waveTestStore,
                            waveTestSpecificStore,
                            waveMappingStore,
                            waveBlogStore ):
        """
        Build XML structure from dictionaries and save file.
        """
        
        # building a WML tree structure
        root = ET.Element("ConfigurationFile")
        
        # version number of WML file format
        version = ET.SubElement(root,"Version")
        version.text = self.CURRENT_VERSION
        
        #Converting the data in waveChassisStore to WML format
        self._constructChassisConfigSection(waveChassisStore, root)  
               
        #Converting the data in waveBlogStore to WML format 
        self._constructBlogStoreSection(waveBlogStore, root)
                
        #Converting the data in wavePortStore to WML format
        self._constructPortConfigSection(wavePortStore, root)
                
        #Converting the data in waveClientTableStore to WML format
        self._constructClientProfileConfigSection(waveClientTableStore, 
                                                  waveSecurityStore, root)
            
        self._consturctTrafficsSection(waveTestStore, root)
        
        #Converting the data in waveTestStore to WML format
        self._constructTestConfigSection(waveTestStore, 
                                         waveTestSpecificStore,
                                         root)  
        
        #Converting the data in waveMappingStore to WML format
        self._constructMapConfig(waveMappingStore, root)
                      
        # wrap it in an ElementTree instance, and save as XML
        self._indent(root)
        tree = ET.ElementTree(root)
        tree.write(fileName)
        #Return success or failure
        return

    # This method is used to provide indentation of the tree before
    # writing it out. Unfortunately, the wmlParser is not using a 
    # normalized xml form and thus this doesn't work very well. Still,
    # it's better than the compact form, so we'll make do with it.
    def _indent(self, elem, level=0):
        i = "\n" + level*"  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            for elem in elem:
                self._indent(elem, level+1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i
    
    def _constructChassisConfigSection(self, waveChassisStore, root):
        parentChassis = ET.SubElement(root,"ChassisConfig")
        chassisList = waveChassisStore.keys()
        for chassisName in chassisList:
            chName = ET.SubElement(parentChassis, "ChassisName")
            chName.text = str(chassisName)
            
            cardsList = waveChassisStore[chassisName].keys()
            for cardName in cardsList:
                Card = ET.SubElement(chName, "Card")
                Card.text = str(cardName)
                
                portList = waveChassisStore[chassisName][cardName].keys()
                for portName in portList:
                    port = ET.SubElement(Card, "Port")
                    port.text = portName
                    
                    for eachwaveChassisStoreElement in portSetupModel.waveChassisStoreElementsList:
                        chassisElement = str(eachwaveChassisStoreElement)
                        eachwaveChassisStoreElement = ET.SubElement(port,str(eachwaveChassisStoreElement))
                        eachwaveChassisStoreElement.text = str(waveChassisStore[chassisName][cardName][portName][chassisElement])
                        if (eachwaveChassisStoreElement.text == "8023"):
                            for eachwaveChassisStoreEthernetElement in self.waveChassisStoreEthernetElementsList:
                                ethernetElement = str(eachwaveChassisStoreEthernetElement)
                                eachwaveChassisStoreEthernetElement = ET.SubElement(port, eachwaveChassisStoreEthernetElement)
                                eachwaveChassisStoreEthernetElement.text = str(waveChassisStore[chassisName][cardName][portName][ethernetElement])

    def _constructBlogStoreSection(self, waveBlogStore, root):
        blogConfig = ET.SubElement(root,"BlogConfig")
        listOfPortNames = waveBlogStore.keys()                
        for portName in listOfPortNames: 
            portProp = ET.SubElement(blogConfig,"PortName")
            portProp.text = str(portName)   
            for eachWaveBlogStoreElement in self.waveBlogStoreElementsList:
                waveBlogStoreElement = str(eachWaveBlogStoreElement)
                eachWaveBlogStoreElement = ET.SubElement(portProp, eachWaveBlogStoreElement)
                if waveBlogStoreElement == 'BlogMode':
                    eachWaveBlogStoreElement.text = str(waveBlogStore[portName][waveBlogStoreElement])
                if waveBlogStoreElement == 'BlogBinSetUpConfig':
                    binNamesList = waveBlogStore[portName][waveBlogStoreElement].keys()
                    binNamesList.sort()                    
                    for eachBinName in binNamesList:
                        binConfig = ET.SubElement(eachWaveBlogStoreElement,eachBinName)                    
                        for eachBlogBinSetupConfigElement in self.blogBinSetupConfigList:
                            blogConfigElement = ET.SubElement(binConfig, eachBlogBinSetupConfigElement)
                            blogConfigElement.text = str(waveBlogStore[portName][waveBlogStoreElement][eachBinName][eachBlogBinSetupConfigElement])

    def _constructPortConfigSection(self, wavePortStore, root):
        portConfig = ET.SubElement(root,"PortPropertiesConfig")
        portsList = wavePortStore.keys()
        for portName in portsList: 
            portProp = ET.SubElement(portConfig,"PortName")
            portProp.text = str(portName)
            bssidSsidList = wavePortStore[portName].items()
            for eachBssidSsidPair in  bssidSsidList:
                bssid = eachBssidSsidPair[0]
                ssid = eachBssidSsidPair[1]
                bssidSsidPair = ET.SubElement(portProp,"BssidSsidPair")
                bssidTag = ET.SubElement(bssidSsidPair,"Bssid")
                bssidTag.text = str(bssid)
                ssidTag = ET.SubElement(bssidSsidPair,"Ssid")
                ssidTag.text = str(ssid)
    
    def _constructClientProfileConfigSection(self, waveClientTableStore,
                                            waveSecurityStore, root):
        clientProfile = ET.SubElement(root,"ClientProfileConfig")
        clientGroupsList = waveClientTableStore.keys()
        for eachClientGroupName in clientGroupsList:
            clientGroupName = ET.SubElement(clientProfile, "ClientGroupName")
            for eachwaveClientTableElement in self.waveClientTableElementsList:
                clientTableElement = str(eachwaveClientTableElement)
                eachwaveClientTableElement = ET.SubElement(clientGroupName, eachwaveClientTableElement)
                eachwaveClientTableElement.text =  str(waveClientTableStore[eachClientGroupName][clientTableElement])
            ipv4 = ET.SubElement(clientGroupName, "Ipv4")
            for eachipv4Element in self.waveClientTableIpv4List:
                ipv4Element = str(eachipv4Element)
                eachipv4Element = ET.SubElement(ipv4, eachipv4Element)
                eachipv4Element.text = str(waveClientTableStore[eachClientGroupName][ipv4Element])
                
            mac = ET.SubElement(clientGroupName, "Mac")
            for eachmacElement in self.waveClientTableMacList:
                macElement = str(eachmacElement)
                eachmacElement = ET.SubElement(mac, eachmacElement)
                eachmacElement.text = str(waveClientTableStore[eachClientGroupName][macElement])
            
            clientOptions = ET.SubElement(clientGroupName, "Performance")
            for eachwaveClientTableOptionsElement in self.waveClientTableOptionsList:
                clientTableOptionsElement = str(eachwaveClientTableOptionsElement)
                subElement = ET.SubElement(clientOptions, eachwaveClientTableOptionsElement)
                if isinstance(waveClientTableStore[eachClientGroupName][clientTableOptionsElement], dict):
                    self._generateTags(subElement, 
                                      waveClientTableStore[eachClientGroupName][clientTableOptionsElement])
                else:
                    subElement.text = str(waveClientTableStore[eachClientGroupName][clientTableOptionsElement])
                
             
            security = ET.SubElement(clientGroupName, "Security")
            for eachSecurityOption in self.waveSecurityList:
                securityItem = str(eachSecurityOption)
                if (waveSecurityStore[eachClientGroupName].has_key(securityItem)):
                    eachSecurityItem = ET.SubElement(security, eachSecurityOption)
                    eachSecurityItem.text = waveSecurityStore[eachClientGroupName][securityItem]
    
    def _consturctTrafficsSection(self, waveTestStore, root):
        traffics = ET.SubElement(root,"Traffics")
        testConfigKeysList = waveTestStore.keys()
        for eachKey in testConfigKeysList:
            if eachKey == "Traffics":
                for eachTrafficParm in GTSM.waveTestTrafficList:
                    trafficElement = ET.SubElement(traffics, str(eachTrafficParm))
                    trafficElement.text = waveTestStore[eachKey][str(eachTrafficParm)]
                    if (trafficElement.text == "Udp"):
                        udpElement = ET.SubElement(traffics,"Udp")
                        for eachUdpParm in GTSM.waveTestUdpList:
                            udpInfo = ET.SubElement(udpElement, str(eachUdpParm))
                            udpInfo.text = waveTestStore[eachKey][str(eachUdpParm)]
                    if (trafficElement.text == "Icmp"):
                        icmpElement = ET.SubElement(traffics,"Icmp")
                        for eachIcmpParm in GTSM.waveTestIcmpList:
                            icmpInfo = ET.SubElement(icmpElement, str(eachIcmpParm))
                            icmpInfo.text = waveTestStore[eachKey][str(eachIcmpParm)]
                    if (trafficElement.text == "Tcp"):
                        tcpElement = ET.SubElement(traffics,"Tcp")
                        for eachTcpParm in GTSM.waveTestTcpList:
                            tcpInfo = ET.SubElement(tcpElement, str(eachTcpParm))
                            tcpInfo.text = waveTestStore[eachKey][str(eachTcpParm)]
                        for eachTcpFlag in GTSM.waveTestTcpFlagsList:
                            tcpInfo = ET.SubElement(tcpElement, str(eachTcpFlag))
                            tcpInfo.text = waveTestStore[eachKey][str(eachTcpFlag)]
                    if (trafficElement.text == "Raw"):
                        rawElement = ET.SubElement(traffics,"Raw")
                        for eachRawParm in GTSM.waveTestRawList:
                            rawInfo = ET.SubElement(rawElement, str(eachRawParm))
                            rawInfo.text = waveTestStore[eachKey][str(eachRawParm)]

                payload = ET.SubElement(traffics, "Payload")
                for eachPayloadParm in GTSM.waveTestPayloadList:
                    payloadParm = ET.SubElement(payload, str(eachPayloadParm))
                    payloadParm.text = str(waveTestStore[eachKey][str(eachPayloadParm)])

    def _constructTestConfigSection(self, waveTestStore, 
                                    waveTestSpecificStore, root):
        testConfig = ET.SubElement(root,"TestConfig")
        if 'roaming_delay' in waveTestSpecificStore.keys():
            testConfig.text = "WLAN Roaming Test"
        elif 'roaming_benchmark' in waveTestSpecificStore.keys():
            testConfig.text = "Roaming Benchmark Test"
        elif 'roaming_stress' in waveTestSpecificStore.keys():
            testConfig.text = "Roaming Stress Test"
        elif 'voip_roam_quality' in waveTestSpecificStore.keys():
            testConfig.text = "VoIP Roam Quality Test"
        elif 'frame_generator' in waveTestSpecificStore.keys():
            testConfig.text = "Frame Generator"
        else:
            testConfig.text = "Benchmarking"
        
        self._constructGenericTestConfigSection(waveTestStore, testConfig)
                            
        for eachTest in waveTestSpecificStore.keys():
            if eachTest in ["unicast_unidirectional_throughput", 
                            "mesh_throughput_per_hop",
                            "mesh_throughput_aggregate"]:
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.tputList)):
                    if self.tputList[i] == 'MediumCapacity':
                        self._generateMedCapacityTags(testSpecificParm,
                                                      waveTestSpecificStore[eachTest])
                    else:
                        tputElement = ET.SubElement(testSpecificParm,str(self.tputList[i]))
                        tputElement.text = str(waveTestSpecificStore[eachTest][str(self.tputList[i])])
                              
            if eachTest == "unicast_packet_loss":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.packetLossList)):
                    if self.packetLossList[i] == 'MediumCapacity':
                        self._generateMedCapacityTags(testSpecificParm,
                                                      waveTestSpecificStore[eachTest])
                    else:
                        packetLossElement = ET.SubElement(testSpecificParm,str(self.packetLossList[i]))
                        packetLossElement.text = str(waveTestSpecificStore[eachTest][str(self.packetLossList[i])])
                        
                if waveTestSpecificStore[eachTest]["ILoadMode"] == "Increment":
                    for i in range(0,len(self.iLoadList)):
                        iLoadElement = ET.SubElement(testSpecificParm,str(self.iLoadList[i]))
                        iLoadElement.text = str(waveTestSpecificStore[eachTest][str(self.iLoadList[i])])
                        
            if eachTest in ["unicast_max_forwarding_rate", 
                            "mesh_max_forwarding_rate_per_hop"]:
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.maxfrList)):
                    if self.maxfrList[i] == 'MediumCapacity':
                        self._generateMedCapacityTags(testSpecificParm,
                                                      waveTestSpecificStore[eachTest])
                    else:
                        maxfrElement = ET.SubElement(testSpecificParm,str(self.maxfrList[i]))
                        maxfrElement.text = str(waveTestSpecificStore[eachTest][str(self.maxfrList[i])])

            if eachTest == "tcp_goodput":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.tcpGoodputList)):
                    if self.tcpGoodputList[i] == 'MediumCapacity':
                        self._generateMedCapacityTags(testSpecificParm,
                                                      waveTestSpecificStore[eachTest])
                    else:
                        tcpGoodputElement = ET.SubElement(testSpecificParm,str(self.tcpGoodputList[i]))
                        tcpGoodputElement.text = str(waveTestSpecificStore[eachTest][str(self.tcpGoodputList[i])])
                    
            if eachTest == "aaa_auth_rate" or eachTest == "aaa_auth_load":
                eachTest = "aaa_auth_rate" # VPR 5133
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.authRateList)):
                    authRateElement = ET.SubElement(testSpecificParm,str(self.authRateList[i]))
                    authRateElement.text = str(waveTestSpecificStore[eachTest][str(self.authRateList[i])])
            
            if eachTest == "frame_generator":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest  
                self._generateTags(testSpecificParm, waveTestSpecificStore[eachTest])
            
            if eachTest in ["unicast_latency",
                            "mesh_latency_per_hop",
                            "mesh_latency_aggregate"]:
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.latencyList)):
                    latencyElement = ET.SubElement(testSpecificParm,str(self.latencyList[i]))
                    latencyElement.text = str(waveTestSpecificStore[eachTest][str(self.latencyList[i])])
            
                if waveTestSpecificStore[eachTest]["ILoadMode"] == "Increment":
                    for i in range(0,len(self.iLoadList)):
                        iLoadElement = ET.SubElement(testSpecificParm,str(self.iLoadList[i]))
                        iLoadElement.text = str(waveTestSpecificStore[eachTest][str(self.iLoadList[i])])
                        
            if eachTest == "unicast_call_capacity":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.callCapacityList)):
                    callCapElement = ET.SubElement(testSpecificParm,str(self.callCapacityList[i]))
                    callCapElement.text = str(waveTestSpecificStore[eachTest][str(self.callCapacityList[i])])
            
#                 if waveTestSpecificStore[eachTest]["ILoadMode"] == "Increment":
#                     for i in range(0,len(self.iLoadList)):
#                         iLoadElement = ET.SubElement(testSpecificParm,str(self.iLoadList[i]))
#                         iLoadElement.text = str(waveTestSpecificStore[eachTest][str(self.iLoadList[i])])
                        
            if eachTest == "unicast_max_client_capacity":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.maxccList)):
                    maxccElement = ET.SubElement(testSpecificParm,str(self.maxccList[i]))
                    maxccElement.text = str(waveTestSpecificStore[eachTest][str(self.maxccList[i])])
                    
            if eachTest == "rate_vs_range":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testSpecificParm.text = eachTest
                for i in range(0,len(self.rateVsRangeList)):
                    rateVsRangeElement = ET.SubElement(testSpecificParm,str(self.rateVsRangeList[i]))
                    rateVsRangeElement.text = str(waveTestSpecificStore[eachTest][str(self.rateVsRangeList[i])])
                    
            if eachTest == "roaming_delay" :
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testName = ET.SubElement(testSpecificParm, "Name")
                testName.text = repr(eachTest)
                self._generateTags(testSpecificParm, waveTestSpecificStore[eachTest])
            
            if eachTest in ["voip_roam_quality", "roaming_benchmark"]:
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testName = ET.SubElement(testSpecificParm, "Name")
                testName.text = repr(eachTest)
                tmp = waveTestSpecificStore[eachTest].copy()
                tmp.__delitem__("roamTraffic")
                tmp.__delitem__("roamRate")
                self._generateTags(testSpecificParm, tmp)
                RoamRate = ET.SubElement(testSpecificParm, "RoamRate")
                RoamRate.text = str(waveTestSpecificStore[eachTest]["roamRate"])
                
                roamTrafficMap = waveTestSpecificStore[eachTest]["roamTraffic"]
                RoamTraffic = ET.SubElement(testSpecificParm, "RoamTraffic")
                RoamTrafficMappings = ET.SubElement(RoamTraffic, "Mappings")
                for i in range(0, len(roamTrafficMap)):
                    mapping = ET.SubElement(RoamTrafficMappings, "Mapping")
                    sourceClient = ET.SubElement(mapping, "SourceClient")
                    sourceClient.text = str(roamTrafficMap[i][0])
                    destClient = ET.SubElement(mapping, "DestClient")
                    destClient.text = str(roamTrafficMap[i][1])
            
            if eachTest == "roaming_stress":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testName = ET.SubElement(testSpecificParm, "Name")
                testName.text = repr(eachTest)
                tmp = waveTestSpecificStore[eachTest].copy()
                tmp.__delitem__("backgroundTraffic")
                tmp.__delitem__("roamTraffic")
                tmp.__delitem__("roamRate")
                self._generateTags(testSpecificParm, tmp)
                RoamRate = ET.SubElement(testSpecificParm, "RoamRate")
                RoamRate.text = str(waveTestSpecificStore[eachTest]["roamRate"])
                backgroundTrafficMap = waveTestSpecificStore[eachTest]["backgroundTraffic"]
                BgTraffic = ET.SubElement(testSpecificParm, "BgTraffic")
                BgTrafficMappings = ET.SubElement(BgTraffic, "Mappings")
                for i in range(0, len(backgroundTrafficMap[0])):
                    mapping = ET.SubElement(BgTrafficMappings, "Mapping")
                    sourceClient = ET.SubElement(mapping, "SourceClient")
                    sourceClient.text = str(backgroundTrafficMap[0][i][0])
                    destClient = ET.SubElement(mapping, "DestClient")
                    destClient.text = str(backgroundTrafficMap[0][i][1])
                    trafficDirection = ET.SubElement(mapping, "TrafficType")
                    trafficDirection.text = str(backgroundTrafficMap[0][i][2])
                    trafficType = ET.SubElement(mapping, "TrafficDirection")
                    trafficType.text = str(backgroundTrafficMap[0][i][3])
    
                otherStateInfo = ET.SubElement(BgTraffic, "OtherStateInfo")
                traffDirectionCheckbox = ET.SubElement(otherStateInfo, "TraffDirectionCheckbox")
                traffDirectionCheckbox.text = str(backgroundTrafficMap[1][0])
                traffTypeComboBox = ET.SubElement(otherStateInfo, "TraffTypeComboBox")
                traffTypeComboBox.text = str(backgroundTrafficMap[1][1])
                
                roamTrafficMap = waveTestSpecificStore[eachTest]["roamTraffic"]
                RoamTraffic = ET.SubElement(testSpecificParm, "RoamTraffic")
                RoamTrafficMappings = ET.SubElement(RoamTraffic, "Mappings")
                for i in range(0, len(roamTrafficMap)):
                    mapping = ET.SubElement(RoamTrafficMappings, "Mapping")
                    sourceClient = ET.SubElement(mapping, "SourceClient")
                    sourceClient.text = str(roamTrafficMap[i][0])
                    destClient = ET.SubElement(mapping, "DestClient")
                    destClient.text = str(roamTrafficMap[i][1])
            if eachTest == "qos_capacity":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testName = ET.SubElement(testSpecificParm, "Name")
                testName.text = repr(eachTest)
                self._generateTags(testSpecificParm, waveTestSpecificStore[eachTest])

            if eachTest == "qos_service":
                testSpecificParm = ET.SubElement(testConfig,"Test")
                testName = ET.SubElement(testSpecificParm, "Name")
                testName.text = repr(eachTest)
                self._generateTags(testSpecificParm, waveTestSpecificStore[eachTest])

            if eachTest not in [ "roaming_delay",
                                 "unicast_call_capacity",
                                 "qos_capacity",
                                 "qos_service",
                                 "roaming_benchmark",
                                 "voip_roam_quality",
                                 "roaming_stress" ,
                                 "aaa_auth_rate",
                                 "frame_generator",
                                 "rate_vs_range"]:
                if waveTestSpecificStore[eachTest]["Frame"] == "Standard":
                    for i in range(0,len(self.frameTypeList)):
                        frameTypeElement = ET.SubElement(testSpecificParm,str(self.frameTypeList[i]))
                        frameTypeElement.text = str(waveTestSpecificStore[eachTest][str(self.frameTypeList[i])])
                            
                if waveTestSpecificStore[eachTest]["Frame"] == "Increment":
                    for i in range(0,len(self.incrFrameList)):
                        incrElement = ET.SubElement(testSpecificParm,str(self.incrFrameList[i]))
                        incrElement.text = str(waveTestSpecificStore[eachTest][str(self.incrFrameList[i])])

    def _generateMedCapacityTags(self, testSpecificParm,
                                 testStore):
        medCapacityElement = ET.SubElement(testSpecificParm, 'MediumCapacity')
        data = testStore['MediumCapacity']
        #XML tags can not start with numbers, change 
        self._generateTags(medCapacityElement, data)     
                  
    def _constructMapConfig(self, waveMappingStore, root):
        mapConfig = ET.SubElement(root,"MapConfig")

        srcDestPairInfo = ET.SubElement(mapConfig,"SourceDestinationInfo")
        if (len(waveMappingStore) == 0):
            return
        else:
            mappingOptionsTag = ET.SubElement(srcDestPairInfo,"MappingOptions")
            mappingOptionsTag.text = str(waveMappingStore[0])
            
            srcTag = ET.SubElement(srcDestPairInfo,"Source")
            srcTag.text = str(waveMappingStore[1])
            
            destTag = ET.SubElement(srcDestPairInfo,"Destination")
            destTag.text = str(waveMappingStore[2]) 
                
            mappingType = ET.SubElement(srcDestPairInfo,"MappingType")
            mappingType.text = waveMappingStore[3]
                
            flowDirection = ET.SubElement(srcDestPairInfo,"FlowDirection")
            flowDirection.text = waveMappingStore[4]
        
            flowOptions = ET.SubElement(srcDestPairInfo,"FlowOptions")
            
            flowOptionsDict = waveMappingStore[5]
            
            connectMode = ET.SubElement(srcDestPairInfo,"ConnectMode")
            connectMode.text = waveMappingStore[6]
            
            flowPhyRate = ET.SubElement(flowOptions,"PhyRate")
            flowPhyRate.text = flowOptionsDict['PhyRate']
            
            flowType = ET.SubElement(flowOptions,"Type")
            flowType.text = flowOptionsDict['Type']
            
            if (flowType.text == "UDP"):
                for eachParm in GTSM.waveTestUdpList:
                    x = ET.SubElement(flowOptions,eachParm)
                    x.text = flowOptionsDict[eachParm]

    
    def _constructGenericTestConfigSection(self, waveTestStore, testConfig):
        testConfigKeysList = waveTestStore.keys()
        for eachKey in testConfigKeysList:
            if eachKey == "TestParameters":
                testParm = ET.SubElement(testConfig, "TestParameters")
                for eachTestParm in GTSM.waveTestParametersList:
                    testParmElement = ET.SubElement(testParm, str(eachTestParm))
                    testParmElement.text = str(waveTestStore[eachKey][str(eachTestParm)])

            if eachKey == "Learning":
                learningKeysList = waveTestStore[eachKey].keys()
                learningKey = ET.SubElement(testConfig, "Learning")
                for eachLearningParm in GTSM.waveTestLearningList:
                    testElement = ET.SubElement(learningKey,str(eachLearningParm))
                    testElement.text = str(waveTestStore[eachKey][str(eachLearningParm)])
             
            if eachKey == "Connection":
                connKeysList = waveTestStore[eachKey].keys()
                connKey = ET.SubElement(testConfig, "Connection")
                for eachConnParm in GTSM.waveTestConnectionList:
                    connElement = ET.SubElement(connKey,str(eachConnParm))
                    connElement.text = str(waveTestStore[eachKey][str(eachConnParm)])                
                            
            if eachKey == "DutInfo":
                dutInfoKeysList = waveTestStore[eachKey].keys()
                dutInfoKey = ET.SubElement(testConfig, "DutInfo")
                for eachDutInfoParm in GTSM.waveTestDutInfoList:
                    dutInfoElement = ET.SubElement(dutInfoKey,str(eachDutInfoParm))
                    dutInfoElement.text = str(waveTestStore[eachKey][str(eachDutInfoParm)])
        
            if eachKey == "LogsAndResultsInfo":
                logsAndResultsKeysList = waveTestStore[eachKey].keys()
                logsAndResultsKey = ET.SubElement(testConfig, "LogsAndResultsInfo")
                for eachLogsAndResultsParm in GTSM.waveLogsAndResultsInfoList:
                    logsAndResultsInfoElement = ET.SubElement(logsAndResultsKey,str(eachLogsAndResultsParm))
                    logsAndResultsInfoElement.text = str(waveTestStore[eachKey][str(eachLogsAndResultsParm)])
