import odict

class UserConfig(object):
    def __init__(self):
################################################################################
###############       USER-CONFIGURABLE PARAMETERS       #######################
################################################################################

        ######################### Hardware definition ##########################
        """
        The CardMap defines the WaveBlade ports that will be available for the test.
        Field Definitions:                                                     
          PortName -        Name given to the specified WaveBlade port. This is a user defined name. 
          ChassisID -       The WT90/20 Chassis DNS name or IP address. Format: 'string' or '0.0.0.0'
          CardNumber -      The WaveBlade card number as given on the Chassis front panel.
          PortNumber -      The WaveBlade port number, should be equal to 0 for current cards. 
          RadioBand -       The band on which the WLAN port transmits and receives.
                            Valid values are: 2400, 4900, or 5000
          Channel -         The channel on which the WLAN port transmits and receives 
                            1-14 - Supported channels on band 2400 MHz
                            1-11, 13, 15, 17, 19, 21, 25 - Supported channels on band 4900 MHz
                            36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 
                            132, 136, 140, 149, 153, 157, 161, 165 - Supported channels on band 5000 MHz
          SecondaryChannel- For 802.11n channel bonding, the location of the secondary channel.
                            Vaild values: 'above', 'below', or 'defer'
          Autonegotiation - Ethernet Autonegotiation mode. Valid values: 'on', 'off', 'forced'.
          Speed -           Ethernet speed setting if not obtained by autonegotiation.
                            Valid values: 10, 100, 1000
          Duplex -          Ethernet Duplex mode if not obtained by autonegotiation. 
                            Valid values: 'full', 'half'
        Field Format: dictionary
          For Wifi Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, <RadioBand>, <RadioChannel> <SecondaryChannel>),
          For Ethernet Cards - 
              <PortName>: ( <ChassisID>, <CardNumber>, <PortNumber>, <autoNegotiation>, <speed>, <duplex> ),
        """
        self.CardMap = {'WT90_W1': ('wt-tga-10-34', 9, 4, 5000, 149, 'defer'),
                        'WT90_E1': ('wt-tga-10-34', 4, 1, 'on', 100, 'full')      
                       }

        ################### First Level Test Parameters ########################
        """
        The parameters in this group need to be set by the user to define the primary
        test configuration. 
        DwellTime -     Global client dwell time. It will be used only when PortsDwellTime is not defined.
        PortsDwellTime- Per port client dwell time. If a corresponding port dwell time is not specified, 
                        the global client dwell time will be used for that port.
        TransmitTime -  This is the amount of time for a test iteration to execute. RFC2544 recommends a time from
                        30-240 seconds. Units: seconds. 
        EthIP -         The IP address of the Ethernet endpoint
        ParseRoamStatsInRealTime - Boolean True/False value. If True, we save and parse the roam stats every second,
                                   otherwise we save the roam stats every 50 seconds and parse it at the end of the roams.
        SavePCAPfile -  Boolean True/False value. If True a PCAP file will be created containing the detailed frame data that
                        was captured on each WT-20/90 port. 
        LoggingDirectory - Location for putting the remaining test results files.
        TimeStampDir -  Add TimeStamp subdirectory to logging directory
        IgnoreClientAssocFailure - Ignore client association failure flag. If set to
                                   True, we will not stop the test when a client failed to
                                   associate with the AP for the first time in the beginning
                                   of the test
        SplitDetailedResultCsvFile - Split the result CSV file when the line number exceeds 50,000 lines
                                     File name will be Detailed_scaled_roaming_portname_part1.csv, 
                                     Detailed_scaled_roaming_portname_part2.csv, etc                    
        """
        self.DwellTime      = 2
        self.PortsDwellTime = {'WT90_W1': 2}
        self.TestDuration   = 10
        self.EthIP          = '192.168.1.10'
        self.ParseRoamStatsInRealTime = False
        self.SavePCAPfile   = False
        self.LoggingDirectory = "logs"
        self.TimeStampDir   = True
        self.IgnoreClientAssocFailure = True
        self.SplitDetailedResultCsvFile = True
        
        ##################### Description of Client setups #####################
        """             
        ClientOptions defines the options available when setting up a/b/g/n clients.
        The first and formost, VCL needs to know what type of client it is in order
        for the correct options to apply.
        Field Definitions for 802.11a/b/g clients:
          PhyType -   Set the type of client.  Values are '11b', '11ag', '11n'.  Default is '11ag'
          PhyRate -   The 802.11 phy rate to apply to all data frames originating from the client.
                      Valid values are all legally defined values
          TxPower - The transmit power in dBm
          ProbeBeforeAssoc - Enables or disables the use of probes before associating and the probing mode
                             Valid values are 'unicast', 'bdcast' and 'off'
          ClientLearning - Enable or disable a learning flow
          LearningRate - The rate at which the learning flow is sent out
          GratuitousArp - Enables or disables the client to perform a gratuitous ARP after association with an AP
          ProactiveKeyCaching - Proactive key caching
          LeaseDhcpOnRoam - Renew DHCP on roam
          LeaseDhcpReconnection - Renew DHCP on re-association
          DhcpTimeout - DHCP timeout in msec
        """
        ClientOptions = odict.OrderedDict([('PhyType', '11ag'), ])
        ClientOptions['PhyRate']           = 6
        ClientOptions['TxPower']           = -6
        ClientOptions['ProbeBeforeAssoc']  = 'unicast'
        ClientOptions['ClientLearning']    = 'off'
        ClientOptions['LearningRate']      = 5
        ClientOptions['GratuitousArp']     = 'off'
        ClientOptions['ProactiveKeyCaching'] = 'off'
        ClientOptions['LeaseDhcpOnRoam']   = 'off'
        ClientOptions['LeaseDhcpReconnection'] = 'off'
        ClientOptions['DhcpTimeout'] = 5000

        """             
        ClientOptions for 802.11n clients are sligthly different.  
        Field Definitions:
          PhyType            - Set the type of client.  Values are '11b', '11ag', '11n'.
          PlcpConfiguration  - The type of PLCP configuration used for 11n.  Valid options
                               are 'legacy', 'mixed', 'greenfield'.  Default is 'mixed'
          ChannelBandwidth   - The channel bandwidth in MHz; values are either 20 or 40.
          ChannelModel       - These specify the channel model used for emulating the intervening
                               effects on the MIMO transmission. Vaild values are
                               'A', 'B', 'C', 'D', 'E', 'F', or 'Bypass'.
          DataMcsIndex       - Set the modulation and coding scheme used for flows transmitting
                               from 11n clients.  See 802.11n section 20.6 for list of MCSs.            
          GuardInterval      - (optional) The guard interval in nanoseconds (ns).  Valid values are
                               'short', 'standard'.  Default is 'standard'
          WmeEnabled         - Enables or disables the use of QoS access categories (AC). Must be turned on for 11n.
          AggregationEnabled - Enables or disables the aggregation for 11n clients.
          GratuitousArp      - Enables or disables the client to perform a gratuitous ARP after association with an AP
          ProbeBeforeAssoc   - Enables or disables the use of probes before associating and the probing mode.
                               Valid values are 'unicast', 'bdcast' and 'off'
          ClientLearning     - Enable or disable a learning flow
          LearningRate       - The rate at which the learning flow is sent out
          TxPower            - The transmit power in dBm
          ProactiveKeyCaching- proactive key caching
          LeaseDhcpOnRoam    - renew DHCP on roam
          LeaseDhcpReconnection - renew DHCP on re-association
          DhcpTimeout - DHCP timeout in msec
        """
        ClientOptions11n = odict.OrderedDict([('PhyType', '11n'), ])
        ClientOptions11n['PlcpConfiguration']  = 'mixed'
        ClientOptions11n['ChannelBandwidth']   = 40
        ClientOptions11n['ChannelModel']       = 'Bypass'
        ClientOptions11n['DataMcsIndex']       = 15
        ClientOptions11n['GuardInterval']      = 'standard'
        ClientOptions11n['WmeEnabled']         = 'on'
        ClientOptions11n['AggregationEnabled'] = 'on'
        ClientOptions11n['GratuitousArp']      = 'off'
        ClientOptions11n['ProbeBeforeAssoc']   = 'unicast'
        ClientOptions11n['ClientLearning']     = 'off'
        ClientOptions11n['LearningRate']       = 5
        ClientOptions11n['TxPower']            = -6
        ClientOptions11n['ProactiveKeyCaching']= 'off'
        ClientOptions11n['LeaseDhcpOnRoam']   = 'off'
        ClientOptions11n['LeaseDhcpReconnection'] = 'off'
        ClientOptions11n['DhcpTimeout'] = 5000

        """
        Security Options is dictionary of passed security parameters.  
        It has a mandatory key of 'Method' and optional keys depending upon the 
        particular security chosen.  
        Field Definitions:
            Method - valid values are:
                'None'
                'WEP-Open-40'
                'WEP-Open-128'
                'WEP-SharedKey-40'
                'WEP-SharedKey-128'
                'WPA-PSK'
                'WPA-EAP-TLS'
                'WPA-EAP-TLS-AES'
                'WPA-EAP-TTLS-GTC'
                'WPA-PEAP-MSCHAPV2'
                'WPA-EAP-FAST'
                'WPA2-PSK'
                'WPA2-EAP-TLS'
                'WPA2-EAP-TTLS-GTC'
                'WPA2-PEAP-MSCHAPV2'
                'WPA2-EAP-FAST'
                'DWEP-EAP-TLS'
                'DWEP-EAP-TTLS-GTC'
                'DWEP-PEAP-MSCHAPV2'
                'LEAP'
                'WPA-LEAP'
                'WPA2-LEAP'
                'WPA-PSK-AES'
                'WPA-PEAP-MSCHAPV2-AES'
                'WPA2-PEAP-MSCHAPV2-TKIP'
                'WPA2-EAP-TLS-TKIP'
                'WPA2-PSK-TKIP'
                'WPA-CCKM-PEAP-MSCHAPv2-TKIP'
                'WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP'
                'WPA-CCKM-TLS-TKIP'
                'WPA-CCKM-TLS-AES-CCMP'
                'WPA-CCKM-LEAP-TKIP'
                'WPA-CCKM-LEAP-AES-CCMP'
                'WPA-CCKM-FAST-TKIP'
                'WPA-CCKM-FAST-AES-CCMP'
                'WPA2-CCKM-PEAP-MSCHAPv2-TKIP'
                'WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP'
                'WPA2-CCKM-TLS-TKIP'
                'WPA2-CCKM-TLS-AES-CCMP'
                'WPA2-CCKM-LEAP-TKIP'
                'WPA2-CCKM-LEAP-AES-CCMP'
                'WPA2-CCKM-FAST-TKIP'
                'WPA2-CCKM-FAST-AES-CCMP'
            KeyId - The ID number of the security key. Used for WEP open & shared.
                    Valid values are 1-4
            KeyType - NetworkKey type. Valid values are 'ascii' or 'hex'
            NetworkKey - Network key, limited to 128 bytes
            RootCertificate - The file name and path of the root certificate. 
                              The file will be loaded onto the system when the client is setup
            ClientCertificate - The file name and path of the client certificate. 
                                The file will be loaded onto the system when the client is setup
            PrivateKeyFile - The file name and path of the private key. 
                             The file will be loaded onto the system when the client is setup
            EnableValidateCertificate - Used by PEAP-MSCHAPv2. Valid values are 'on' or 'off'
            Identity - The user name for 802.1x authentication. Default value is 'anonymous'
            Password - The password for 802.1x security. Default value is 'whatever'
            AnonymousIdentity - The anonymous identity for 802.1x security for TTLS
            LoginMethod - Valid values are 'Single', 'Increment' and 'File'
                          'Single' - all clients use identical identity and password
                          'Increment' - identity & password are incremented for each new client.
                                        i.e. 'Username01' & 'Password01', 'Username02' & 'Password02', etc
                                        Please see 'StartIndex'
                          'File' - the identity & password info for each client is read from a file.
                                   Please see 'LoginFile'
            StartIndex - starting index when 'LoginMethod' is set to 'Increment'
            LoginFile - location of login file. Used when 'LoginMethod' is set to 'File'

        Some common one defined:
        """
        Security_None = {'Method': 'None'}
        Security_WEP  = {'Method': 'WEP-Open-128', 'KeyId': 1, 'NetworkKey': '00:00:00:00:00:00' }
        Security_WPA  = {'Method': 'WPA-PSK', 'NetworkKey': 'whatever', 'KeyType': 'ascii'}
        Security_WPA2_PSK  = {'Method': 'WPA2-PSK', 'NetworkKey': 'whatever', 'KeyType': 'ascii'}
        Security_WPA_hex = {'Method': 'WPA-PSK', 'NetworkKey': 'f33572c66310a62a55b5aa621f089ff359107c3d745fb0815fa0c73439730b0c', 'KeyType': 'hex'}
        Security_WPA2_hex = {'Method': 'WPA2-PSK', 'NetworkKey': 'f33572c66310a62a55b5aa621f089ff359107c3d745fb0815fa0c73439730b0c', 'KeyType': 'hex'}        
        Security_WPA2_EAP_TLS = {'Method': 'WPA2-EAP-TLS', 'Identity': 'anonymous', 'Password' : 'whatever', 'LoginMethod': 'Single'}

        """
        Login information for clients. This information will be used by either 802.1X or Web Authentication.
        Logins can be defined in one of three ways:
            None = no per-client login, use per-group 'Identity' and 'Password'
            List of tuples in the form: [ ( 'username', 'password' ), ... ] used across client groups.
            Dictionary of the form: { 'groupname': [ (u,p), (u,p), ... ] }
        """
        self.Logins = [ 
            ('anonymous', 'whatever'), 
            ]

        """
        To setup clients for the test they will be placed into client groups. Each group is assigned to
        a logical port. Many different client groups can be defined and a port may have more than one group
        assigned to it. The client groups are divided between source(orginating traffic) and destination
        (receiving traffic). 
        Field Definitions:
          GroupName -  User defined name given to the client Group. Name has to be unique.
          PortName -   Logical port name defined the CardMap.
          SSID       - The SSID to which this client group will associate. SSID will be an ASCII text string.
          MACaddress - The MAC address to use.  Using the word 'DEFAULT' will cause a random address to be
                       generated by the system.  Using the word 'AUTO' will assign an unique MAC by cc:ss:pp:ip:ip:ip
          IPaddress -  The Base IP address to use for this client group. Individual addresses for each client
                       in the group will be derived from the base IP address. An address of 0.0.0.0 implies that
                       DHCP will be used to obtain the client IP address. 
          SubNet    -  SubNet mask 
          Gateway -    Gateway address. 
          IncrTuple -  This is tuple of three values in the form (<count>, <MacIncrByte>, <IpIncrByte>). <count>
                       is the number of clients to create, <MacIncrByte> is the byte in the six byte MAC address
                       to increment (e.g. 00:00:00:00:10:02); Use the keyword 'DEFAULT' for automatic MAC incrementing.
                       <IpIncrByte> is the byte in the four byte IP address to increment (e.g. 0.0.0.1 will increment the
                       last byte by 1). 
                       NOTE: An empty tuple - () means that just one client is being defined. 
          Security -   Name of security policy to use for this client group. 'NONE' will cause open security. 
                       Security policies only apply to WiFi clients. 
          Options -    Reference to a client option list as defined above. 
        Field Format: a list of tuples
          ( <GroupName>, <PortName>, <SSID>, <MACaddress>, <IPaddress>, <SubNet>, <Gateway>, ( <IncrTuple> ), Security, <options> ),
          ( <GroupName2>, <PortName2>, <SSID>, <MACaddress2>, <IPaddress2>, <SubNet2>, <Gateway2>, ( <IncrTuple2> ), Security2, <options2> )
        """
        self.SourceClients = [
            ('ClientWifi', 'WT90_W1', 'OPEN', 'AUTO', '192.168.2.10', '255.255.0.0', '192.168.1.1', (10, 'DEFAULT', '0.0.0.1'), Security_None, ClientOptions),
            ]
        self.DestClients = [
            ('ClientEth', 'WT90_E1', '00:00:00:00:00:00', 'AUTO', self.EthIP, '255.255.0.0', '192.168.1.1', (1, 'DEFAULT', '0.0.0.1'), Security_None, {}),
            ]

        ####################### Timing parameters ##############################
        """
        These parameters will effect the performance of the test. They should only be altered if a specific
        problem is occuring that keeps the test from executing with the DUT. 
        
        BSSIDscanTime -     Amount of time to allow for scanning during the BSSID discovery process. Units: seconds
        maxBssidCount -     Maximum number of BSSIDs in a wifi port (min value is 2, max value is 8)
        AssociateRate -     The rate at which the test will attempt to associate clients with the SUT. This includes the time
                            required to complete .1X authentications. 
                            Units: associations/second. Type: float
        AssociateRetries -  Number of attempts to retry the complete association process for each client in the test.
        AssociateTimeout -  Amount of time the test will wait for a client association to complete before considering iteration
                            a failed connection. Units: seconds; Type: float
        stunRate         -  the rate at which the test will attempt to send STUN packets from clients to the Ethernet end-point.
        """
        self.BSSIDscanTime    = 2
        self.maxBssidCount    = 8
        self.AssociateRate    = 1.0
        self.AssociateRetries = 0
        self.AssociateTimeout = 5.0
        self.stunRate         = 1.0

        ################### Misc info for test results files ###################
        self.TestID = '-specify-'
        self.DUTinfo = {}
        self.DUTinfo['WLAN Switch Model'] = '-specify-'
        self.DUTinfo['WLAN Switch Version'] = '-specify-'
        self.DUTinfo['AP Model'] = '-specify-'
        self.DUTinfo['AP SW Version'] = '-specify-'

################################################################################
###############    END OF USER-CONFIGURABLE PARAMETERS   #######################
################################################################################

        self.version = 1.0
