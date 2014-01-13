require 'motive'

class PrtMps
    def initialize(motive)

        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.X_ACTIONTEC_PortMappings')
        parameter.get('PortMappingNumberOfEntries')

        # parameter.to('PortMapping.1')
        # parameter.get('Status')
        # parameter.get('NetworkedDevicename')
        # parameter.get('NetworkedAdress')
        # parameter.get('PublicIPAdress')
        # parameter.get('PublicIPAdress')
        # parameter.get('Protocols')
        # parameter.get('WANConnectionType')

        motive.parameterSubmit
    end
end
