__metaclass__ = type

class genericTestSetupModel:
    DefaultUDPsrcPort = 8000
    DefaultUDPdestPort = 69
    waveTestParametersList = ['TestDurationHr',
                               'TestDurationMin',
                               'TestDurationSec',
                               'TrialDuration',
                               'NumTrials',
                               'LossTolerance',
                               'SettleTime', 
                               'ClientContention',
                               'RandomSeed',
                               'AcceptableFrameLossRate',
                               'ReferenceTPUTMode',
                               'ThroughputInputMode',
                               'AcceptableThroughput'
                               'AcceptableMaxLatency',
                               'AcceptableForwardingRate',
                               'ForwardingRateMode',
                               'ExpectedClientConnections',
                               'AcceptableGoodput',
                               'GoodputMode',
                               'ExpectedCallCapacity',
                               'ExpectedAuthentications'
                               ]
    
    waveTestLearningList = ['ArpNumRetries',
                             'ArpRate',
                             'ArpTimeout',
                             'AgingTime',
                             'ClientLearningTime',
                             'FlowLearningTime'
                             ]
    
    waveTestConnectionList = ['ConnectionType', 
                               'AssocTimeout', 
                               'AssocRate'
                               ]
    
    waveTestPayloadList = ['Content',
                           'PayloadData',
                           'UserPattern'
                           ]
    
    waveTestTrafficList = ['TrafficType']
    
    waveTestUdpList = ['SourcePort',
                       'DestinationPort']
    
    waveTestIcmpList = ['Type',
                        'Code'
                        ]
    
    waveTestTcpList = ['SourcePort',
                        'IncrSourcePort',
                        'DestinationPort',
                        'IncrDestPort',
                        'Sequence','Ack',
                        'DataOffset',
                        'Window',
                        'UrgentPointer',
                        'Checksum',
                        'DataOptionsPadding'
                        ]
    
    waveTestTcpFlagsList = ['SynBit',
                             'FinBit',
                             'RstBit',
                             'PshBit',
                             'UrgBit',
                             'AckBit',
                             'EceBit',
                             'CwrBit'
                             ]
    
    waveTestRawList = ['RawData']
    
    waveTestDutInfoList = ['WLANSwitchModel',
                            'WLANSwitchSWVersion',
                            'APModel',
                            'APSWVersion'
                            ]
    
    waveLogsAndResultsInfoList = ['LogsDir',
                                   'TimeStampDir', 
                                   'TestNameDir', 
                                   'GeneratePdfReport',
                                   'pf',
                                   'db',
                                   'dbtype',
                                   'dbname',
                                   'dbusername',
                                   'dbpassword',
                                   'dbserverip',
                                   'TestCaseName',
                                   'TestCaseDescription'
                                   ]
    
    @classmethod
    def normalizeWMLdata(cls, waveTestStore, testName):

        #For Rate Vs Range test, we no longer (since 4.1) support non-udp traffic
        #types
        if testName == "rate_vs_range":
            if waveTestStore['Traffics']['TrafficType'] == 'Tcp':
                waveTestStore['Traffics']['TrafficType'] = 'Udp'
                srcPort = waveTestStore['Traffics']['TrafficType']['SourcePort']
                destPort = waveTestStore['Traffics']['TrafficType']['DestinationPort']
                waveTestStore['Traffics']['TrafficType']['SourcePort'] = srcPort
                waveTestStore['Traffics']['TrafficType']['SourcePort'] = destPort
            elif waveTestStore['Traffics']['TrafficType'] == 'Icmp':
                #Set the default Udp traffic config
                waveTestStore['Traffics']['TrafficType'] = 'Udp'
                waveTestStore['Traffics']['TrafficType']['SourcePort'] = self.DefaultUDPsrcPort
                waveTestStore['Traffics']['TrafficType']['SourcePort'] = self.DefaultUDPdestPort
        
        return waveTestStore