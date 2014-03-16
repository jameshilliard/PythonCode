# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.1.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.1.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.1.Port
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.2.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.2.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.2.Port
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.3.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.3.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.3.Port

# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.1.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.1.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.1.Port
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.2.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.2.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.2.Port
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.3.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.3.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.3.Port
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.4.
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.4.Enable
# InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.4.Port

require 'motive'

class RmteAdm
    def initialize(motive)

        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.1')
        parameter.get('Enable')
        parameter.get('Port')
        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.2')
        parameter.get('Enable')
        parameter.get('Port')
        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Telnets.3')
        parameter.get('Enable')
        parameter.get('Port')

        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.1')
        parameter.get('Enable')
        parameter.get('Port')
        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.2')
        parameter.get('Enable')
        parameter.get('Port')
        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.3')
        parameter.get('Enable')
        parameter.get('Port')
        parameter.at('InternetGatewayDevice.X_ACTIONTEC_RemoteAdmin.Https.4')
        parameter.get('Enable')
        parameter.get('Port')

        motive.parameterSubmit
    end
end
