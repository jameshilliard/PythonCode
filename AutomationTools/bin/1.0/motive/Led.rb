require 'motive'

class Led
    def initialize(motive)

        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.X_ACTIONTEC_LED')
        parameter.get('Wireless_LAN_Link')
        parameter.get('MoCA_LAN_Link')
        parameter.get('MoCA_WAN_Link')
        parameter.get('Ethernet_WAN')
        parameter.get('Ethernet_LAN1')
        parameter.get('Ethernet_LAN2')
        parameter.get('Ethernet_LAN3')
        parameter.get('Ethernet_LAN4')

        motive.parameterSubmit
    end
end
