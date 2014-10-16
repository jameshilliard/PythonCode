# InternetGatewayDevice.LANDevice.{i}
# InternetGatewayDevice.LANDevice.{i}LANEthernetInterfaceNumberOfEntries
# InternetGatewayDevice.LANDevice.{i}LANUSBInterfaceNumberOfEntries
# InternetGatewayDevice.LANDevice.{i}LANWLANConfigurationNumberOfEntries
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DHCPServerConfigurable
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DHCPServerEnable
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DHCPRelay
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.MinAddress
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.MaxAddress
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.ReservedAddresses
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.SubnetMask
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DNSServers
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DomainName
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPRouters
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.DHCPLeaseTime
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.UseAllocatedWAN
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.AssociatedConnection
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.PassthroughLease
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.PassthroughMACAddress
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.AllowedMACAddresses
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterfaceNumberOfEntries
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterface.{i}.
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterface.{i}.Enable
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterface.{i}.IPInterfaceIPAddress
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterface.{i}.IPInterfaceSubnetMask
# InternetGatewayDevice.LANDevice.{i}.LANHostConfigManagement.IPInterface.{i}.IPInterfaceAddressingType
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Enable
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Status
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.MACAddress
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.MACAddressControlEnabled
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.MaxBitRate
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.DuplexMode
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Stats.
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Stats.BytesSent
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Stats.BytesReceived
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Stats.PacketsSent
# InternetGatewayDevice.LANDevice.{i}.LANEthernetInterfaceConfig.{i}.Stats.PacketsReceived

require 'motive'

class Lan
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.LANHostConfigManagement')
        parameter.set('boolean', 'DHCPServerEnable', 'true')
        parameter.set('string', 'MinAddress', '192.168.1.11')
        parameter.set('string', 'MaxAddress', '192.168.1.19')
	parameter.set('string', 'DHCPLeaseTime', '600')
	
        parameter.at('InternetGatewayDevice.Firewall')
        parameter.set('string', 'Config', 'Low')

        motive.parameterSubmit


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.LANHostConfigManagement')
        parameter.get('DHCPServerConfigurable')
        parameter.get('DHCPServerEnable')
        parameter.get('DHCPRelay')
        parameter.get('MinAddress')
        parameter.get('MaxAddress')
        parameter.get('ReservedAddresses')
        parameter.get('SubnetMask')
        parameter.get('DNSServers')
        parameter.get('DomainName')
        parameter.get('IPRouters')
        parameter.get('DHCPLeaseTime')
        parameter.get('UseAllocatedWAN')
        parameter.get('AssociatedConnection')
        parameter.get('PassthroughLease')
        parameter.get('PassthroughMACAddress')
        parameter.get('AllowedMACAddresses')
        parameter.get('IPInterfaceNumberOfEntries')

        parameter.to('LANDevice.1')
        parameter.get('Enable')
        parameter.get('IPInterfaceIPAddress')
        parameter.get('IPInterfaceSubnetMask')
        parameter.get('IPInterfaceAddressingType')

        motive.parameterSubmit


        parameter = motive.verifyParameterValues

        parameter.at('InternetGatewayDevice.LANDevice.1.LANHostConfigManagement')
        parameter.verify('DHCPServerEnable', 'true')
        parameter.verify('MinAddress', '192.168.1.11')
        parameter.verify('MaxAddress', '192.168.1.19')

        require 'peer-a'

        PeerA.new('192.168.1.11', 'connect')
    end
end
