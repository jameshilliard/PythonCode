import copy
import odict
import WaveEngine as WE
import time
import socket
__metaclass__ = type

    
waveChassisStoreElementsList = ['CardID',
                                'CardModel',
                                'PowerCapability',
                                'PortID',
                                'BindStatus',
                                'PortName',
                                'PortType',
                                'Band',
                                'Channel',
                                'SecondaryChannelPlacement',
                                'EnableRxAttenuation',
                                'hiddenSSIDs',
                                'CardMode'
                                ]

validPowerCapabilities = ['Low', 'Low 11n', 'High']

class ChassisCouldNotBeLocatedError(Exception): 
    def __init__(self, errorMsg):
        Exception.__init__(self, errorMsg)

class PortWriteError(Exception): pass

class PortResetError(Exception): pass

class PortBindError(Exception): pass

class PortBindConflictError(PortBindError): pass

class PortReleaseError(Exception): pass

class PortDestroyError(Exception): pass

class ChannelScanAbortException(Exception):pass

class FoundAnAccessPoint(Exception): pass

VCL_DELAY = 0.1
SCAN_DELAY = 0.2

class Chassis(object):

    def __init__(self, chassisName, chassisInfo = None):
        self.__name = chassisName
        self.__chassisModel = ''
        self.__cards = {}
        if not chassisInfo:
            pass
        else:
            self._setChassisInfo(chassisInfo)
        
        self.__connected = False
        
    def _name(self):
        return self.__name
    name = property(fget = _name)
    
    def _getModel(self):
        return self.__chassisModel
    model = property(fget = _getModel)
    
    def _cards(self):
        return self.__cards
    cards = property(fget = _cards)
    
    def _getChassisInfo(self):
        chassisInfo = {}
        for cardName in self.__cards:
            chassisInfo[cardName] = self.__cards[cardName].cardInfo
        return chassisInfo
    def _setChassisInfo(self, chassisInfo):
        if not chassisInfo:
            return
        
        for cardName in chassisInfo:
            if cardName in self.__cards:
                self.__cards[cardName].cardInfo = chassisInfo[cardName]
            else:
                cardID = self._getCardID(chassisInfo[cardName])
                if cardID:
                    self.__cards[cardName] = ChassisCard(self.__name, 
                                                        cardName,
                                                        cardID,
                                                        chassisInfo[cardName])
    chassisInfo = property(fget = _getChassisInfo,
                           fset = _setChassisInfo)
    
    
    def _getCardID(self, cardInfo):
        """
        For now, the dict chassisInfo[cardName] wouldn't have 'CardID'. 
        Extract it from the ports information of the card. When changes are
        made to the chassis store data strcuture, get rid of this method.
        """
        portsInCard = cardInfo.keys()
        if portsInCard:
            somePort = portsInCard[0]
            return cardInfo[somePort]['CardID']
        else:
            print 'CardID not found in the port config, Invalid Port Info!'
            
    def _getChassisIPaddress(self, chassisname):
        try:
            # convert hostname to hostip
            ipaddr = socket.gethostbyname( chassisname )
        except Exception, e:
            try:
                ( msgerr, msginfo ) = e
            except:
                msginfo = str(e)
            #Convert the error into more user friendly
            if msginfo == "getaddrinfo failed":
                msginfo = 'Host IP could not be found'    
            raise ChassisCouldNotBeLocatedError(msginfo)
        
    def _reportVersionMisMatchIfAny(self, chassisName, cardID):
        """
        This is called in a context where card read is performed. So, no need
        of performing another card read  
        """
        hostVersion = str( WE.VCLtest("action.getVclVersionStr()") )
        cardVersion = str( WE.VCLtest("card.getVersion()") )
        msg = ''
        if hostVersion != cardVersion:
            # per VPR 3083, print only a warning message for mis-matched versions
            msg = "Warning: Firmware version %s on Chassis %s, Card %s, does not match WaveTest version %s.\n" % \
                    ( cardVersion, chassisName, cardID, hostVersion )
        return msg
    
    def isConnected(self):
        return self.__connected
    
    def portBelongsHere(self, portName):
        for cardName in self.__cards:
            if self.__cards[cardName].portBelongsHere(portName):
                return True
        return False

    def getPortParents(self, portName):
        cardName = self._getCardNameOfPort(portName)
        if cardName:
            return (self.__name, cardName)
        else:
            return None
    
    def storeAccessPointsInfoOfPort(self, portName, portInfo):
        cardName = self._getCardNameOfPort(portName)
        if cardName:
            self.__cards[cardName].storeAccessPointsInfoOfPort(portName, portInfo)
            
    def _getAccessPointsInfo(self):
        accessPointsInfo = {}
        for cardName in self.__cards:
            accessPointsInfo.update(self.__cards[cardName].accessPointsInfo)
        return accessPointsInfo
    accessPointsInfo = property(fget = _getAccessPointsInfo)
    
    
    def storeBlogInfoOfPort(self, portName, blogInfo):
        cardName = self._getCardNameOfPort(portName)
        self.__cards[cardName].storeBlogInfo(portName, blogInfo)
    
    def _getBlogStoreInfo(self):
        blogStoreInfo = {}
        for cardName in self.__cards: 
            blogStoreInfo.update(self.__cards[cardName].blogStoreInfo)
        return blogStoreInfo
    blogStoreInfo = property(fget = _getBlogStoreInfo)
    
    def _getCardNameOfPort(self, portName):
        for cardName in self.__cards:
            if self.__cards[cardName].portBelongsHere(portName):
                return self.__cards[cardName].name
        return None
    
    def _getCardNameByID(self, cardID):
        """
        Legacy cards have 'Card %d' format Vs the new 'card%d' format.
        VPR 6480
        """
        legacyCardName = 'Card %d'%cardID
        if legacyCardName in self.__cards:
            return legacyCardName 
        else:
            return 'card%d'%cardID
        
    def _connect(self):
        chassisName = self.__name
        
        self._getChassisIPaddress(chassisName)

        retVal = WE.VCLtest("chassis.connect('%s')"%chassisName)
        if (retVal <> 0):
            raise WE.ChassisConnectError(retVal)
        else:
            self.__connected = True
    
    def _disconnect(self):
        chassisName = self.__name
        retVal = WE.VCLtest("chassis.disconnect('%s')"%chassisName)
        if (retVal <> 0):
            raise WE.ChassisDisconnectError(retVal)
        else:
            self.__connected = False
        
    def connect(self):
        self._connect() 
        chassisName = self.__name
        messages = []
        if WE.VCLtest("chassis.read('%s')"%(chassisName)) != 0:
            raise WE.ChassisReadError(chassisName)
        
        self.__chassisModel = WE.VCLtest("chassis.getModelName()")
        for cardID in WE.VCLtest("chassis.cardInfo"):
            cardName = self._getCardNameByID(cardID)
            if cardName in self.__cards:
                self.__cards[cardName].reconnect()
            else:
                self.__cards[cardName] = ChassisCard(self.__name,
                                                    cardName, cardID)
                self.__cards[cardName].connect()
            msg = self._reportVersionMisMatchIfAny(chassisName, cardID)
            if msg:
                messages.append(msg)
        return messages
    
    def disconnect(self):
        self._disconnect()
    
    def reconnect(self):
        cardsBeforeReconnect = self._getCards()
        messages = self.connect()
        cardsAfterReconnect = self._getCards()
        if cardsBeforeReconnect != cardsAfterReconnect:
            #Perform action 
            pass
        return messages
    
    def _getCards(self):
        return self.__cards.keys()
    
class ChassisCard(object):
    def __init__(self, chassisName, cardName, cardID, cardInfo = None):
        self.__chassisName = chassisName
        self.__name = cardName
        self.__cardID = cardID
        self.__ports = odict.OrderedDict()

        self._setCardInfo(cardInfo)
        
        self.__cardModel = ''
    def _chassisName(self):
        return self.__chassisName
    chassisName = property(fget = _chassisName)
    
    def _name(self):
        return self.__name
    name = property(fget = _name)
    
    def _getCardInfo(self):
        cardInfo = odict.OrderedDict()
        for portName in self.__ports:
            portName = self.__ports[portName].name
            portInfo = self.__ports[portName].portInfo
            
            cardInfo[portName] = portInfo
        return cardInfo
    def _setCardInfo(self, cardInfo):
        if not cardInfo:
            return
        portNames = self._getPortNames()
        for port in cardInfo:
            if port in portNames:
                self.__ports[port].portInfo = cardInfo[port]
            else:
                
                self.__ports[port] = ChassisCardPort(self.__chassisName,
                                                     self.__name,
                                                     port, 
                                                     cardInfo[port]['CardID'],
                                                     cardInfo[port]['CardModel'],
                                                     cardInfo[port]['PortID'],
                                                     portInfo = cardInfo[port])
    cardInfo = property(fget = _getCardInfo,
                        fset = _setCardInfo)
    
    def _getPorts(self):
        return self.__ports
    ports = property(fget = _getPorts)
    
    def storeAccessPointsInfoOfPort(self, portName, apInfo):
        if portName not in self.__ports:
            print 'Port information set for invalid port '
            return
        self.__ports[portName].accessPointsInfo = apInfo

    def _getAccessPointsInfo(self):
        apInfo = {}
        for portName in self.__ports:
            portName = self.__ports[portName].name
            portAPinfo = self.__ports[portName].accessPointsInfo
            if portAPinfo:
                apInfo[portName] = portAPinfo
        return  apInfo
    accessPointsInfo = property(fget = _getAccessPointsInfo)
    
    
    def storeBlogInfo(self, portName, blogInfo):
        self.__ports[portName].blogStore = blogInfo
    
    def _getBlogStoreInfo(self):
        blogStoreInfo = {}
        for portName in self.__ports:
            blogStoreInfo[portName] = self.__ports[portName].blogStore
        return blogStoreInfo
    blogStoreInfo = property(fget = _getBlogStoreInfo)
    
    def portBelongsHere(self, portName):
        portNames = self._getPortNames()
        
        return (portName in portNames)

    def _portList(self):
        return self.__ports
    portList = property(fget = _portList)
    
    def _getPortNames(self):
        portNames = []
        for portName in self.__ports:
            portNames.append(self.__ports[portName].name)
        return portNames

    def _getPortNameByID(self, portID):
        """
        Legacy naming scheme of ports requires us to check the port identity 
        not by name. VPR 6480
        """
        for portName in self.__ports:
            thisPortID = self.__ports[portName]._getPortID()
            if str(portID) == str(thisPortID):
                return portName
        #None found. Create the name.
        return self.__chassisName + '_%s_port%d'%(self.__name, portID)
    
    def connect(self):
        if (WE.VCLtest("card.read('%s', %s)"%(self.__chassisName, 
                                               self.__cardID)) != 0):
            raise WE.CardReadError(chassisName, self.__cardID)
        self.__cardModel = WE.VCLtest("card.getModelName()")
        for portID in reversed(WE.VCLtest("card.portInfo") ):
            portName = self._getPortNameByID(portID)
            if portName not in self.__ports:
                self.__ports[portName] = ChassisCardPort(self.__chassisName,
                                                         self.__name,
                                                         portName,
                                                         self.__cardID,
                                                         self.__cardModel,
                                                         portID)
                self.__ports[portName].connect()
            else:
                self.__ports[portName].reconnect()
    
    def reconnect(self):
        portsBeforeReconnect = self._getPorts()
        self.connect()
        portsAfterReconnect = self._getPorts()
        if portsBeforeReconnect != portsAfterReconnect:
            #Perform action
            pass
    
    def _getPorts(self):
        return self.__ports.keys()
    
class ChassisCardPort(object):
    portMaxPowerPowerToCapabilityMap = {-6: 'Low',
                                         0:'Low 11n',
                                        15: 'High'
                                        } 
    bandMap = {
               2400: '2.4 GHz',
               4900: '4.9 GHz',
               5000: '5 GHz'
               }
    
    bandToChannelMap = {
                        2400: ['1', '2', '3', '4', '5', '6', '7', '8', '9', 
                               '10', '11', '12', '13', '14']
    ,
                        4900: ['1', '2', '3', '4', '5', '6', '7', '8', '9', 
                               '10', '11', '13', '15', '17', '19', '21', 
                               '25'],
                               
                        5000: ['36', '40', '44', '48', '52', '56', '60', 
                               '64', '100', '104', '108', '112', '116', 
                               '120', '124', '128', '132', '136', '140', 
                               '149', '153', '157', '161', '165'],
                               
                        'Unknown': []
                        }
    
    validChannelList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', 
                        '12', '13', '14', '15', '17', '19', '21', '25', '36', 
                        '40', '44', '48', '52', '56', '60', '64', '100', '104', 
                        '108', '112', '116', '120', '124', '128', '132', '136', 
                        '140','149', '153', '157', '161', '165']
    # IG Table columns
    BT_BINNAME_COLUMN = 0
    BT_BINLOW_COLUMN = 1
    BT_BINHIGH_COLUMN = 2
    BT_STRIKEPROBABILITY_COLUMN = 3
    BIN_NAME_LIST = ['Band_1','Band_2','Band_3','Band_4']
    DEFAULT_BIN_LOW_LIST = [40,615,1190,1765]
    DEFAULT_BIN_HIGH_LIST = [614,1189,1764,2340]
    DEFAULT_BIN_STRIKE = 25
    BLOG_START_PERCENT_DEFAULT = 0
    BLOG_STOP_PERCENT_DEFAULT = 100 

    def _getDefaultBlogStore():    
        BIN_NAME_LIST = ['Band_1','Band_2','Band_3','Band_4']
        DEFAULT_BIN_LOW_LIST = [40,615,1190,1765]
        DEFAULT_BIN_HIGH_LIST = [614,1189,1764,2340]
        DEFAULT_BIN_STRIKE = 25

        
        binDict = odict.OrderedDict()
        
        for i in range(len(BIN_NAME_LIST)):
            binName = BIN_NAME_LIST[i]
            binLow = DEFAULT_BIN_LOW_LIST[i]
            binHigh = DEFAULT_BIN_HIGH_LIST[i]
            binStrikeProbability = DEFAULT_BIN_STRIKE
            
            binDict[binName] = {'BinLow': binLow,
                                'BinHigh': binHigh, 
                                'BinStrikeProbability':binStrikeProbability
                                }

        defaultBlogState = 'False'
        defaultBlogStore = {'BlogBinSetUpConfig': binDict,
                            'BlogMode':defaultBlogState
                            }
        return defaultBlogStore
    
    DEFAULT_BLOGSTORE = _getDefaultBlogStore()
    
    @classmethod
    def getBandFromChannel(cls, channel):
        band = 'Unknown'
        for band in cls.bandToChannelMap:
            if str(channel) in cls.bandToChannelMap[band]:
                return band
        
        return band
        
    @staticmethod
    def getCardNum( portName ):
        """
        Extract integer card number from card string description
        FIXME -- should not do this
        """
        portPart = portName.split('_')[1]
    
        return int(portPart.lstrip('card'))
    @staticmethod
    def getPortNum( portName ):
        """
        Extract integer card number from card string description
        FIXME -- should not do this
        """
        portPart = portName.split('_')[2]
    
        return int(portPart.lstrip('port'))
    
    def __init__(self, chassisName, cardName, portName, cardID, 
                 cardModel, portID,portInfo = None):
        self.__chassisName = chassisName
        self.__cardName = cardName
        self.__cardID = cardID
        self.__cardModel = cardModel
        self.__portID = portID
        self.__name = portName
        self.__portInfo = {}
        
        if portInfo:
            self._setPortInfo(portInfo)
        
        self.__accessPointsInfo = odict.OrderedDict()
        self.__blogStore = copy.deepcopy(self.DEFAULT_BLOGSTORE)
        
    def _name(self):
        return self.__name
    name = property(fget = _name)
    
    def _getPortInfo(self):
        """
        Sample data:
        portInfo = {
                    'BindStatus': 'False', 
                    'PortID': 0, 
                    'hiddenSSIDs': [''], 
                    'CardMode': 'TGA', 
                    'Band': 2400, 
                    'CardID': 4, 
                    'PortName': 'wt-tga-14-61_card4_port0', 
                    'PortType': '80211', 
                    'Channel': 'Unknown',
                    'SecondaryChannelPlacement':'defer',
                    'EnableRxAttenuation': 'on',
                    'EthernetSpeed': '100',
                    'Duplex': 'full',
                    'Autonegotiation': 'on'
                    }
        """
        return self.__portInfo
    def _setPortInfo(self, portInfo):
        """
        set the defaults, update the attributes present in the portInfo. This 
        enables easy addition of new port attributes, as those new attributes 
        would have defaults
        """
        defaultPortInfo = {
                           'CardModel': 'Legacy',
                           'BindStatus': 'False',
                           'PortID': 0,
                           'hiddenSSIDs': [''],
                           'CardMode': 'TGA',
                           'Band': 2400,
                           'CardID': 4,
                           'Channel': 'Unknown',
                           'SecondaryChannelPlacement':'defer',
                           'EnableRxAttenuation': 'on',
                           'PortName':'',
                           'PortType':'', 
                           'EthernetSpeed': 'NA',
                           'Duplex': 'NA',
                           'Autonegotiation': 'NA' 
                           }
        defaultEthPortInfo = {'Band': 'NA',
                              'Channel': 'NA',
                              'EthernetSpeed': '100',
                              'Duplex': 'full',
                              'Autonegotiation': 'on'
                             }
        
        ethInfo = False
        portType = portInfo.get('PortType', None)
        if portType == WE.EthPortType:
            defaultPortInfo.update(defaultEthPortInfo)
            ethInfo = True
        self.__portInfo = defaultPortInfo
        
        normalizedPortInfo = self._normalizePortInfo(portInfo, ethInfo) 
        self._updatePortInfo(normalizedPortInfo )
             
    portInfo = property(fget = _getPortInfo,
                        fset = _setPortInfo)
    
            
    def _updatePortInfo(self, portInfo):
        """
        Update the given portInfo attributes. No normalization is required
        """
        self.__portInfo.update(portInfo)
        #PortID always must be in sync with portInfo['PortID'], it might not be
        #the case sometimes, see VPR 6480.
        if 'PortID' in portInfo:
            self.__portID = portInfo['PortID']
            
    def updatePortInfo(self, portInfo):
        normalizedPortInfo = self._normalizePortInfo(portInfo) 
        self.__portInfo.update(normalizedPortInfo)
        
    def _accessPointsInfo(self, band= None, channel = None):
        if not (band and channel):
            band = self.__portInfo['Band']
            channel = self.__portInfo['Channel']
        
        if (
            (not band in self.__accessPointsInfo) 
            or
            (not channel in self.__accessPointsInfo[band])
            ):
            return {}
            
        return self.__accessPointsInfo[band][channel]
    
    def _setAccessPointsInfo(self, apInfo, band = None, channel= None):
        if not (band and channel):
            band = self.__portInfo['Band']
            channel = self.__portInfo['Channel']
        if band != 'Unknown' and channel != 'Unknown': 
            self.__accessPointsInfo[band] = {}
            self.__accessPointsInfo[band][channel] = apInfo
        else:
            print 'AP information requested to be store when band or channel is "Unknown"'
    accessPointsInfo = property(fget= _accessPointsInfo, 
                               fset = _setAccessPointsInfo)
        
    def _getPortBlogStore(self):
        """
        {
         'BlogBinSetUpConfig': 
                             'Band1':
                                     'BinLow':
                                     'BinHigh':
                                     'BinStrikeProbability':
                             'Band2':
                                     'BinLow':
                                     'BinHigh':
                                     'BinStrikeProbability':
                             'Band3':
                                     'BinLow':
                                     'BinHigh':
                                     'BinStrikeProbability':
                             'Band4':
                                     'BinLow':
                                     'BinHigh':
                                     'BinStrikeProbability':
         'BlogMode':
        } 
        """
        return self.__blogStore
    def _setPortBlogStore(self, blogStore):
        self.__blogStore = blogStore
    blogStore = property(fget = _getPortBlogStore,
                         fset = _setPortBlogStore)
    
    def _getBlogBinSetUpConfig(self):
        return self.__blogStore['BlogBinSetUpConfig']
    def _setBlogBinSetUpConfig(self, blogBinConfig):
        self.__blogStore['BlogBinSetUpConfig'] = blogBinConfig
    blogBinConfig = property(fget = _getBlogBinSetUpConfig,
                             fset = _setBlogBinSetUpConfig)
    
    def _setBlogMode(self, blogMode):
        self.__blogStore['BlogMode'] = blogMode
        cardMode = {'True':'IG',
                    'False': 'TGA'}[blogMode]
        #Why should we maintain this info twice (as 'BlogMode' and also as 'CardMode'
        self.updatePortInfo({'CardMode':cardMode})
        
    def _getBlogMode(self):
        return self.__blogStore['BlogMode']
    blogMode = property(fget = _getBlogMode,
                         fset = _setBlogMode)
    
    def _normalizePortInfo(self, portInfo, ethInfo = False):
        normalizedPortInfo = portInfo
        
        if ethInfo:
            #For the sake of old wml files
            if 'Channel' in portInfo:
                normalizedPortInfo['Channel'] = 'NA'
            
            if 'Band' in portInfo:
                normalizedPortInfo['Band'] = 'NA'
        else:
                
            if 'Channel' in portInfo:
                normalizedPortInfo['Channel'] = self._getNormalizedChannel(portInfo['Channel'])
                
            if 'Band' in portInfo:
                normalizedPortInfo['Band'] = self._getNormalisedBand(portInfo['Band'])
            
            if 'hiddenSSIDs' in portInfo:
                if isinstance(portInfo['hiddenSSIDs'], str):
                    hiddenSSIDs = portInfo['hiddenSSIDs'].split(';')
                    normalizedPortInfo['hiddenSSIDs'] = hiddenSSIDs
            
        if 'PortID' in portInfo:
            """
            Port naming scheme has been changed from '0 to n-1'
            to '0 to n'. In case an old wml is being loaded, change the portID 0 to 1.
            Don't worry for values greater than 1 as we never earlier in the 
            field had a multi-port card.
            """
            if portInfo['PortID'] == '0':
                normalizedPortInfo['PortID'] = '1'
                    
        return normalizedPortInfo 
    
    def _setBandValue(self, band):
        bandInfo = {'Band': band}
        self._updatePortInfo(bandInfo)
        
    def _setChannelValue(self, channel):
        channelInfo = {'Channel': channel}
        self._updatePortInfo(channelInfo)
        
    def _getNormalizedChannel(self, channel):
        if channel is None:
            channel = 'Unknown'
        
        if str(channel) not in ['Unknown', 'N/A']+ self.validChannelList: 
            print 'Invalid Channel value set. Setting it to Unknown'
            channel = 'Unknown'
        
        return channel
    
    def _getNormalisedBand(self, band, channel = None):
        if band == 'Unknown':    #Maybe an old config file, see if channel is set
            return self._getBandFromChannel(channel)
        
        if band in [2400, '2400', 4900,'4900', 5000, '5000']:
            return int(band)
        elif band == 'N/A':
            return 'Unknown'
        elif isinstance(band, str):
            band = str(band).strip('GHz').strip()
            labelTobandMap = {
                       '2.4': 2400,
                       '4.9': 4900,
                       '5':   5000 
                       }
            
            return labelTobandMap[band]
        else:
            print 'Invalid Band Value'
            return 'Unknown'
        
    def _getBandFromChannel(self, portChannel):
        if not portChannel:
            portChannel = self.__portInfo.get('Channel', 'Unknown')

        if portChannel in ['Unknown', 'N/A']:
            return 'Unknown'
        else:    
            legacyChannelMap = {
                                2400: ['1', '2', '3', '4', '5', '6', '7', '8', 
                                       '9', '10', '11', '12', '13', '14'],
                                                                      
                                5000: ['36', '40', '44', '48', '52', '56', '60', 
                                       '64', '100', '104', '108', '112', '116', 
                                       '120', '124', '128', '132', '136', '140', 
                                        '149', '153', '157', '161', '165']
                                } 
            
            for band in legacyChannelMap:
                if portChannel in legacyChannelMap[band]:
                    return band
            #Should be an invalid channel, pass it through normalization
            #self.updatePortInfo({'Channel': portChannel})

            return 'Unknown' 
        
    def connect(self):
        """
        Complying with the existing waveapps architecture, we create
        temporary ports and delete them after getting the attributes of 
        the port. 
        create temp port, get attributes
        """
        WE.VCLtest( "port.alias( 'chassis-connect-temp-port', '%s', %d, %d )" % 
                                ( self.__chassisName, 
                                  int(self.__cardID), 
                                  int(self.__portID) ) )
        WE.VCLtest( "port.read( 'chassis-connect-temp-port' )" )
        self.__portMaxPower = WE.VCLtest("port.getRadioMaxPower()", 
                                         negativesAreOK = True)
        portInfo = {'CardModel': self.__cardModel,
                    'PowerCapability': self._getPowerCapability(),
                    'BindStatus': 'False',
                    'PortID': self._getPortID(),
                    'hiddenSSIDs': [''],
                    'CardMode': self._getOperationalMode(),
                    'CardID': self._getCardID(),
                    'PortName': self.__name,
                    'PortType': self._getPortType(),
                    'Band': 'Unknown',
                    'Channel': 'Unknown'
                    }
        self._setPortInfo(portInfo)
        WE.VCLtest( "port.unalias( 'chassis-connect-temp-port' )" )
    
    def isEnabled(self):
        return (self.__portInfo['BindStatus'] == 'True') 
    
    def setEnabled(self, state):
        state = str(state)
        if state not in ['True', 'False']:
            print 'Request to set invalid BindStatus'
        enabledProperty = {'BindStatus': state}
        self._updatePortInfo(enabledProperty)
    
    def reset(self):
        return WE.VCLtest("port.reset('%s')"%self.__name)
        
    def _bindPort(self):
        
        try:
            retVclCode = WE.VCLtest("port.bind('%s','%s',%d,%d)"%
                                     (self.__name, self.__chassisName,
                                      int(self.__cardID), int(self.__portID)),
                                      negativesAreOK = True)
        except:
            pass
        
        if retVclCode == -4 :
            raise PortBindConflictError
        elif retVclCode != 0 :
            raise PortBindError
        
        retVclCode = WE.VCLtest("port.reset('%s')"%self.__name)
        if (retVclCode != 0):
            raise PortResetError
        
        WE.VCLtest("port.read('%s')"%self.__name)
        
        if (self.__portInfo['PortType'] in WE.WiFiPortTypes):
            WE.VCLtest("port.setRadio('%s')"%'on') 
            
        retVclCode = WE.VCLtest("port.write('%s')"%self.__name)
        if (retVclCode != 0):
            raise PortWriteError
    
    def _unbindPort(self):
        """
        This method unbinds the port
        """

        retVclCode = WE.VCLtest("port.unbind('%s')"%self.__name)
        if retVclCode != 0:            
            raise PortReleaseError 
        
        retVclCode = WE.VCLtest("port.destroy('%s')"%self.__name)
        if (retVclCode != 0):                        
            raise PortDestroyError

    
    def _getCardID(self):
        return self.__cardID
    
    def _getPortID(self):
        #Temporary change, to work around vcl issue
        return self.__portID
        #return WE.VCLtest( "port.getOwnerId()")
        
    def _getPowerCapability(self):
        if self.__portMaxPower in self.portMaxPowerPowerToCapabilityMap:
            return self.portMaxPowerPowerToCapabilityMap[self.__portMaxPower]
        else:
            return 'Low' 
        
    def _getOperationalMode(self):
        return WE.VCLtest( "port.getOperationalMode()").upper()
    
    def _getPortType(self):
        return WE.VCLtest("port.getType()")
    
    def _setPortBand(self, band):
        """
        This method just sets the radio band, doesn't write it. This should be
        used in conjunction with writePortChannel, which does port.write()
        This setBand, setChannel then write sequence follows 1->N map between
        Band and Channels (we don't wanna write band for ever channel)
        """
        WE.VCLtest('port.setRadioBand(%d)'%int(band))
        time.sleep( VCL_DELAY )
    
    def _writePortChannel(self, channel):
        if self._validChannelForCardType(channel):
            WE.VCLtest( "port.setRadioChannel( %d )" % int(channel) )
            WE.VCLtest( "port.write( '%s' )" % (self.__name) )
            time.sleep( VCL_DELAY )
    
    def _validChannelForCardType(self, channel):
        portType = self._getPortType()
        channel = str(channel)
        #For now skip the 4900 band, as it isn't supported by the cards
        return ((channel in self.bandToChannelMap[2400]) 
                or
                +(channel in self.bandToChannelMap[5000])
                )
        
    def _readPortBSSIDs(self):
        WE.VCLtest( "port.scanBssid( '%s' )" % ( self.__name ) )
        time.sleep( VCL_DELAY * 3 )
        WE.VCLtest( "port.read( '%s' )" % ( self.__name ) )
        #VPR 4379
        WE.VCLtest( "port.write('%s')",( self.__name ) )
        
        return WE.VCLtest("port.bssidList")

    def reconnect(self):
        stateToBeSaved = self._getStateToBeSaved()
        
        self.connect()

        self._updatePortInfo(stateToBeSaved)
                
    def _getStateToBeSaved(self):
        portInfo = self._getPortInfo()
        bindStatus = portInfo['BindStatus']
        hiddenSSIDs = portInfo['hiddenSSIDs']
        band = portInfo['Band']
        channel = portInfo['Channel']
        
        stateToBeSaved = {'BindStatus': bindStatus,
                          'hiddenSSIDs':hiddenSSIDs,
                          'Band':band,
                          'Channel':channel
                          }
        return stateToBeSaved
    
    def performAutoScan(self, funcToReportChannelStatus, funcToReportAPinfo,
                        shouldAbortMission):
        portInfo = self._getPortInfo()
        if portInfo['BindStatus'] == 'True':
            
            self._bindPort()
            
            if portInfo['PortType'] in WE.WiFiPortTypes:
                self._reloadWifiInfo(portInfo, 
                                     funcToReportChannelStatus,
                                     funcToReportAPinfo,
                                     shouldAbortMission)
            elif portInfo['PortType'] == WE.EthPortType:
                #self._reloadEthInfo(portInfo)
                pass
            
            self._unbindPort()
            
    def _reloadWifiInfo(self, portInfo, 
                        funcToReportChannelStatus,
                        funcToReportAPinfo, 
                        shouldAbortMission):
        hiddenSSIDs = portInfo['hiddenSSIDs']
        allAPinfo = {} 
        channelInfo = self._getValidChannelInfo()
        try:
            for band in channelInfo:
                self._setPortBand(band)
                allAPinfo[band] = {}
                foundAPsAtThisBand = False
                for channel in channelInfo[band]:
                    if shouldAbortMission():
                        raise ChannelScanAbortException
                    channel = int(channel)
                    #Report band/channel to be scanned
                    funcToReportChannelStatus(band, channel)
                    
                    apInfoAtThisChannel = self._doChannelScan(band = 'PRESET',
                                                              channel = channel, 
                                                              hiddenSSIDs = hiddenSSIDs)
                    allAPinfo[band][channel] = apInfoAtThisChannel
                    if apInfoAtThisChannel:
                        foundAPsAtThisBand = True
                        self._setBandValue(band)
                        self._setChannelValue(channel)
                        
                        portType = self.__portInfo['PortType']
                        secondaryChannelPlacement = self.__portInfo['SecondaryChannelPlacement']
                        funcToReportAPinfo(band, 
                                           channel,
                                           apInfoAtThisChannel,
                                           portType,
                                           secondaryChannelPlacement)
                        #VPR 6380
                        raise FoundAnAccessPoint
                    else:
                        #Remove self.__portInfo[band][channel] if exists,
                        #could happen when we load a file where a port is now
                        #connected to a different AP config
                        if self.__portInfo['Channel'] == str(channel):
                            self.__portInfo['Channel'] = 'Unknown'    
                if not foundAPsAtThisBand:
                    if self.__portInfo['Band'] == band:
                        self.__portInfo['Band'] = 'Unknown'    
                         
        except (ChannelScanAbortException, FoundAnAccessPoint):
            pass    
        except e:
            print "Unexpected exception during channel scan", str(e)                              
        self.__accessPointsInfo = allAPinfo
    
    def _getValidChannelInfo(self):
        validChannelInfo = copy.deepcopy(self.bandToChannelMap)
        del validChannelInfo['Unknown']
        
        return validChannelInfo
    
    def _doChannelScan(self, band = None, channel = None, hiddenSSIDs = []):
        if band != 'PRESET':
            if band == None:
                band = self.__portInfo['Band']
            if band == 'Unknown':
                return {}
        if band != 'PRESET':
            self._setPortBand(band)  
              
        if channel != 'PRESET':
            if channel == None:
                channel = self.__portInfo['Channel']
                if channel == 'Unknown':
                    return {}
                else:
                    channel = int(channel)
        if channel != 'PRESET':    
            self._writePortChannel(channel)
        
        portBssidList = self._readPortBSSIDs()

        bssidToSSIDmap = self._getSSIDinfo(portBssidList)
        
        if hiddenSSIDs:    
            for bssid in bssidToSSIDmap:
                if bssidToSSIDmap[bssid] == '':
                    ssid = self._searchForHiddenSSIDs(bssid, hiddenSSIDs)
                    bssidToSSIDmap[bssid] = ssid
        
        return bssidToSSIDmap    
            
    def scanAndStoreInfo(self, band = None, channel = None, hiddenSSIDs = []):
        band = self.__portInfo['Band']
        channel = self.__portInfo['Channel']
        if band != 'Unknown' and channel != 'Unknown':
            self._bindPort()
            
            if not hiddenSSIDs:
                hiddenSSIDs = self.__portInfo['hiddenSSIDs']

            bssidToSSIDmap = self._doChannelScan(band, channel, hiddenSSIDs) 
            self.__accessPointsInfo[band] = {}
            self.__accessPointsInfo[band][channel] = bssidToSSIDmap
        
            self._unbindPort()
        
    def _getSSIDinfo(self, portBssidList):
        bssidToSSIDmap  = {}
        for bssid in portBssidList:
            ssid = WE.VCLtest("port.getBssidSsid('%s')"%bssid)
            time.sleep( SCAN_DELAY )
            bssidToSSIDmap[bssid] = ssid
        
        return bssidToSSIDmap
    
    def _searchForHiddenSSIDs(self, bssid, hiddenSSIDs):
        hiddenSSIDofBSSID = ''

        for ssid in hiddenSSIDs:
            dummyClientName = 'dummyClient'
            WE.VCLtest("mc.create('%s')"%dummyClientName)
            WE.VCLtest("mc.setPortList(%s)"%str([self.__name]))
            WE.VCLtest("mc.setBssidList(%s)"%str([bssid]))
            WE.VCLtest("mc.setSsid('%s')"%ssid)
            WE.VCLtest("mc.write('%s')"%dummyClientName)
            WE.VCLtest("mc.doConnectToAP('%s', %d)"%(dummyClientName, 0))
            time.sleep(0.1)
            WE.VCLtest("clientStats.read('%s')"%dummyClientName)
            probeRspTstamp = WE.VCLtest("clientStats.tstampProbeRsp")
            WE.VCLtest("mc.destroy('%s')"%dummyClientName) 
            if probeRspTstamp:
                hiddenSSIDofBSSID = ssid
                break
 
        return hiddenSSIDofBSSID

    def _reloadEthInfo(self):
        pass

def _normalizeBand(portDict):
    validBandsInStr = [str(band) for band in ChassisCardPort.bandMap.keys()]
    normalizeBand = False
    if 'Band' not in portDict:
        if portDict['PortType'] in WE.EthPortType:
            portDict['Band'] = 'N/A' 
        elif portDict['PortType'] in WE.WiFiPortTypes:
            normalizeBand = True
            
    if portDict['Band'] not in validBandsInStr:
        normalizeBand = True
    
    if normalizeBand:        
        band = ChassisCardPort.getBandFromChannel(portDict['Channel'])
        portDict['Band'] = band
    
    #return portDict

def normalizeWMLdata(waveChassisStore):
    """
    This method handles placing, deleting of any information elements for
    backward/forward compatibility. This module is in charge of 
    WaveChassisStore and WavePortStore 
    """
    #Add 'secondaryChannelPlacement' port property for older configurations
    #Add valid Band value

    for chassisName in waveChassisStore:
#        thisChassisStore = waveChassisStore[chassisName]
#        if 'ChassisModel' not in thisChassisStore:
#            thisChassisStore['ChassisModel'] = 'Legacy'
        for cardName in waveChassisStore[chassisName]:
            for portName in waveChassisStore[chassisName][cardName]:
                portDict = waveChassisStore[chassisName][cardName][portName]
                if 'SecondaryChannelPlacement' not in  portDict:
                    portDict['SecondaryChannelPlacement'] = 'defer'
                if 'EnableRxAttenuation' not in portDict:
                    portDict['EnableRxAttenuation'] = 'on'
                #For a brief time, we had 'None' as default for Channel and
                #Band, they are now 'Unknown'
                if portDict['Channel'] == 'None':
                    portDict['Channel'] = 'Unknown'
                        
                #portDict = _normalizeBand(portDict)
                _normalizeBand(portDict)
                if 'PowerCapability' not in portDict:
                    if portDict['PortType'] == WE.NportType:
                        portDict['PowerCapability'] = 'Low 11n'
                    else:
                        portDict['PowerCapability'] = 'Low'
            
                if 'CardModel' not in portDict:
                    portDict['CardModel'] = 'Legacy'   
                     
    return waveChassisStore
