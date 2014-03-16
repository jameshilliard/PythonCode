# InternetGatewayDevice.ManagementServer.
# InternetGatewayDevice.ManagementServer.URL
# InternetGatewayDevice.ManagementServer.Username
# InternetGatewayDevice.ManagementServer.Password
# InternetGatewayDevice.ManagementServer.PeriodicInformEnable
# InternetGatewayDevice.ManagementServer.PeriodicInformInterval
# InternetGatewayDevice.ManagementServer.PeriodicInformTime
# InternetGatewayDevice.ManagementServer.ParameterKey
# InternetGatewayDevice.ManagementServer.ConnectionRequestURL
# InternetGatewayDevice.ManagementServer.ConnectionRequestUsername
# InternetGatewayDevice.ManagementServer.ConnectionRequestPassword
# InternetGatewayDevice.ManagementServer.UpgradesManaged

require 'motive'

class MgmtSvr
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.ManagementServer')
        parameter.set('string', 'URL', 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt')
        parameter.set('string', 'ConnectionRequestURL', 'http://71.191.180.66.4567/202763136')
        parameter.set('string', 'ConnectionRequestUsername','')

        motive.parameterSubmit


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.ManagementServer')
        parameter.get('URL')
        parameter.get('Username')
        parameter.get('PeriodicInformEnable')
        parameter.get('PeriodicInformInterval')
        parameter.get('PeriodicInformTime')
        parameter.get('ParameterKey')
        parameter.get('ConnectionRequestURL')
        parameter.get('ConnectionRequestUsername')
        parameter.get('UpgradesManaged')
        parameter.get('X_Verizon_RetryInterval')
        parameter.get('ManageableDeviceNumberOfEntries')
        parameter.get('ManageableDeviceNotificationLimit')

        motive.parameterSubmit


        parameter = motive.verifyParameterValues

        parameter.at('InternetGatewayDevice.ManagementServer')
        parameter.verify('URL', 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt')
        parameter.verify('ConnectionRequestURL', 'http://71.191.180.66.4567/202763136')
        parameter.verify('ConnectionRequestUsername','')
    end
end
