__metaclass__ = type

class specificTestSetupModel:
    """
    Automation can't digest any dependency on qt. Some of the attributes, methods
    of specificTestSetup (as other modules in WaveAppSuite) are not qt related
    and those methods are used elsewhere (primarily ../we_lib/wmlparser.py).
    Make those attributes and methods accessible without dependency on qt, 
    this class serves that purpose.
    """    
    UserSpecifiableMedCapacityTests = ['unicast_max_forwarding_rate',
                                      'tcp_goodput',
                                      'unicast_packet_loss',
                                      'unicast_unidirectional_throughput',
                                      'mesh_max_forwarding_rate_per_hop', 
                                      'mesh_throughput_per_hop', 
                                      'mesh_throughput_aggregate'
                                      ]

    #For now choosing to go with class variable which has the default 
    #user specified medium capacity config. TODO- use below class method
    #which can be called(by wml parser) to normalize specific test setup data
    DefaultUserSpecifiedMedCapacityConfig = {
                                             'SpecifiedMediumCapacityRates': {},
                                             'Mode': 'Auto'
                                             }
    
    @classmethod
    def normalizeWMLdata(cls, waveTestSpecificStore):
        """
        This method handles placing, deleting of any information elements for
        backward/forward compatibility. This module is in charge of 
        WaveTestSpecificStore
        """
        for testName in waveTestSpecificStore:
            if testName in cls.UserSpecifiableMedCapacityTests:
                if 'MediumCapacity' not in waveTestSpecificStore[testName]:
                    waveTestSpecificStore[testName]['MediumCapacity'] = DefaultUserSpecifiedMedCapacityConfig

        return waveTestSpecificStore