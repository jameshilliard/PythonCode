# Create a WML file to be used by Wave Engine
#

# Where to store the configureation file
SavedFilename = "saved.xml"

############# Hardware defination ####################
waveChassisStore = {}
waveChassisStore['wt-tga-10-6a'] = {'Card 1': {'Name': 'Port_E1', 'Type': '8023',  'CardID': 1, 'PortID': 0, 'EthernetSpeed': 100, 'Duplex': 'full', 'Autonegotiation': 'on'},
                                    'Card 2': {'Name': 'Port_W1', 'Type': '80211', 'CardID': 2, 'PortID': 0, 'Channel': '6'},
                                    'Card 3': {'Name': 'Port_W2', 'Type': '80211', 'CardID': 3, 'PortID': 0, 'Channel': '11'},
                                    'Card 4': {'Name': 'Port_W3', 'Type': '80211', 'CardID': 4, 'PortID': 0, 'Channel': '2'},
                                    'Card 5': {'Name': 'Port_W4', 'Type': '80211', 'CardID': 5, 'PortID': 0, 'Channel': '1'},
                                    'Card 6': {'Name': 'Port_W5', 'Type': '80211', 'CardID': 6, 'PortID': 0, 'Channel': '1'},
                                    'Card 7': {'Name': 'Port_W6', 'Type': '80211', 'CardID': 7, 'PortID': 0, 'Channel': '1'}}

#Description of Client Profiles
waveClientTableStore = {}
waveClientTableStore['Client_One'] =   { 'Name':        'Client_One',
                                         'PortName':    'Port_W1',
                                         'BSSID':       '00:00:00:00:00:00',
                                         'MacAddress':  'DEFAULT',
                                         'Dhcp':        'Disable',
                                         'BaseIP':      '192.168.50.11',
                                         'SubnetMask':  '255.255.255.0',
                                         'Gateway':     '192.168.50.10',
                                         'NumClients':  1,
                                         'MacAddressIncr': 'DEFAULT',
                                         'IncrIP':      '0.0.0.1',
                                         'Security':    'open',
                                         'Options':     {'PhyRate': 54, 'Sifs': 16, 'SlotTime': 9, 'AckTimeout': 350} }
waveClientTableStore['Client_Two'] =   { 'Name':        'Client_Two',
                                         'PortName':    'Port_W2',
                                         'BSSID':       '00:00:00:00:00:00',
                                         'MacAddress':  'DEFAULT',
                                         'Dhcp':        'Disable',
                                         'BaseIP':      '192.168.50.10',
                                         'SubnetMask':  '255.255.255.0',
                                         'Gateway':     '192.168.50.10',
                                         'NumClients':  1,
                                         'MacAddressIncr': 'DEFAULT',
                                         'IncrIP':      '0.0.0.1',
                                         'Security':    'open',
                                         'Options':     {'PhyRate': 54, 'Sifs': 16, 'SlotTime': 9, 'AckTimeout': 350} }
    
#Descript the traffic flow
waveMappingStore = [['Client_One'], ['Client_Two'], 'OneToOne', 'Unidirectional', {'Type': 'IP', 'PhyRate': 54 }]

#Test Paramters
waveTestStore  = {}
waveTestStore['TestParameters']                   = {}
waveTestStore['TestParameters']['NumIterations']  =   1 
waveTestStore['TestParameters']['LearningTime']   =   2
waveTestStore['TestParameters']['TransmitTime']   =  10
waveTestStore['TestParameters']['SettleTime']     =   2
waveTestStore['TestParameters']['AgingTime']      =  10
waveTestStore['TestParameters']['FrameSizeList']  = [ 64, 1518 ]
waveTestStore['TestParameters']['ILOADlist']      = [ 100, 500, 1000 ]

waveTestStore['LogsAndResultsFile']                          = {}
waveTestStore['LogsAndResultsFile']['CSVfilename']               = 'Results_file.csv'
waveTestStore['LogsAndResultsFile']['BackupLogFileCheckBox']     = 'Unchecked'
waveTestStore['LogsAndResultsFile']['BackupReportsFileCheckBox'] = 'Unchecked'
waveTestStore['LogsAndResultsFile']['LogFile']                   = 'LogFile.log'
waveTestStore['LogsAndResultsFile']['ReportsFile']               = 'ReportsFile.log'

waveTestStore['BinarySearchSettings']                            = {}
waveTestStore['BinarySearchSettings']['SearchMinimum']           =    0
waveTestStore['BinarySearchSettings']['SearchMaximum']           = 1024
waveTestStore['BinarySearchSettings']['SearchResolutionPercent'] = 0.1
waveTestStore['BinarySearchSettings']['SearchAcceptLossPercent'] = 0.0

#Other Timing pararmetes that may be changed
waveTestStore['Learning']                      = {}
waveTestStore['Learning']['BSSIDscanTime']     =   2
waveTestStore['Learning']['AssociateRate']     =  10
waveTestStore['Learning']['AssociateRetries']  =   0
waveTestStore['Learning']['AssociateTimeout']  =   5.0
waveTestStore['Learning']['ARPRate']           =  10
waveTestStore['Learning']['ARPRetries']        =   0
waveTestStore['Learning']['ARPTimeout']        =   5.0

waveTestStore['WaveEngineConfig']                      = {}
waveTestStore['WaveEngineConfig']['LoopDelay_mS']      = 250
waveTestStore['WaveEngineConfig']['DisplayPrecission'] =   3

########################## DO NOT MODIFY BELOW HERE ##########################
import wmlParser
MyConfig = wmlParser.parseWml(SavedFilename)

#Need by wmlParser, but not used
for pChassis in waveChassisStore.keys():
    for pCard in waveChassisStore[pChassis].keys():
        waveChassisStore[pChassis][pCard]['BindStatus'] = True
        waveChassisStore[pChassis][pCard]['Port'] = 'Port 1'
for client in waveClientTableStore.keys():
        waveClientTableStore[client]['Interface'] = 'Banana'
        waveClientTableStore[client]['SSID'] = 'unknown'
wavePortStore = {}

MyConfig.convertToWmlConfig(SavedFilename,waveChassisStore,wavePortStore,waveClientTableStore,waveTestStore,waveMappingStore)
