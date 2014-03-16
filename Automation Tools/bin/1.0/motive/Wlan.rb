# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.Enable
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.Status
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BSSID
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.MaxBitRate
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.Channel
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.SSID
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BeaconType
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.MACAddressControlEnabled
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.Standard
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WEPKeyIndex
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.KeyPassphrase
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WEPEncryptionLevel
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BasicEncryptionModes
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BasicAuthenticationMode
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WPAEncryptionModes
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WPAAuthenticationMode
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.IEEE11iEncryptionModes
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.IEEE11iAuthenticationMode
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PossibleChannels
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BasicDataTransmitRates
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.OperationalDataTransmitRates
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PossibleDataTransmitRates
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.InsecureOOBAccessEnabled
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.BeaconAdvertisementEnabled
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.RadioEnabled
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AutoRateFallBackEnabled
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.LocationDescription
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.ChannelsInUse
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.DeviceOperationMode
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.DistanceFromRoot
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PeerBSSID
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AuthenticationServiceMode
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.TotalBytesSent
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.TotalBytesReceived
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.TotalPacketsSent
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.TotalPacketsReceived
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.TotalAssociations
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.AssociatedDeviceMACAddress
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.AssociatedDeviceIPAddress
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.AssociatedDeviceAuthenticationState
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.LastRequestedUnicastCipher
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.LastRequestedMulticastCipher
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.AssociatedDevice.{i}.LastPMKId
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WEPKey.{i}.
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.WEPKey.{i}.WEPKey
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PreSharedKey.{i}.
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PreSharedKey.{i}.PreSharedKey
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PreSharedKey.{i}.KeyPassphrase
# InternetGatewayDevice.LANDevice.{i}.WLANConfiguration.{i}.PreSharedKey.{i}.AssociatedDeviceMACAddress

require 'motive'

# $HIDE_IE = true

class Wlan
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
        parameter.set('boolean', 'Enable', 'true')
        parameter.set('string', 'Status', 'Up')
        parameter.set('unsignedInt', 'Channel', '0')
        parameter.set('string', 'SSID', 'Home')
        parameter.set('string', 'WEPKeyIndex', '1')
        parameter.set('string', 'KeyPassphrase', '')
        parameter.set('string', 'WEPENcryptionLevel', '40-bit,104-bit')


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
        parameter.get('Enable')
        parameter.get('Status')
        parameter.get('BSSID')
        parameter.get('MaxBitRate')
        parameter.get('Channel')
        parameter.get('SSID')
        parameter.get('BeaconType')
        parameter.get('MACAddressControlEnabled')
        parameter.get('Standard')
        parameter.get('WEPKeyIndex')
        parameter.get('KeyPassphrase')
        parameter.get('WEPEncryptionLevel')
        parameter.get('BasicEncryptionModes')
        parameter.get('BasicAuthenticationMode')
        parameter.get('WPAEncryptionModes')
        parameter.get('WPAAuthenticationMode')
        # parameter.get('IEEE11iEncryptionModes')
        # parameter.get('IEEE11iAuthenticationMode')
        parameter.get('PossibleChannels')
        parameter.get('BasicDataTransmitRates')
        parameter.get('OperationalDataTransmitRates')
        parameter.get('PossibleDataTransmitRates')
        parameter.get('InsecureOOBAccessEnabled')
        parameter.get('BeaconAdvertisementEnabled')
        parameter.get('RadioEnabled')
        parameter.get('AutoRateFallBackEnabled')
        parameter.get('LocationDescription')
        parameter.get('ChannelsInUse')
        parameter.get('DeviceOperationMode')
        parameter.get('DistanceFromRoot')
        parameter.get('PeerBSSID')
        parameter.get('AuthenticationServiceMode')
        parameter.get('TotalBytesSent')
        parameter.get('TotalBytesReceived')
        parameter.get('TotalPacketsSent')
        parameter.get('TotalPacketsReceived')
        parameter.get('TotalAssociations')

        motive.parameterSubmit


        parameter = motive.verifyParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration,7')
        parameter.verify('Enable', 'true')
        parameter.verify('Status', 'Up')
        parameter.verify('Channel', '0')
        parameter.verify('SSID', 'Home')
        parameter.verify('WEPKeyIndex', '1')
        parameter.verify('WEPENcryptionLevel', '40-bit,104-bit')
    end
end
